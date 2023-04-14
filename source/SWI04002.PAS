
Procedure MakeRec(x,y:integer;Fill,Color:word);
Begin
  SetFillstyle(Fill,Color);
  if x<10 then Bar3D(15*x+100,10*y+40,15*x+113,10*y+48,0, Topoff)
    else begin x:=x-10;Bar3D(15*x+350,10*y+40,15*x+363,10*y+48,0, Topoff);end;
end;

procedure ShadeRec(x,y:integer);
begin
  MakeRec(x,y,InterleaveFill,FlashColor);
end;

procedure SetRec(x,y:integer);
begin
  MakeRec(x,y,SolidFill,OnColor);
end;

procedure ResetRec(x,y:integer);
begin
  MakeRec(x,y,EmptyFill,OffColor);
end;

Function OneD(x,y:integer):integer;
begin
  OneD:=10*x+y;
end;

procedure RestoreRec(x,y:integer);
begin
  if x<10 then if iput[OneD(x,y)] then SetRec(x,y)
                  else ResetRec(x,y)
    else if oput[OneD(x-10,y)] then SetRec(x,y)
                  else ResetRec(x,y)
end;

procedure Toggle(x,y:integer);
begin
  sound(1000);delay(10);nosound;
  if x<10 then begin
     iput[OneD(x,y)]:= not iput[OneD(x,y)];
     if iput[OneD(x,y)] then SetRec(x,y) else ResetRec(x,y) end
    else begin
     oput[OneD(x-10,y)]:= not oput[OneD(x-10,y)];
     if oput[OneD(x-10,y)] then SetRec(x,y) else ResetRec(x,y) end
end;

Procedure DisplayI;
var i,j:integer;
begin
      for j:= 0 to 9 do
        for i:= 0 to 9 do
            RestoreRec(i,j);
end;

Procedure DisplayO;
var i,j:integer;
begin
      for j:= 0 to 9 do
        for i:= 10 to 19 do
            RestoreRec(i,j);
end;
Procedure ActiveDetect;     {Displays Neurons whos weights are   }
begin                       {greater than the Threshold        }
   ClearVector(Iput);
   ClearVector(Oput);
   for j:= 0 to Cells do
      for i:=0 to Cells do
         if W[i,j]>QT then begin
            Iput[i]:=True;
            Oput[j]:=True;
            end;
   DisplayI;
   DisplayO;
end;

Procedure InhibitiveDetect; {Displays Neurons whos weights are   }
begin                       {less than the negative Threshold  }
   ClearVector(Iput);
   ClearVector(Oput);
   for j:= 0 to Cells do
      for i:=0 to Cells do
         if W[i,j]<-QT then begin
            Iput[i]:=True;
            Oput[j]:=True;
            end;
   DisplayI;
   DisplayO;
end;

Procedure RightArrow;
begin
  line(290,89,310,89);
  line(310,89,305,84);
  line(310,89,305,94);
end;
