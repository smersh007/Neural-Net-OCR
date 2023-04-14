Function Exist(FileName:FileNameType):Boolean;
var Fil:file;
    IORes:integer;
begin
  Assign(Fil,Filename);
  {$I-}
  Reset(Fil);
  {$I+}
  IORes:=IOResult;
  Exist:=(IOResult=0);
end;

Procedure Beep(F:real);
begin
  sound(trunc(1000*F));delay(50);nosound;
end;

Procedure WaitForKey(var Key:char);
begin
 repeat until keypressed;
 Key:=ReadKey;
end;

Procedure Attention(Contents:AttnString; var Key:Char);

Var OldPort      : ViewPortType;
    x1,y1,x2,y2  : Integer;
    BitMap       : Pointer;
    WindowSize   : word;

begin
   Beep(2);
   GetViewSettings(OldPort);
   SetTextStyle(SmallFont,HorizDir,4);
   x2:=TextWidth(Contents)+2;
   y2:=DialogHeight*10;
   x1:=600-x2-3*MenuSP;
   y1:=20+15*MenuSP;
   SetViewPort(x1,y1,x1+x2,y1+y2,ClipOn);
   WindowSize:=ImageSize(0,0,x2,y2);
   GetMem(BitMap,WindowSize);
   GetImage(0,0,x2,y2,BitMap^);
   ClearViewPort;
   rectangle(0,0,x2,y2);
   Line(0,10,x2,10);
   OuttextXY((x2-TextWidth('Attention:')) div 2,0,'Attention:');
   OuttextXY(2,10,Contents);
   WaitForKey(Key);
   PutImage(0,0,BitMap^,Normalput);
   FreeMem(BitMap,WindowSize);
   With OldPort do SetViewPort(x1,y1,x2,y2,Clip);
end;

Procedure DisplayBox(Contents:Displaystring); {General Output Box}

 Var OldPort          : ViewPortType;
     i                : Integer;
     x,y,Width,Height : Integer;

begin
      GetViewSettings(OldPort);
      SetTextStyle(SmallFont,HorizDir,4);
      x:=50;
      y:=150;
      Width:=TextWidth(Contents)+2;
      Height:=22;
      SetViewPort(x,y,x+Width,y+Height,ClipOn);
      ClearViewPort;
      rectangle(0,0,Width,Height);
      Line(0,10,Width,10);
      OutTextXY((Width-TextWidth('Notes:')) div 2,1,'Notes:');
      OutTextXY(2,11,Contents);
      With OldPort do SetViewPort(x1,y1,x2,y2,Clip);
end;

PROCEDURE error(err:textline);
begin
  Beep(5);Beep(4);Beep(3);
  Attention('Software Error:'+Err+', NNOCR terminated',bin);
  HALT;
end;

Procedure HeapOverflow;
begin
  Error('Network too big');
end;

Procedure DisplayData(X,Y:Integer;Title:TitleString;Value:ValueString);

Var OldPort : ViewPortType;

Const
    Width  = 60;
    Height = 25;

begin
      GetViewSettings(OldPort);
      SetViewPort(x,y,x+Width,y+Height,ClipOn);
      ClearViewPort;
      rectangle(0,0,Width,Height);
      Line(0,11,Width,11);
      SetTextStyle(SmallFont,HorizDir,4);
      OutTextXY((Width-TextWidth(Title)) div 2,0,Title);
      OutTextXY((Width-TextWidth(Value)) div 2,12,Value);
      With OldPort do SetViewPort(x1,y1,x2,y2,Clip);
end;

Procedure DisplayWatch;
begin
      if Watch then DisplayData(240,145,'Watch','On')
        else DisplayData(240,145,'Watch','Off')
end;

Procedure DisplayNormalization;
begin
      if Normalization then DisplayData(320,145,'Normalize','On')
        else DisplayData(320,145,'Normalize','Off')
end;

Procedure DisplayAcc;
Var Value : ValueString;

begin
      Str(Acc:4:1,Value);
      if Acc<=100 then DisplayData(400,145,'Accuracy',Value+'%')
        else DisplayData(400,145,'Accuracy','?')
end;

Procedure DisplayNoise;
Var Value : ValueString;

begin
      Str(NoiseLevel,Value);
      DisplayData(160,145,'Noise',Value+'%')
end;


Procedure Displaydw;
Var Value:ValueString;

begin
      Str(dw,Value);
      DisplayData(480,145,'dw',Value)
end;

Procedure DisplayQT;
Var Value:ValueString;

begin
      Str(QT,Value);
      DisplayData(560,145,'Threshold',Value)
end;


Function Sure:Boolean;
var Key:char;
begin
 repeat
   Attention('Are You Sure? (Y/N)',Key);
 until Upcase(Key) in ['Y','N'];
 if Upcase(Key)='Y' then Sure:=True
 else if Upcase(Key)='N' then Sure:=False;
end;
