Procedure Edit(var ExitCode:integer);

var Done        : boolean;
    ISave,OSave : Vector;
    Key         : Char;
    ScrollMode  : Boolean;

  procedure Up;
  begin
  if ScrollMode then begin
    for i:= 0 to cells-1 do
      if x<10 then Iput[i]:=Iput[i+1]
        else Oput[i]:=Oput[i+1];
    if x<10 then DisplayI else DisplayO;
    end
  else begin
    RestoreRec(x,y);
    y:=y-1;
    ShadeRec(x,y);
    end;
  end;

  procedure Down;
  begin
  if ScrollMode then begin
    for i:= cells downto 1 do
      if x<10 then Iput[i]:=Iput[i-1]
        else Oput[i]:=Oput[i-1];
    if x<10 then DisplayI else DisplayO;
    end
  else begin
    RestoreRec(x,y);
    y:=y+1;
    ShadeRec(x,y);
    end;
  end;

  procedure Left;
  begin
  if ScrollMode then begin
    for i:= 0 to cells-10 do
      if x<10 then Iput[i]:=Iput[i+10]
        else Oput[i]:=Oput[i+10];
    if x<10 then begin
       for i:= cells-10 to cells do Iput[i]:=False;
       DisplayI
       end
      else begin
        for i:= cells-10 to cells do Oput[i]:=False;
        DisplayO;
        end;
    end
  else begin
    RestoreRec(x,y);
    x:=x-1;
    ShadeRec(x,y);
    end;
  end;

  procedure Right;
  begin
  if ScrollMode then begin
    for i:= cells downto 10 do
      if x<10 then Iput[i]:=Iput[i-10]
        else Oput[i]:=Oput[i-10];
    if x<10 then begin
       for i:= 0 to 9 do Iput[i]:=False;
       DisplayI
       end
      else begin
        for i:= 0 to 9 do Oput[i]:=False;
        DisplayO;
        end;
    end
  else begin
    RestoreRec(x,y);
    x:=x+1;
    ShadeRec(x,y);
    end;
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
    {RIGHT}      #77: if x <> 19 then Right;
    {BIGLEFT}   #115: if x >  0  then BigLeft;
    {BIGRIGHT}  #116: if x <  19 then BigRight;
    {DOWN}       #80: if y <> 9  then Down;
    {F1}         #59: if x<10 then begin InvertVector(Iput);DisplayI;end
                      else begin InvertVector(Oput);DisplayO; end;
    {F2}         #60: if x<10 then begin ClearVector(Iput);DisplayI;end
                      else begin ClearVector(Oput);DisplayO; end;
    {F3}         #61: if x<10 then begin CorruptVector(Iput,0.1);DisplayI;end
                      else begin CorruptVector(Oput,0.1);DisplayO; end;
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
                       else begin Oput:=ImageTable[ImagePtr];DisplayO end
                 end;
          end;
    until Done;  {Quit Editor}
CloseMenu;
end;
