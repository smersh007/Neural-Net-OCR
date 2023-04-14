program BAM;

{


           Neural Network Assosiative Memory experimentation utility
           ---------------------------------------------------------
                      by Michael R. Samerski

                      Commenced               21-08-88
                      Last modified           16-03-89

            Developed from 'A window into the brain', APC March 1988

Version 03.02
-------------
NOTES:
Software Modification Record:

V01.00
 Only one unit connects input to output.
 Fully passes input and output vectors until stable.
V03.00
 Thresholding is used
 Allows Saving of connection matrix to disk.
V03.01
 The first pass is from the last cursor position to the opposite side.
 Vector Inversion during editing available

 Same as V03.01 BUT:
   Character images can be inserted into input and output fields from disk
   Connection Matrix can be viewed in 3D
   Neuron firing speed is increased 171%       \__by replacing multiplies with
   Weight computation speed is increased  33%  /  logic operations
}


Uses
  Dos,
  Graph,
  Crt;


const
     Threshold   = 0;
     MaxImages   = 255;
     Elements    = 99;
     ConSource   = 'SAVE.NET';
     ImageSource = 'CHARSET.IMG';

type
    textline     = string[80];
    filenametype = string[10];
    matrix       = array[0..Elements,0..Elements] of integer;
    vector       = array[0..Elements] of boolean;
    VectorTable  = array[0..MaxImages] of Vector;

var
  MatrixFile : file of matrix;
  VectorFile : file of VectorTable;
  ImageTable : VectorTable;
  ImagePtr   : Integer;
  grDriver   : integer;
  grMode     : integer;
  ErrCode    : integer;
  Inf        : TextSettingsType;
  Key        : char;
  X,Y,
  i,j        : integer;
  Iput,Oput  : vector;
  con        : matrix;
  Sum        : Integer;
  N,Stable   : Boolean;

PROCEDURE error(err:textline);
begin
  SetTextStyle(SmallFont,HorizDir,4);
  OutTextXY(10,0,err);
  HALT;
end;

Procedure Wait;
begin
 repeat until keypressed
end;

FUNCTION exist(filename:filenametype):boolean;
var fil:file;
    IORes :Integer;
begin
  assign(fil,filename);
  {$I-}
  reset(fil);
  {$I+}
  IORes:=IOResult;
  exist:=(IORes=0);
end;

procedure ShadeRec(x,y:integer);
begin
  SetFillStyle(InterleaveFill,0);
  if x<10 then Bar3D(15*x+100,10*y+40,15*x+113,10*y+48,0, Topoff)
    else begin
    x:=x-10;Bar3D(15*x+350,10*y+40,15*x+363,10*y+48,0, Topoff);end;

end;

procedure SetRec(x,y:integer);
begin
  SetFillStyle(SolidFill,1);
  if x<10 then Bar3D(15*x+100,10*y+40,15*x+113,10*y+48,0, Topoff)
    else begin
    x:=x-10;Bar3D(15*x+350,10*y+40,15*x+363,10*y+48,0, Topoff);end;
end;


procedure ResetRec(x,y:integer);
begin
  SetFillStyle(EmptyFill,0);
  if x<10 then Bar3D(15*x+100,10*y+40,15*x+113,10*y+48,0, Topoff)
    else begin
    x:=x-10;Bar3D(15*x+350,10*y+40,15*x+363,10*y+48,0, Topoff);end;

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

Procedure LeftArrow;
begin
  line(290,91,310,91);
  line(290,91,295,86);
  line(290,91,295,96);
end;

Procedure RightArrow;
begin
  line(290,89,310,89);
  line(310,89,305,84);
  line(310,89,305,94);
end;

Procedure DrawScreen;
var y:integer;
begin
      Cleardevice;
      SetTextStyle(GothicFont,HorizDir,2);
      OuttextXY(230,155,'Neural Network');
      OuttextXY(150,175,'Bidirectional Associative Memory');
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
      OuttextXY(60,185,'V03.02');
      OuttextXY(460,185,'by Michael Samerski');
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

Procedure ClearVector(var Vector:vector);
var i:integer;
begin
   for i:= 0 to Elements do Vector[i]:=false; {Initialize arrays}
end;

Procedure InvertVector(var Vector:vector);
var i:integer;
begin
   for i:= 0 to Elements do Vector[i]:=not Vector[i]; {Initialize arrays}
end;

Procedure ClearMatrix(var Matrix:matrix);
var i,j:integer;
begin
    for i:= 0 to Elements do
      for j:= 0 to Elements do
        Matrix[i,j]:=0;
end;

Procedure Edit;

  procedure Up;
  begin
    RestoreRec(x,y);
    y:=y-1;
    ShadeRec(x,y);
  end;

  procedure Down;
  begin
     RestoreRec(x,y);
     y:=y+1;
     ShadeRec(x,y);
  end;

  procedure Left;
  begin
     restorerec(x,y);
     x:=x-1;
     shaderec(x,y);
  end;

  procedure Right;
  begin
     restorerec(x,y);
     x:=x+1;
     shaderec(x,y);
  end;

  procedure BigLeft;
  begin
     restorerec(x,y);
     x:=x-5;
     if x<0 then x:=0;
     shaderec(x,y);
  end;

  procedure BigRight;
  begin
     restorerec(x,y);
     x:=x+5;
     if x>19 then x:=19;
     shaderec(x,y);
  end;


var Done:boolean;

begin
   Done:=False;
   repeat
       repeat ShadeRec(x,y);Delay(70);RestoreRec(x,y);Delay(50); until keypressed;
       Key:=ReadKey;
       case Key of
          #0:begin
               Key:=ReadKey;                          { Function keys }
               case Key of
    {UP}         #72: if y <> 0  then Up;
    {LEFT}       #75: if x <> 0  then Left;
    {RIGHT}      #77: if x <> 19 then Right;
    {BIGLEFT}   #115: if x >  0  then BigLeft;
    {BIGRIGHT}  #116: if x <  19 then BigRight;
    {DOWN}       #80: if y <> 9  then Down;
    {F1}         #59: if x<10 then begin InvertVector(iput);DisplayI;end
    {F2}              else begin InvertVector(oput);DisplayO; end;
                 #60: if x<10 then begin ClearVector(iput);DisplayI;end
                      else begin ClearVector(oput);DisplayO; end;
                 end;
             end;
          ' ':Toggle(x,y);
   {ENTER}#13:Done:=True;
          else begin
                 ImagePtr:=Ord(Key);
                 if x<10 then begin Iput:=ImageTable[ImagePtr];DisplayI end
                       else begin Oput:=ImageTable[ImagePtr];DisplayO end
                 end;
          end;
    until Done;  {Quit Editor}
end;

Function BoolInt(X:boolean):Integer;
begin
     if X then BoolInt:=1
     else BoolInt:=0;
end;

Function BoolBipolar(X:boolean):Integer;
begin
     if X then BoolBipolar:=1
     else BoolBipolar:=-1;
end;

Function IntBool(X:Integer):Boolean;
begin
     if X>Threshold then IntBool:=True
     else if X<-Threshold then IntBool:=False
     else error('Bad call to function IntBool()');
end;

Procedure MatrixDisplay;

var x,y,u,v          :integer;
    z,Theta,Thi      :real;
    CosTheta,SinThi  :Real;

PROCEDURE translate;
begin
       z:=2*Con[x,y];
       u:=200+trunc(4.5*(x-y*CosTheta));
       v:=175-trunc(1.5*(z+y*SinThi));
end; { procedure translate }
begin
  ClearDevice;
  Theta:=pi/3;
  Thi  :=pi/3;
  CosTheta:=cos(Theta);
  SinThi:=sin(Thi);
  for x:= 0 to Elements do begin
  y:=0;
  translate;
  MoveTo(u,v);
     for y:= 0 to Elements do begin
       translate;
       LineTo(u,v);
       end
  end;
  for y:= 0 to Elements do begin
  x:=0;
  translate;
  MoveTo(u,v);
     for x:= 0 to Elements do begin
       translate;
       LineTo(u,v);
       end;
  end

end;

Procedure PassLtoR(var Done:boolean);
begin
   Done:=True;
   SetColor(Black);LeftArrow;
   SetColor(White);RightArrow;
   for j:= 0 to Elements do begin
      Sum:=0;
      for i:=0 to Elements do
         if Iput[i] then Sum:=Sum+con[i,j];
      if Abs(Sum)>Threshold then begin
         N:=IntBool(Sum);
         if oput[j] <> N then begin
            oput[j]:=N; {Fiddling with N saves one array access or IntBool call}
            Done:=False;
            RestoreRec(10 +(j div 10),j mod 10);
            end;
         end;
      end;
end;

Procedure PassRtoL(var Done:boolean);
begin
   Done:=True;
   SetColor(Black);RightArrow;
   SetColor(White);LeftArrow;
   for j:= 0 to Elements do begin
      Sum:=0;
      for i:=0 to Elements do
         if Oput[i] then Sum:=Sum+con[j,i];
      if Abs(Sum)>Threshold then begin
         N:=IntBool(Sum);
         if iput[j] <> N then begin
            iput[j]:=N; {Fiddling with N saves one array access or IntBool call}
            Done:=False;
            RestoreRec(j div 10,j mod 10);
            end;
         end;
      end;
end;

Procedure SetWeights;
begin
   for i:= 0 to Elements do
     for j:= 0 to Elements do
        if (Iput[i] xor Oput[j]) then Con[i,j]:=Con[i,j]-1
        else Con[i,j]:=Con[i,j]+1

{      Con[i,j]:=Con[i,j]+BoolBipolar(Iput[i])*BoolBipolar(Oput[j]);}
end;


BEGIN
  X:=0;Y:=0;
  nosound;
  grDriver := Detect;
  InitGraph(grDriver,grMode,'a:\');
  ErrCode := GraphResult;
  if ErrCode = grOk then begin
   ClearVector(Iput);
   ClearVector(Oput);
   ClearMatrix(Con);
   SetColor(White);
   DrawScreen;
   repeat
     key:=upcase(readkey);
     Case Key of
     'L':begin {Learn mode}
         X:=5;Y:=5;
         Edit;
         Setweights;
         sound(2000);delay(50);nosound;
         end;
     'T':begin {Test mode}
         Edit;
         Stable:=False;
         if x<10 then PassLtoR(Stable);
         while not Stable do begin
             PassRtoL(Stable);
             if not Stable then PassLtoR(Stable)
             end;
         sound(2000);delay(50);nosound;
         end;
     'I':begin {Image menu}
         repeat
           Key:=upcase(readkey);
         until Key in ['S','L','E'];
         Case Key of
          'L':if exist(ImageSource) then error('File "'+ImageSource+'" not found')
              else begin
               assign(Vectorfile,ImageSource);
               reset(VectorFile);
               read(Vectorfile,ImageTable);
               close(Vectorfile);
               end;
          'S':begin
              assign(VectorFile,ImageSource);
              rewrite(VectorFile);
              write(VectorFile,ImageTable);
              close(VectorFile);
              end;
          'E':Begin
              Edit;
              if x<10 then ImageTable[ImagePtr]:=Iput
                else ImageTable[ImagePtr]:=Oput
              end;
           end;
        end;
    'C':begin {Connection menu}
        repeat
           key:=upcase(readkey);
        until key in ['S','L','D'];
        Case Key of
         'L':if exist(ConSource) then error('File "'+ConSource+'" not found')
             else begin
               assign(matrixfile,ConSource);  {Load connection matrix}
               reset(matrixfile);
               read(matrixfile,con);
               end;
         'D':begin
             MatrixDisplay;
             Wait;
             ClearDevice;
             DrawScreen;
             end;
         'S':begin
             assign(matrixfile,ConSource);
             rewrite(matrixfile);
             write(matrixfile,con);
             close(matrixfile);
             end;
         end;
        end;
     end;
   until Key=#27;    {<ESC> = Exit Program}
   CloseGraph;
   end
 else
    Writeln('Graphics error:', GraphErrorMsg(ErrCode));
end.
