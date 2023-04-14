program BAM;

{


           Neural Network Assosiative Memory experimentation utility
           ---------------------------------------------------------
                      by Michael R. Samerski  21-8-88

            Developed from 'A window into the brain', APC March 1988

Version 02.00
-------------
NOTES:
Software Modification record:

 Same as V01.00
 BUT:
  Randomly passes input and output vectors until keypressed

}

Uses
  Dos,
  Graph,
  Crt;

type
    textline=string[80];
var
  grDriver : integer;
  grMode   : integer;
  ErrCode  : integer;
  Inf      : TextSettingsType;
  Key      : char;
  X,Y,
  i,j      : integer;
  iput,oput: array[0..99] of boolean;
  con      : array[0..99,0..99] of integer;
  Sum      : Integer;
  FirstPass,
  N,Stable : Boolean;

PROCEDURE error(err:textline);
begin
  OutTextXY(10,10,err);
  HALT;
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


Procedure Setup;
var i,j:integer;
begin
      Cleardevice;
      SetTextStyle(GothicFont,HorizDir,2);
      OuttextXY(230,155,'Neural Network');
      OuttextXY(150,175,'Bidirectional Associative Memory');
      OuttextXY(150,10,'Input');
      OuttextXY(400,10,'Output');
      SetTextStyle(SmallFont,HorizDir,4);
      OuttextXY(60,185,'V02.00');
      DisplayI;
      DisplayO;
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


procedure up;
begin
 RestoreRec(x,y);
 y:=y-1;
 ShadeRec(x,y);
end;

procedure down;
begin
 RestoreRec(x,y);
 y:=y+1;
 ShadeRec(x,y);
end;

procedure left;
begin
 restorerec(x,y);
 x:=x-1;
 shaderec(x,y);
end;

procedure right;
begin
 restorerec(x,y);
 x:=x+1;
 shaderec(x,y);
end;

Function BoolInt(X:boolean):Integer;
begin
     if X then BoolInt:=1
     else BoolInt:=0;
end;

Function IntBool(X:Integer):Boolean;
begin
     if X>0 then IntBool:=True
     else if X<0 then IntBool:=False
          else error('Bad call to function IntBool()');
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
begin
   repeat
       repeat ShadeRec(x,y);Delay(50);RestoreRec(x,y);Delay(50); until keypressed;
         key:=upcase(readkey);
         if key in [' ','I','M','J','K','C'] then
           case key of
             'I':if y <> 0 then up;
             'M':if y <> 9 then down;
             'J':if x <> 0 then left;
             'K':if x <> 19 then right;
             ' ':Toggle(x,y);
             'C':if x<10 then begin ClearI;DisplayI; end
                         else begin ClearO;DisplayO; end;
             end {case};
    until key='Q';  {Quit Editor}
end;

BEGIN
  X:=0;Y:=0;
  nosound;
  grDriver := Detect;
  InitGraph(grDriver,grMode,'');
  ErrCode := GraphResult;
  if ErrCode = grOk then begin
   ClearI;
   ClearO;
   ClearCon;
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
              j:= random(100);
              Sum:=0;
              for i:=0 to 99 do
                  Sum:=Sum+BoolInt(iput[i])*con[i,j];
              if Sum<>0 then begin
                 N:=IntBool(Sum);
                 if oput[j] <> N then begin
                   oput[j]:=N; {Fiddling with N saves one array access or IntBool call}
                   Stable:=False;
                   RestoreRec(10 +(j div 10),j mod 10);
                   end;
                 end;
               j:= random(100);
               Sum:=0;
               for i:= 0 to 99 do
                 Sum:=Sum+BoolInt(oput[i])*con[j,i];
               if Sum<>0 then begin
                  N:=IntBool(Sum);
                  if iput[j] <> N then begin
                    iput[j]:=N; {Fiddling with N saves one array access or IntBool call}
                    Stable:=False;
                    RestoreRec(j div 10,j mod 10);
                    end;
                  end;
      until keypressed;
      sound(1000);delay(100);nosound;
      end;
    until key='E';    {Exit Program}
   CloseGraph;
   end
 else
    Writeln('Graphics error:', GraphErrorMsg(ErrCode));
end.
