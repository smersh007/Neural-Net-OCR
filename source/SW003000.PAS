program BAM;

{


           Neural Network Assosiative Memory experimentation utility
           ---------------------------------------------------------
                      by Michael R. Samerski

                      Commenced               21-08-88
                      Last modified           09-03-89

            Developed from 'A window into the brain', APC March 1988

Version 03.00
-------------
NOTES:
 Only one unit connects input to output.
 Fully passes input and output vectors until stable.
 Same as V01.00 BUT:
   Thresholding is used.
   Allows Saving of connection matrix to disk.
}


Uses
  Dos,
  Graph,
  Crt;

type
    textline     = string[80];
    filenametype = string[10];
    matrix       = array[0..99,0..99] of integer;
    vector       = array[0..99] of boolean;

var
  matrixfile : file of matrix;
  grDriver   : integer;
  grMode     : integer;
  ErrCode    : integer;
  Inf        : TextSettingsType;
  Key        : char;
  X,Y,
  i,j        : integer;
  iput,oput  : vector;
  con        : matrix;
  Sum        : Integer;
  FirstPass,
  N,Stable   : Boolean;

const
     Threshold = 10;
     source   = 'save.net';

PROCEDURE error(err:textline);
begin
  SetTextStyle(SmallFont,HorizDir,4);
  OutTextXY(10,0,err);
  HALT;
end;

FUNCTION exist(filename:filenametype):boolean;
var fil:file;
    IORes:Integer;
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

Procedure Setup;
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
      OuttextXY(60,185,'V03.00');
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

Procedure ClearI;
var i:integer;
begin
      for i:= 0 to 99 do
         iput[i]:=false;           {Initialize arrays}
end;

Procedure ClearO;
var i:integer;
begin
      for i:= 0 to 99 do
         oput[i]:=false;
end;

Procedure ClearCon;
var i,j:integer;
begin
    for i:= 0 to 99 do
      for j:= 0 to 99 do
        con[i,j]:=0;
end;

Procedure Edit;

var Done:boolean;

begin
   Done:=False;
   repeat
       repeat ShadeRec(x,y);Delay(50);RestoreRec(x,y);Delay(50); until keypressed;
       Key:=ReadKey;
       case upcase(Key) of
          #0:begin
               Key:=ReadKey;                          { Function keys }
               case Key of
                 #72: if y <> 0 then Up;                      { Up    }
                 #75: if x <> 0 then Left;                    { Left  }
                 #77: if x <> 19 then Right;                  { Right }
                 #80: if y <> 9 then Down;                    { Down  }
                 end;
             end;
          ' ':Toggle(x,y);
          'C':if x<10 then begin ClearI;DisplayI; end
                      else begin ClearO;DisplayO; end;
          #13:Done:=True;                                  { Enter }
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

BEGIN
  X:=0;Y:=0;
  nosound;
  grDriver := Detect;
  InitGraph(grDriver,grMode,'a:\bgi');
  ErrCode := GraphResult;
  if ErrCode = grOk then begin
   ClearI;
   ClearO;
   ClearCon;
   SetColor(1);
   Setup;
   repeat
     key:=upcase(readkey);
     if key ='L' then begin {Learn mode}
       X:=5;Y:=5;
       Edit;
       for i:= 0 to 99 do   {Store Connections}
        for j:= 0 to 99 do
           con[i,j]:=con[i,j]+((BoolInt(iput[i]) shl 1)-1)*((BoolInt(oput[j]) shl 1)-1);
       end
     else if key ='T' then begin {Test mode}
        Edit;
        FirstPass:=true;
        Repeat
        SetColor(0);LeftArrow;
        SetColor(1);RightArrow;
          Stable:=True;
            for j:= 0 to 99 do begin
              Sum:=0;
              for i:=0 to 99 do
                  Sum:=Sum+BoolInt(iput[i])*con[i,j];
              if Abs(Sum)>Threshold then begin
                 N:=IntBool(Sum);
                 if oput[j] <> N then begin
                   oput[j]:=N; {Fiddling with N saves one array access or IntBool call}
                   Stable:=False;
                   RestoreRec(10 +(j div 10),j mod 10);
                   end;
                 end;
              end;
         If FirstPass or not Stable then Begin
             SetColor(0);RightArrow;
             SetColor(1);LeftArrow;
             for j:= 0 to 99 do begin
               Sum:=0;
               for i:= 0 to 99 do
                 Sum:=Sum+BoolInt(oput[i])*con[j,i];
               if Abs(Sum)>Threshold then begin
                  N:=IntBool(Sum);
                  if iput[j] <> N then begin
                    iput[j]:=N; {Fiddling with N saves one array access or IntBool call}
                    Stable:=False;
                    RestoreRec(j div 10,j mod 10);
                    end;
                  end;
               end;
          end;
         FirstPass:=false;
      until Stable or keypressed;
      sound(1000);delay(100);nosound;
      end
    else if key ='F' then begin {File menu}
      repeat
         key:=upcase(readkey);
      until key in ['S','L'];
      if key='L' then
        if exist(source) then error('File "'+source+'" not found')
        else begin
          assign(matrixfile,source);  {Load connection matrix}
          reset(matrixfile);
          read(matrixfile,con);
          end
      else if key='S' then {Save connection matrix}
          assign(matrixfile,source);
          rewrite(matrixfile);
          write(matrixfile,con);
          close(matrixfile);
          end;
    until key=#27;    {<ESC> = Exit Program}
   CloseGraph;
   end
 else
    Writeln('Graphics error:', GraphErrorMsg(ErrCode));
end.
