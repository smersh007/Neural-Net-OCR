Procedure ClearVector(var Vector:vector);
var i:integer;
begin
   for i:= 0 to Cells do Vector[i]:=false; {Initialize arrays}
end;

Procedure ClearOutVector(var Vector:OutVector);
var i:integer;
begin
   for i:= 0 to 7 do Vector[i]:=false; {Initialize arrays}
end;

Procedure InvertVector(var Vector:vector);
var i:integer;
begin
   for i:= 0 to Cells do Vector[i]:=not Vector[i]; {Initialize arrays}
end;

Procedure CorruptVector(var Vector:vector;Prob:real);
{Flip Prob% of the units    (0<Prob<1)    }
var i:integer;
begin
   for i:= 0 to Cells do
     if Random<Prob then Vector[i]:=not Vector[i]; {Initialize arrays}
end;

Procedure ZeroMatrix(var Matrix:matrix);
var i,j:integer;
begin
    for i:= 0 to Cells do
      for j:= 0 to 7 do
        Matrix[i,j]:=0;
end;

Procedure RandomizeMatrix(var Matrix:matrix);
var i,j  :integer;
    RNum :real;
begin
    for i:= 0 to Cells do
      for j:= 0 to 7 do begin
        RNum:=random;
        if RNum>0.67 then Matrix[i,j]:=1
        else If RNum>0.33 then Matrix[i,j]:=0
        else Matrix[i,j]:=-1;
        end;
end;

Procedure CharVec(ch:Char;var OutVec:OutVector);
var i    : integer;
    Mask : integer;
begin
  Mask:=$01;
  for i:=0 to 7 do begin
    OutVec[i]:=((Lo(ord(ch)) and Mask)=Mask);
    Mask:=Mask shl 1;
    end;
end;

Function VecByte(Vec:OutVector):byte;
var i          : integer;
    R          : byte;
    PowerOfTwo : integer;
begin
  R:=0;
  PowerOfTwo:=1;
  for i:=0 to 7 do begin
    if Vec[i] then R:=R+PowerOfTwo;
    PowerOfTwo:=PowerOfTwo shl 1;
    end;
  VecByte:=R;
end;

