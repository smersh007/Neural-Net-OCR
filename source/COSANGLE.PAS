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