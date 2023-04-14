Procedure OpenMenu(Menu:MenuType);

Var OldPort      : ViewPortType;
    i            : Integer;
    x2,y2        : Integer;

begin
   GetViewSettings(OldPort);
   with MenuStack[MenuSP] do begin
     MenuX:=510-3*MenuSP;
     MenuY:=20+15*MenuSP;
     x2:=6*MenuWidth;
     y2:=ord(Menu[0,1])*10;
     SetViewPort(MenuX,MenuY,MenuX+x2,MenuY+y2,ClipOn);
     MenuImageSize:=ImageSize(0,0,x2,y2);
     GetMem(Ptr,MenuImageSize);
     GetImage(0,0,x2,y2,Ptr^);
     ClearViewPort;
     rectangle(0,0,x2,y2);
     Line(0,10,x2,10);
     SetTextStyle(SmallFont,HorizDir,4);
     OuttextXY((x2-TextWidth(Menu[1])) div 2,0,Menu[1]);
     for i:=2 to ord(Menu[0,1]) do
       OuttextXY(3,10*(i-1),Menu[i]);
     With OldPort do SetViewPort(x1,y1,x2,y2,Clip);
     end; {with}
   if MenuSP <>MaxOpen then Inc(MenuSP) else error('MenuStack Overflow');
end;

Procedure CloseMenu;
begin
   if MenuSP <> 0 then begin
     Dec(MenuSP);
     with MenuStack[MenuSP] do begin
        MenuY:=20+15*MenuSP;
        PutImage(MenuX,MenuY,Ptr^,Normalput);
        FreeMem(Ptr,MenuImageSize);
        end {with}
     end
   else error('MenuStack underflow');
end;
