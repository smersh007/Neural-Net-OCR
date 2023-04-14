Function BitSet(B:byte;i:integer):Boolean;
var k    : integer;
    Mask : integer;

begin
 Mask:=$01;
 for k:=0 to i-1 do Mask:=Mask shl 1;
 BitSet:=((B and Mask) = Mask);
end;

Procedure Propagate;     {Forward}
var
  SumOfSquares : integer;
  Sum          : Real;                    {Activation Level       }
  i,j          : integer;
begin
    SumOfSquares:=1;
    if Normalization then
      for i:=0 to Cells do
        if Iput[i] then Inc(SumOfSquares);{ Sum all i inputs for normalization}
    for j:= 0 to 7 do begin
      Sum:=0;
      for i:=0 to Cells do
         if Iput[i] then Sum:=Sum+W[i,j];  { Sum all i inputs for j-th unit  }
      Oput[j]:=Sum/{Sqrt}(SumOfSquares)>QT;{ Thesholding occurs here         }
      end;
end;


Procedure SetWeights;   {Delta Method}

var PairPtr         : Integer;          {Training Pair Index          }
    i,j             : Integer;          {Cell pointers                }
    Connected,                          {No weight adjustment required for current training pair}
    Adjusted        : Boolean;          {Weight adjustment required over this trial}
    Tries,                              {Attempts at Weight adjustment}
    GoodCount       : integer;          {Successful recalls           }
    Done            : Boolean;
    OldAcc          : real;

begin
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
              if NoiseLevel>0 then CorruptVector(Iput,NoiseLevel/100);
              Propagate;
              if Watch then DisplayI; {DisplayI is too slow to watch}
              DisplayO;               {This is so fast we can watch it!}
              for i:= 0 to Cells do   {The Delta Rule begins here}
                for j:= 0 to 7 do
                  if Iput[i] then                            {detect the error}
                     if BitSet(Pair[PairPtr].Ascii,j) xor Oput[j] then begin
                        Connected:=False;     {Flag that a correction was made}
                        if Oput[j] then Dec(W[i,j],dw)    {Make the correction}
                          else Inc(W[i,j],dw);
                        end;
              if not Connected then Adjusted:=True; {Weights were adjusted}
            until Connected or Done; {Weights are good for this association}
            if not Adjusted then begin beep(7);Inc(GoodCount);end;
            end;
          Acc:=100*(GoodCount)/(LastPair+1);
          DisplayAcc;
          until (Tries=LastPair+1) and (NoiseLevel=0) or Done;{All associations are recalled}
    end;                                   {correctly or user gives up   }
    if Done then begin                     {but continue if noise hardening}
      Acc:=OldAcc;    {Restore Acc}
      DisplayAcc;
      end
end;
