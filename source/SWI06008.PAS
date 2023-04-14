Function BitSet(B:byte;i:integer):Boolean;
var k    : integer;
    Mask : integer;

begin
 Mask:=$01;
 for k:=0 to i-1 do Mask:=Mask shl 1;
 BitSet:=((B and Mask) = Mask);
end;

Procedure Propagate;     {Forward}
var n:HiddenPtr;
    j:integer;

procedure PropagateHiddenLayer(NI,NO:integer;CI:HiddenVec;var CO:HiddenVec;W:HiddenMat);
var
  SumOfSquares : integer;
  Sum          : Real;                    {Activation Level       }
  i,j          : integer;

begin
    SumOfSquares:=1;
    if Normalization then
      for i:=0 to NI do
        if CI[i] then Inc(SumOfSquares);  { Sum all i inputs for normalization}
    for j:= 0 to NO do begin
      Sum:=0;
      for i:=0 to NI do
         if CI[i] then Sum:=Sum+W[i,j];   { Sum all i inputs for j-th unit  }
      CO[j]:=Sum/{Sqrt}(K*SumOfSquares)>=0;
      end;
    if NO<>7 then CO[0]:=True; {Biasing Neuron is always on}
end;                           {No Biasing Neuron for last layer though (use NO=7 to detect it)}

procedure PropagateFirstLayer(NI,NO:integer;CI:Vector;var CO:HiddenVec;var W:Matrix);
var                                                                 {   ^---stops stack overflow}
  SumOfSquares : integer;
  Sum          : Real;                    {Activation Level       }
  i,j          : integer;

begin
    SumOfSquares:=1000;
    if Normalization then
      for i:=0 to NI do
        if CI[i] then Inc(SumOfSquares);  { Sum all i inputs for normalization}
    for j:= 0 to NO do begin
      Sum:=0;
      for i:=0 to NI do
         if CI[i] then Sum:=Sum+W[i,j];   { Sum all i inputs for j-th unit  }
      CO[j]:=Sum/{Sqrt}(K*SumOfSquares)>=0;
      end;
    {No Biasing Neuron required on first layer}
end;

begin
  n:=Network;
  PropagateFirstLayer(Cells,HCells,Iput,n^.C,W);
  while n^.next <> NetTail do begin
    PropagateHiddenLayer(HCells,HCells,n^.C,n^.next^.C,n^.next^.W);
    n:=n^.next;
    end;
  PropagateHiddenLayer(HCells,7,n^.C,n^.Next^.C,n^.next^.W);
  for j:=0 to 7 do Oput[j]:=n^.next^.C[j];  {Copy first 8 bits of last vector}
end;


Procedure SetWeights;   {Back-Propagation Method}

var PairPtr         : Integer;          {Training Pair Index          }
    i,j             : Integer;          {Cell pointers                }
    Connected,                          {No weight adjustment required for current training pair}
    Adjusted        : Boolean;          {Weight adjustment required over this trial}
    Tries,                              {Attempts at Weight adjustment}
    GoodCount       : integer;          {Successful recalls           }
    Done            : Boolean;
    OldAcc          : real;
    n               : HiddenPtr;

  Procedure BackPropagate;
  var Delta,
      TempDelta : array[0..HCells] of LongInt;
      i,j       : integer;
      Target    : OutVector;
      Wdash     : HiddenMat;

    Procedure BackPropagateFirstLayer(NI,NO:integer;CI:Vector;var CO:HiddenVec;var W:Matrix);
    var i,j : integer;
    begin
      for i:= 0 to NO do begin          {Calculate new Delta}
        TempDelta[i]:=0;
        for j:= 0 to NO do
          TempDelta[i]:=TempDelta[i]+Delta[j]*Wdash[i,j];
        end;
      for j:= 0 to NO do
        for i:= 0 to NI do
          if CI[i] then W[i,j]:=W[i,j]+TempDelta[j];
    end;

    Procedure BackPropagateLastLayer(NI,NO:integer;CI:HiddenVec;CT:OutVector;CO:OutVector;var W:HiddenMat);
    var i,j : integer;                           { ^-Previous   ^-Target     ^-Result}
    begin
       for j:=NO+1 to NI do Delta[j]:=0;  {zero unused part of Delta}
       for j:=0 to NO do begin
         Delta[j]:= (Integer(CT[j])-Integer(CO[j])); {Calculate Delta for output}
         if Delta[j]<>0 then Connected:=False;       {Delta <> [0,0,0,0,0...0]}
         end;
       for j:=0 to NO do
         for i:=0 to NI do
           if CI[i] then W[i,j]:=W[i,j]+Delta[j];
    end;

  begin {BackPropagate}
    CharVec(char(AssocTable.Pair[PairPtr].Ascii),Target);
    n:=NetTail;
    Wdash:=n^.W;
    BackPropagateLastLayer(HCells,7,n^.prev^.C,Target,Oput,n^.W);
    n:=n^.prev;
    if Connected then n:=Network;       {Don't propagate zero errors}
    while n <> Network do begin         {Back-Propagate Hidden Layers}
      for i:= 0 to HCells do begin      {Calculate new Delta}
        TempDelta[i]:=0;
        for j:= 0 to HCells do
          TempDelta[i]:=TempDelta[i]+Delta[j]*Wdash[i,j];
        end;
      Delta:=TempDelta;
      Wdash:=n^.W;                      {Copy this matrix before modifying it}
      for j:= 0 to HCells do
        for i:= 0 to HCells do
          if n^.prev^.C[i] then n^.W[i,j]:=n^.W[i,j]+Delta[j];
      n:=n^.prev;
      end;
    if not Connected then BackPropagateFirstLayer(Cells,HCells,Iput,n^.C,W);
  end; {BackPropagate}

begin {SetWeights}
  Done:=False;
  with AssocTable do begin
      repeat
        OldAcc:=Acc;
        GoodCount:=0;
        Tries:=0;
        for PairPtr:=0 to LastPair do
          if not Done then begin
            Adjusted:=False;
            repeat
              if KeyPressed then if ReadKey=' ' then begin
                Watch:=not Watch;
                DisplayWatch;
                end
              else Done:=True;
              Inc(Tries);
              Connected:=True;
              Iput:=Pair[PairPtr].Image;
              if NoiseLevel>0 then begin
                CorruptVector(Iput,NoiseLevel/100);
                if Watch then DisplayI;
                end;
              {ClearOutVector(Oput);}  {Only required if hysteresis present}
              if Watch then DisplayI;
              Propagate;
              DisplayO;
              BackPropagate;
              if not Connected then Adjusted:=True; {Weights were adjusted}
            until Connected or Done; {Weights are good for this association}
            if not Adjusted then begin beep(7);Inc(GoodCount);end;
            end;
          Acc:=100*(GoodCount)/(LastPair+1);
          DisplayAcc;
      until (Tries=LastPair+1) and (NoiseLevel=0) or Done ;{All associations are}
    end;                                   {recalled correctly or user gives up}
    if Done then begin                     {but continue if Noise hardening}
      Acc:=OldAcc;    {Restore Acc}
      DisplayAcc;
      end
end;
