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
       u:=200+Trunc(4*(x*CosTheta-y*14*CosThi));
       v:=170-Trunc(1.2*(Mat[x,y]+y*14*SinThi+x*SinTheta));
    end;            {      ^-- z-axis  }

begin
  GetViewSettings(OldPort);
  x1:=32;
  y1:=10;
  x2:=576;
  y2:=180;
  WindowSize:=ImageSize(x1,y1,x1+x2,y1+y2);
  if WindowSize>MaxAvail then HeapOverflow;
  GetMem(BitMap,WindowSize);
  GetImage(x1,y1,x1+x2,y1+y2,BitMap^);
  SetViewPort(x1,y1,x1+x2,y1+y2,ClipOn);
  ClearViewPort;
  rectangle(0,0,x2,y2);
  CosTheta:=cos(Theta*Pi/180);
  SinThi  :=sin(Thi*Pi/180);
  CosThi  :=cos(Thi*Pi/180);
  SinTheta:=sin(Theta*Pi/180);
  for x:= 0 to Cells do begin
    y:=0;
    Translate;
    MoveTo(u,v);
    for y:= 0 to 7 do begin
       Translate;
       LineTo(u,v);
       end
    end;
    for y:= 0 to 7 do begin
      x:=0;
      Translate;
      MoveTo(u,v);
      for x:= 0 to Cells do begin
         Translate;
         LineTo(u,v);
         end;
      end;
  Attention('Press any key.',Bin);
  With OldPort do SetViewPort(x1,y1,x2,y2,Clip);
  PutImage(x1,y1,BitMap^,Normalput);
  FreeMem(BitMap,WindowSize);
end;