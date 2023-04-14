Procedure DrawScreen;
var y:integer;
begin
      SetColor(White);
      SetTextStyle(GothicFont,HorizDir,2);
      OuttextXY(80,175,'Neural Network Optical Character Recognition');
      SetTextStyle(TriplexFont,HorizDir,2);
      OuttextXY(150,10,'Input');
      DisplayI;
      for y:=0 to 9 do
          line(250,45+10*y,280,90);
      Circle(300,90,23);
      for y:=0 to 7 do
          line(350,55+10*y,320,90);
      for y:=0 to 7 do
          line(365,55+10*y,400,82+2*y);
      Bar3D(400,110,450,70,2,TopOn);
      OuttextXY(390,10,'Output');
      DisplayO;
      SetTextStyle(SmallFont,HorizDir,4);
      OuttextXY(10,185,Version);
      OuttextXY(500,185,'by Michael Samerski');
end;
