Procedure DrawScreen;
var y:integer;
begin
      SetColor(White);
      SetTextStyle(GothicFont,HorizDir,2);
{      OuttextXY(230,155,'Neural Network');}
      OuttextXY(150,175,'Unidirectional Associative Memory');
      SetTextStyle(TriplexFont,HorizDir,2);
      OuttextXY(150,10,'Input');
      DisplayI;
      for y:=0 to 9 do
          line(250,45+10*y,280,90);
      Circle(300,90,23);
      for y:=0 to 9 do
          line(350,45+10*y,320,90);
      OuttextXY(390,10,'Output');
      DisplayO;
      SetTextStyle(SmallFont,HorizDir,4);
      DisplayQT;
      OuttextXY(60,185,Version);
      OuttextXY(480,185,'by Michael Samerski');
end;
