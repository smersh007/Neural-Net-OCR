program UAM;
{


           Neural Network Assosiative Memory experimentation utility
           ---------------------------------------------------------
                      by Michael R. Samerski

                      Commenced               21-08-88
                      Last modified           29-03-89

            Developed from 'A window into the brain', APC March 1988

Version 04.00
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
V03.02
 Character images can be inserted into input and output fields from disk
 Connection Matrix can be viewed in 3D
 Neuron firing speed is increased 171%       \__by replacing multiplies with
 Weight computation speed is increased  33%  /  logic operations
V03.03
 System is under menu control.
 Vector Corruption during editing available.

 Same as V03.03 BUT:
   BAM action is removed so that unidirectional transfer occurs.
   Weights are no longer calculated by cross-correlation,
     the Delta method is used.
   More menu options available to cope with Delta Method,
     such as connection matrix zeroing and randomizing,
     Active and Inhibitive neuron location, Back-Propagation and
     association pair editing, saving and loading.
   Dialog Box added for messages, errors and prompts.
   Image Normalization can be switched on/off.
   Source File was split into include files for convienience.

}


Uses
  Dos,
  Graph,
  Crt;


const Version='V04.00';
      PathToDriver='A:\BGI';

{$I SWI04000}{Menu Definitions               }
{$I SWI04001}{Global Declarations            }
{$I SWI04005}{Matrix and Vector Operations   }
{$I SWI04002}{Cell Drawing procedures        }
{$I SWI04003}{Displays, windows etc.         }
{$I SWI04004}{Menu Procedures                }
{$I SWI04006}{Matrix Display                 }
{$I SWI04007}{Cell Editor                    }
{$I SWI04008}{Learning / Recalling procedures}
{$I SWI04009}{Screen Display procedures      }

BEGIN
  Randomize;
  X:=0;Y:=0;
  QT:=0;
  dw:=1;
  Watch:=True;
  Acc:=101;          {Undefined}
  NoiseLevel:=0;
  MenuSP:=0;
  grDriver := Detect;
  AssocTable.LastPair:=-1;
  InitGraph(grDriver,grMode,PathToDriver);
  ErrCode := GraphResult;
  if ErrCode = grOk then begin
   ClearVector(Iput);
   ClearVector(Oput);
   ZeroMatrix(W);
   DrawScreen;
   DisplayAcc;
   DisplayDw;
   DisplayNormalization;
   DisplayWatch;
   DisplayNoise;
   Done:=False;
   RightArrow;
   OpenMenu(Menu0);
   repeat
     Key:=Upcase(ReadKey);
     Case Key of
       #0 :Bin:=ReadKey;             {Dispose of unwanted Function Keys}
       'A':begin
           OpenMenu(MenuA);
           repeat                    {Associations menu}
             Key:=Upcase(ReadKey);
             Case Key of
               'L':if not exist(AssocSource) then Attention('File "'+AssocSource+'" not found',Bin)
                   else begin
                   OpenMenu(MenuW);
                   assign(Assocfile,AssocSource);
                   reset(AssocFile);
                   read(Assocfile,AssocTable);
                   close(Assocfile);
                   Acc:=101;DisplayAcc;
                   CloseMenu;
                   end;
               'D':if Sure then AssocTable.LastPair:=-1;
               'S':if Sure then begin
                      OpenMenu(MenuW);
                      assign(AssocFile,AssocSource);
                      rewrite(AssocFile);
                      write(AssocFile,AssocTable);
                      close(AssocFile);
                      CloseMenu;
                   end;
               'A':begin                     {Edit mode}
                   X:=5;Y:=5;
                   Edit(EdExCode);
                   if EdExCode=0 then with AssocTable do
                      if LastPair < MaxPairs then begin
                         Inc(LastPair);
                         Pair[2*LastPair]:=Iput;
                         Pair[2*LastPair+1]:=Oput;
                         Acc:=101;DisplayAcc;
                         end
                         else Attention('Out of Training Space.',Bin);
                      end;
               end;
           until Key=#27;
           CloseMenu;
           end;
       'B':if AssocTable.LastPair>-1 then begin OpenMenu(MenuW);Setweights;CloseMenu;end
              else Attention('No Associations to Learn.',Bin);
       'T':begin                     {Test mode}
           Edit(EdExCode);
           if EdExCode=0 then begin
              OpenMenu(MenuW);
              repeat
                If NoiseLevel > 0 Then
                  CorruptVector(Iput,NoiseLevel/100);
                DisplayI;
                Propagate;
                DisplayO;
                IPut:=OPut;
                Beep(2);
              until KeyPressed;
              CloseMenu;
              end;
           end;
       'I':begin
           OpenMenu(MenuI);
           repeat                     {Image menu}
             Key:=Upcase(ReadKey);
             Case Key of
               'L':if not exist(ImageSource) then Attention('File "'+ImageSource+'" not found',Bin)
                   else begin
                   OpenMenu(MenuW);
                   assign(Vectorfile,ImageSource);
                   reset(VectorFile);
                   read(Vectorfile,ImageTable);
                   close(Vectorfile);
                   CloseMenu;
                   end;
               'S':if Sure then begin
                      OpenMenu(MenuW);
                      assign(VectorFile,ImageSource);
                      rewrite(VectorFile);
                      write(VectorFile,ImageTable);
                      close(VectorFile);
                      CloseMenu;
                      end;
               'E':Begin
                   Edit(EdExCode);
                   if EdExCode=0 then
                      if x<10 then ImageTable[ImagePtr]:=Iput
                        else ImageTable[ImagePtr]:=Oput
                   end;
               end;
        until Key =#27;
        CloseMenu;
        end;
    'C':begin                        {Connection menu}
        OpenMenu(MenuC);
        repeat
          Key:=Upcase(ReadKey);
          Case Key of
            'L':if not exist(ConSource) then Attention('File "'+ConSource+'" not found',Bin)
                else begin
                  OpenMenu(MenuW);
                  assign(matrixfile,ConSource);  {Load connection matrix}
                  reset(matrixfile);
                  read(matrixfile,W);
                  Acc:=101;DisplayAcc;
                  CloseMenu;
                  end;
            'D':DisplayMatrix(W);
            'S':if Sure then begin
                   OpenMenu(MenuW);
                   assign(matrixfile,ConSource);
                   rewrite(matrixfile);
                   write(matrixfile,W);
                   close(matrixfile);
                   CloseMenu;
                   end;
            'Z':if Sure then Begin OpenMenu(MenuW);ZeroMatrix(W);Acc:=101;DisplayAcc;CloseMenu;end;
            'R':if Sure then Begin OpenMenu(MenuW);RandomizeMatrix(W);Acc:=101;DisplayAcc;CloseMenu;end;
            'A':Begin OpenMenu(MenuW);ActiveDetect;CloseMenu;end;
            'I':Begin OpenMenu(MenuW);InhibitiveDetect;CloseMenu;end;
            end;
        until key=#27;
        CloseMenu
        end;
    'N':begin
        OpenMenu(MenuV);
        repeat
             DisplayNormalization;
             Key:=Upcase(ReadKey);
             if Key=#0 then begin
                Key:=ReadKey;
   {UPARROW}    if Key=#72 then Normalization:=True
   {DNARROW}    else if Key=#80 then Normalization:=False;
                end;
        until Key=#13;  {RETURN}
        Acc:=101;DisplayAcc;
        CloseMenu;
        end;
    'L':begin
        OpenMenu(MenuV);
        repeat
             DisplayNoise;
             Key:=Upcase(ReadKey);
             if Key=#0 then begin
                Key:=ReadKey;
   {UPARROW}    if Key=#72 then if NoiseLevel<>100 then Inc(NoiseLevel);
   {DNARROW}    if Key=#80 then if NoiseLevel<>0 then Dec(NoiseLevel);
                end;
        until Key=#13;  {RETURN}
        Acc:=101;DisplayAcc;
        CloseMenu;
        end;
    'W':begin
        OpenMenu(MenuV);
        repeat
             Displaydw;
             Key:=Upcase(ReadKey);
             if Key=#0 then begin
                Key:=ReadKey;
   {UPARROW}    if Key=#72 then Inc(dw);
   {DNARROW}    if Key=#80 then if dw<>1 then Dec(dw);
                end;
        until Key=#13;  {RETURN}
        Acc:=101;DisplayAcc;
        CloseMenu;
        end;
    'Q':if Sure then Done:=True;
    'H':begin
        OpenMenu(MenuV);
        Key:=Upcase(ReadKey);
        repeat
             DisplayQT;
             Key:=ReadKey;
             if Key=#0 then begin
                Key:=ReadKey;
   {UPARROW}    if Key=#72 then Inc(QT);
   {DNARROW}    if Key=#80 then if QT<>0 then Dec(QT);
                end;
        until Key=#13;  {RETURN}
        Acc:=101;DisplayAcc;
        CloseMenu;
        end;
    end;
   until Done;                    {Exit Program}
   CloseGraph;
   end
 else Writeln(GraphErrorMsg(ErrCode));
end.