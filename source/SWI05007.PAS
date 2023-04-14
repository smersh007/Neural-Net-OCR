Procedure Edit(var ExitCode:integer);
var
    Done        : boolean;
    ISave       : Vector;
    OSave       : OutVector;
    Key         : Char;
    ScrollMode  : Boolean;
    w,h         : integer;

  procedure Up;
  var i:integer;
  begin
  if ScrollMode then begin
    for i:= 0 to cells-1 do Iput[i]:=Iput[i+1];
    for i:= 0 to 9 do Iput[9+10*i]:=False;
    Iput[cells]:=False;
    DisplayI;
    end;
  RestoreRec(x,y);
  if y<>0 then y:=y-1;
  ShadeRec(x,y);
  end;

  procedure Down;
  var i:integer;
  begin
  if ScrollMode then begin
    for i:= cells downto 1 do Iput[i]:=Iput[i-1];
    for i:= 0 to 9 do Iput[10*i]:=False;
    Iput[0]:=False;
    DisplayI;
    end;
  RestoreRec(x,y);
  if y<>9 then y:=y+1;
  ShadeRec(x,y);
  end;

  procedure Left;
  var i:integer;
  begin
  if ScrollMode then begin
    for i:= 0 to cells-10 do Iput[i]:=Iput[i+10];
    for i:= cells-10 to cells do Iput[i]:=False;
    DisplayI
    end;
  RestoreRec(x,y);
  if x<>0 then x:=x-1;
  ShadeRec(x,y);
  end;

  procedure Right;
  var i:integer;
  begin
  if ScrollMode then begin
    for i:= cells downto 10 do Iput[i]:=Iput[i-10];
    for i:= 0 to 9 do Iput[i]:=False;
    DisplayI
    end;
  RestoreRec(x,y);
  if x<>9 then x:=x+1;
  ShadeRec(x,y);
  end;

  Procedure EditChar(var Vec:OutVector);
  var Finished : boolean;
  begin
    Finished:=False;
    repeat
      Key:=ReadKey;
      if Key=#13 then begin Finished:=True;Done:=True end
      else if Key=#0 then begin
              Key:=ReadKey;
              if Key in [#115,#75] then Finished:=True;
              end
      else begin
        CharVec(Key,Vec);
        DisplayO;
        end;
    until Done;
  end;

  Procedure Scan(Vec:Vector);

  var Done  : boolean;
      X,Y   : integer;
      w,h,d : Integer;

    Procedure Grab(x,y,w,h:integer);
    var x2,y2 : integer;
        x3,y3 : integer;
        kx,ky : integer;
        NearBy: boolean;
    begin
       kx:=w div 10;
       ky:=h div 10;
       for x2:=0 to 9 do
         for y2:=0 to 9 do begin
           NearBy:=False;
           for x3:=x2*kx to x2*kx+kx-1 do
             for y3:=y2*ky to y2*ky+ky-1 do
               if GetPixel(x+x3,y+y3)=1 then NearBy:=True;
           Iput[x2*10+y2]:=NearBy;
           end;
    end;

    procedure Target(x,y,w,h:integer);
    Var OldPort      : ViewPortType;
        x2,y2        : Integer;
        BitMap       : Pointer;
        WindowSize   : word;

    begin
       GetViewSettings(OldPort);
       x2:=w;
       y2:=h;
       SetViewPort(x,y,x+x2,y+y2,ClipOn);
       WindowSize:=ImageSize(0,0,x2,y2);
       GetMem(BitMap,WindowSize);
       GetImage(0,0,x2,y2,BitMap^);
       ClearViewPort;
       rectangle(0,0,x2,y2);
       Delay(20);
       PutImage(0,0,BitMap^,Normalput);
       FreeMem(BitMap,WindowSize);
       With OldPort do SetViewPort(x1,y1,x2,y2,Clip);
    end;


  begin
     OpenMenu(MenuG);
     Done:=False;
     X:=GrabX;Y:=GrabY;
     w:=10;h:=10;
     d:=2;
     repeat
         repeat Target(x,y,w,h) until KeyPressed;
         Key:=ReadKey;
         case Key of
            #0:begin
                 Key:=ReadKey;                          { Function keys }
                 case Key of
      {UP}         #72: if y-d > 0     then y:=y-d;
      {LEFT}       #75: if x-d > 0     then x:=x-d;
      {RIGHT}      #77: if x+w+d < 639 then x:=x+d;
      {DOWN}       #80: if y+h+d < 199 then y:=y+d;
      {HOME}      #115: if d<>1 then dec(d);
      {END}       #116: if d<>100 then inc(d);
      {PGUP}       #73: if (x+w+10 < 639) and (y+h+10<199) then begin w:=w+10;h:=h+10 end;
      {PGDN}       #81: if (w>10) then begin w:=w-10;h:=h-10 end;
                   end;
               end;
     {SPACE}' ': begin
                 OpenMenu(MenuW);
                 Grab(x,y,w,h);
                 DisplayI;
                 CloseMenu;
                 end;
     {ENTER}#13: Done:=True;
            end;
      until Done;  {Quit Editor}
      GrabX:=X;GrabY:=Y;
      CloseMenu;
  end;

  procedure Normalize;
  var Ok,OldScrollMode : boolean;
      i,k              : integer;
  begin
     OldScrollMode:=ScrollMode;
     ScrollMode:=True;
     k:=0;
     Ok:=False;
     repeat
       inc(k);
       for i:=0 to 9 do if Iput[i] then Ok:=True;
       if not Ok then begin
         Left;
         end;
     until Ok or (k=10);
     k:=0;
     Ok:=False;
     repeat
       inc(k);
       for i:=0 to 9 do if Iput[10*i+9] then Ok:=True;
       if not Ok then begin
         Down;
         end;
     until Ok or (K=10);
     ScrollMode:=OldScrollMode;
  end;

begin
   ExitCode:=0; {Exit Normally}
   OpenMenu(MenuE);
   ISave:=Iput;
   OSave:=Oput;
   Done:=False;
   ScrollMode:=False;
   repeat
       repeat ShadeRec(x,y);Delay(70);RestoreRec(x,y);Delay(50); until keypressed;
       Key:=ReadKey;
       case Key of
          #0:begin
               Key:=ReadKey;                          { Function keys }
               case Key of
    {UP}         #72: if y <> 0  then Up;
    {LEFT}       #75: if x <> 0  then Left;
    {RIGHT}      #77: if x <> 9  then Right;
    {DOWN}       #80: if y <> 9  then Down;
    {CTRLRIGHT} #116: EditChar(Oput);
    {F1}         #59: begin InvertVector(iput);DisplayI;end;
    {F2}         #60: begin ClearVector(iput);DisplayI;end;
    {F3}         #61: begin CorruptVector(iput,0.1);DisplayI;end;
    {F4}         #62: begin OpenMenu(MenuW);Normalize;CloseMenu;end;
    {F5}         #63: begin Scan(iput);DisplayI;end;
    {INS}        #82: begin ScrollMode:=not ScrollMode;beep(1);end;
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
                       else begin CharVec(Key,Oput);DisplayO end
                 end;
          end;
    until Done;  {Quit Editor}
CloseMenu;
end;
