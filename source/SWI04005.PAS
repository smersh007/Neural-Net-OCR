Procedure ClearVector(var Vector:vector);
var i:integer;
begin
   for i:= 0 to Cells do Vector[i]:=false; {Initialize arrays}
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
      for j:= 0 to Cells do
        Matrix[i,j]:=0;
end;

Procedure RandomizeMatrix(var Matrix:matrix);
const Max:integer = 2;
var i,j  :integer;
    RNum :real;
begin
    for i:= 0 to Cells do
      for j:= 0 to Cells do begin
        RNum:=random;
        if RNum>0.67 then Matrix[i,j]:=1
        else If RNum>0.33 then Matrix[i,j]:=0
        else Matrix[i,j]:=-1;
        end;
end;


function CosAngle(Vec1,Vec2:Vector):Real; {Returns cosine of angle between two vectors}
var i,j           : integer;
    SumOfSquares1,
    SumOfSquares2,
    DotProduct    : Integer;
Begin
  SumOfSquares1:=0;
  SumOfSquares2:=0;
  DotProduct:=0;
  for i:=0 to cells do begin
    if Vec1[i] then SumOfSquares1:=SumOfSquares1+1;
    if Vec2[i] then SumOfSquares2:=SumOfSquares2+1;
    if (Vec1[i] and Vec2[i]) then DotProduct:=DotProduct+1
    end;
  CosAngle:=DotProduct/sqrt(SumofSquares1*SumOfSquares2);

end;

