program BAM;

{


           Neural Network Assosiative Memory experimentation utility
           ---------------------------------------------------------
                      by Michael R. Samerski

                      Commenced               21-08-88
                      Last modified           16-03-89

            Developed from 'A window into the brain', APC March 1988

Version 03.03
-------------
NOTES:
Software Modification record:

V01.00
 Only one unit connects input to output.
 Fully passes input and output vectors until stable.
V03.00
 Thresholding is used
 Allows Saving of connection matrix to disk.
V03.01
 The first pass is from the last cursor position to the opposite side.
 Vector Inversion during editing available
V03.02
 Character images can be inserted into input and output fields from disk
 Connection Matrix can be viewed in 3D
 Neuron firing speed is increased 171%       \__by replacing multiplies with
 Weight computation speed is increased  33%  /  logic operations

 Same as V03.02 BUT:
    System is under menu control.
    Vector Corruption during editing available.

}


Uses
  Dos,
  Graph,
  Crt;

const MaxOptions = 7;
      MenuWidth   = 20;

type MenuString  = string[MenuWidth];
     MenuType    = array[0..MaxOptions] of MenuString;

const
   menu0:MenuType=
          (#7,
          'Main Menu',
          'Connections..',
          'Images..     ',
          'Learn        ',
          'Test         ',
          'thresHold    ',
          'Quit         ');
   menuC:MenuType=
          (#6,
          'Connection Menu',
          'Load         ',
          'Save         ',
          'Display      ',
          'Reset        ',
          'ESCape       ','');
   menuI:MenuType=
          (#5,
          'Image Menu   ',
          'Load         ',
          'Save         ',
          'Edit         ',
          'ESCape       ','','');
   menuH:MenuType=
          (#4,
          'Set Threshold',
          '^            ',
          'v            ',
          'RET: Done    ','','','');
   menuE:MenuType=
          (#6,
          'Editing Menu ',
          'F1 : Invert ',
          'F2 : Clear  ',
          'F3 : Corrupt 10%',
          'RET: Done   ',
          'ESC: Abort   ','');
   menuW:MenuType=
          (#1,
          'Please Wait ...',
          '','','','','','');


const
     MaxImages   = 255;
     Elements    = 99;
     ConSource   = 'SAVE.NET';
     ImageSource = 'CHARSET.IMG';
     PathToDriver= 'A:\BGI';

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
  EdExCode   : Integer;
  ImagePtr   : Integer;
  grDriver   : integer;
  grMode     : integer;
  ErrCode    : integer;
  Inf        : TextSettingsType;
  Key,Bin    : char;
  X,Y,
  i,j        : integer;
  Iput,Oput  : vector;
  con        : matrix;
  Sum        : Integer;
  N,Stable   : Boolean;
  Threshold  : Integer;



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

Procedure Menu(Menu:MenuType);

Var OldPort      : ViewPortType;
    i            : Integer;
    x1,y1,x2,y2  : Integer;

begin
   GetViewSettings(OldPort);
   x1:=520;
   y1:=50;
   x2:=5*MenuWidth;
   y2:=MaxOptions*10;
   SetViewPort(x1,y1,x1+x2,y1+y2,Clipoff);
   ClearViewPort;
   y2:=ord(Menu[0,1])*10;
   SetViewPort(x1,y1,x1+x2,y1+y2,Clipoff);
   rectangle(0,0,x2,y2);
   Line(0,10,x2,10);
   SetTextStyle(SmallFont,HorizDir,4);
   for i:=1 to ord(Menu[0,1]) do
     OuttextXY(3,10*(i-1),Menu[i]);
   With OldPort do SetViewPort(x1,y1,x2,y2,Clip);
end;

FUNCTION exist(filename:filenametype):boolean;
var fil:file;
begin
  assign(fil,filename);
  {$I-}
  reset(fil);
  {$I+}
  exist:=(ioresult=0);
{! 1. IORe^sult now returns different values corresponding to DOS error codes.}
end;

procedure ShadeRec(x,y:integer);
begin
  SetFillStyle(HatchFill,0);
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

Procedure DisplayThreshold;

Var OldPort          : ViewPortType;
    i                : Integer;
    x,y,Width,Hight  : Integer;
    ThreshString     : string[3];

begin
   GetViewSettings(OldPort);
   x:=520;
   y:=150;
   Width:=52;
   Hight:=22;
   Str(Threshold,Threshstring);
   SetViewPort(x,y,x+Width,y+Hight,Clipoff);
   ClearViewPort;
   SetViewPort(x,y,x+Width,y+Hight,Clipoff);
   rectangle(0,0,Width,Hight);
   Line(0,10,Width,10);
   SetTextStyle(SmallFont,HorizDir,4);
   OutTextXY(3,1,'Theshold');
   OutTextXY(Width div 2,11,ThreshString);
   With OldPort do SetViewPort(x1,y1,x2,y2,Clip);
end;


Procedure DrawScreen;
var y:integer;
begin
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
      OuttextXY(60,185,'V03.03');
      DisplayThreshold;
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

Procedure CorruptVector(var Vector:vector);
var i:integer;
begin
   for i:= 0 to Elements do
     if Random>0.9 then Vector[i]:=not Vector[i]; {Initialize arrays}
end;


Procedure ClearMatrix(var Matrix:matrix);
var i,j:integer;
begin
    for i:= 0 to Elements do
      for j:= 0 to Elements do
        Matrix[i,j]:=0;
end;

Procedure Edit(var ExitCode:integer);

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
    ISave,OSave:Vector;

begin
   ExitCode:=0;
   Menu(MenuE);
   ISave:=Iput;
   OSave:=Oput;
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
                      else begin InvertVector(oput);DisplayO; end;
    {F2}         #60: if x<10 then begin ClearVector(iput);DisplayI;end
                      else begin ClearVector(oput);DisplayO; end;
    {F3}         #61: if x<10 then begin CorruptVector(iput);DisplayI;end
                      else begin CorruptVector(oput);DisplayO; end;
                 end;
             end;
          ' ':Toggle(x,y);
   {ENTER}#13:Done:=True;
   {ESC}  #27:begin
                   Done:=True;
                   ExitCode:=1;   {Abort Code}
                   Iput:=Isave;
                   Oput:=OSave;
                   DisplayI;
                   DisplayO;
                   end;
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
  Threshold:=0;
  nosound;
  grDriver := Detect;
  InitGraph(grDriver,grMode,PathToDriver);
  ErrCode := GraphResult;
  if ErrCode = grOk then begin
   ClearVector(Iput);
   ClearVector(Oput);
   ClearMatrix(Con);
   SetColor(White);
   DrawScreen;
   repeat
     Menu(Menu0);
     key:=upcase(readkey);
     Case Key of
       #0 :Bin:=ReadKey;
       'L':begin                     {Learn mode}
           X:=5;Y:=5;
           Edit(EdExCode);
           if EdExCode=0 then begin
              Menu(MenuW);
              Setweights;
              end;
           sound(2000);delay(50);nosound;
           end;
       'T':begin                     {Test mode}
           Edit(EdExCode);
           if EdExCode=0 then begin
              Menu(MenuW);
              Stable:=False;
              if x<10 then PassLtoR(Stable);
              while not Stable do begin
                 PassRtoL(Stable);
                 if not Stable then PassLtoR(Stable)
                 end;
              sound(2000);delay(50);nosound;
              end;
           end;
       'I':begin {Image menu}
           repeat
             Menu(MenuI);
             Key:=upcase(readkey);
             Case Key of
               'L':if exist(ImageSource) then error('File "'+ImageSource+'" not found')
                   else begin
                   Menu(MenuW);
                   assign(Vectorfile,ImageSource);
                   reset(VectorFile);
                   read(Vectorfile,ImageTable);
                   close(Vectorfile);
                   end;
               'S':begin
                   Menu(MenuW);
                   assign(VectorFile,ImageSource);
                   rewrite(VectorFile);
                   write(VectorFile,ImageTable);
                   close(VectorFile);
                   end;
               'E':Begin
                   Edit(EdExCode);
                   if EdExCode=0 then
                      if x<10 then ImageTable[ImagePtr]:=Iput
                        else ImageTable[ImagePtr]:=Oput
                   end;
               end;
        until Key =#27;
        end;
    'C':begin {Connection menu}
        repeat
          Menu(MenuC);
          key:=upcase(readkey);
          Case Key of
            'L':if exist(ConSource) then error('File "'+ConSource+'" not found')
                else begin
                  Menu(MenuW);
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
                Menu(MenuW);
                assign(matrixfile,ConSource);
                rewrite(matrixfile);
                write(matrixfile,con);
                close(matrixfile);
                end;
            'R':Begin Menu(MenuW);ClearMatrix(Con);end;
            end;
        until key=#27;
        end;
    'H':begin
        Menu(MenuH);
        repeat
             DisplayThreshold;
             Key:=ReadKey;
             if Key=#0 then begin
                Key:=ReadKey;
   {UPARROW}    if Key=#72 then Threshold:=Threshold +1;
   {DNARROW}    if Key=#80 then if Threshold<>0 then Threshold:=Threshold -1;
                end;
        until Key=#13  {RETURN}
        end;
    end;
   until Key='Q';    {Exit Program}
   CloseGraph;
   end
 else
    Writeln('Graphics error:', GraphErrorMsg(ErrCode));
end.
