Procedure DisplayMatrix(Var Mat:Matrix);
                     {   ^--- to prevent Stack Overflow}
Var OldPort      : ViewPortType;
    x1,y1,x2,y2  : Integer;
    BitMap       : Pointer;
    WindowSize   : word;
    x,y,u,v      : integer;                          { y    z,v   x    }
    CosTheta,                                        {  ^    ^    ^    }
    SinThi,                                          {   \   |   /     }
    CosThi,                                          {    \  |  /      }
    SinTheta     : Real;                             { Thi \ | / Theta }
    Key          : Char;                             {      \|/        }
                                                     { <-----*------>u }
const Theta = 20;{__ Degrees  }
      Thi   = 60;{            }

    PROCEDURE Translate;{ from (x,y,z) -> (u,v)    }
    begin
       u:=200+Trunc(8*(x*CosTheta-y*CosThi));
       v:=170-Trunc(2.4*(Mat[2*x,2*(y+1)]+y*SinThi+x*SinTheta));
    end;            {      ^-- z-axis  }

begin
  GetViewSettings(OldPort);
  x1:=32;
  y1:=10;
  x2:=576;
  y2:=180;
  WindowSize:=ImageSize(x1,y1,x1+x2,y1+y2);
  GetMem(BitMap,WindowSize);
  GetImage(x1,y1,x1+x2,y1+y2,BitMap^);
  SetViewPort(x1,y1,x1+x2,y1+y2,ClipOn);
  ClearViewPort;
  rectangle(0,0,x2,y2);
  CosTheta:=cos(Theta*Pi/180);
  SinThi  :=sin(Thi*Pi/180);
  CosThi  :=cos(Thi*Pi/180);
  SinTheta:=sin(Theta*Pi/180);
  for x:= 0 to Cells div 2 do begin
    y:=0;
    Translate;
    MoveTo(u,v);
    for y:= 0 to (Cells div 2)-1 do begin
       Translate;
       LineTo(u,v);
       end
    end;
  Attention('Continue?  (y/N)',Key);
  if UpCase(Key)='Y' then begin
    for y:= 0 to (Cells div 2)-1 do begin
      x:=0;
      Translate;
      MoveTo(u,v);
      for x:= 0 to Cells div 2 do begin
         Translate;
         LineTo(u,v);
         end;
      end;
    Attention('Press any key.',Bin);
    end;
   With OldPort do SetViewPort(x1,y1,x2,y2,Clip);
   PutImage(x1,y1,BitMap^,Normalput);
   FreeMem(BitMap,WindowSize);
end;
