Procedure Propagate;     {Forward}
var
  SumOfSquares : integer;
  Sum          : Integer;                    {Activation Level       }
begin
    SumOfSquares:=1;
    if Normalization then
      for i:=0 to Cells do
        if Iput[i] then Inc(SumOfSquares); { Sum all i inputs for normalization}
    for j:= 0 to Cells do begin
      Sum:=0;
      for i:=0 to Cells do
         if Iput[i] then Sum:=Sum+W[i,j];  { Sum all i inputs for j-th unit  }
      Oput[j]:=Sum/{Sqrt}(SumOfSquares)>QT;{ Thesholding occurs here         }
{     RestoreRec(10 +(j div 10),j mod 10);}
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
    OldAcc          : Real;
begin
  with AssocTable do begin
      repeat
        OldAcc:=Acc;
        GoodCount:=0;
        Tries:=0;
        for PairPtr:=0 to LastPair do
          if not Done Then  begin
            Adjusted:=False;
            repeat
              if KeyPressed then if ReadKey=' ' then begin
                Watch:=not Watch;
                DisplayWatch;
                end
              else Done:=True;
              Inc(Tries);
              Connected:=True;
              Iput:=Pair[2*PairPtr];
              If NoiseLevel > 0 Then CorruptVector(Iput,NoiseLevel/100);
              Propagate;
              if Watch then begin DisplayI; DisplayO;end;
              for i:= 0 to Cells do
                for j:= 0 to Cells do
                  if Iput[i] then
                     if Pair[2*PairPtr+1,j] xor Oput[j] then begin
                        Connected:=False;
                        if Oput[j] then Dec(W[i,j],dw) else Inc(W[i,j],dw);
                        end;
              if not Connected then Adjusted:=True; {Weights were adjusted}
            until Connected or Done; {Weights are good for this association}
            if not Adjusted then begin beep(7);Inc(GoodCount);end;
            end;
        Acc:=100*(GoodCount)/(LastPair+1);
        DisplayAcc;
      until (Tries=LastPair+1) and (NoiseLevel=0) or Done; {All associations are                }
    end;                                {recalled correctly or user gives up}
    if Done then begin                  {but continue if noise hardening}
      Acc:=OldAcc;    {Restore Acc}
      DisplayAcc;
      end
end;