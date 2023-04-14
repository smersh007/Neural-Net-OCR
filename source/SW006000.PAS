program NNOCR;
{


           Neural Network Assosiative Memory experimentation utility
           ---------------------------------------------------------
                      by Michael R. Samerski

                      Last modified           28-05-89

Version 05.00
-------------
NOTES:
Software Modification Record:

V01.00
 Only one layer connects input to output.
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
V04.00
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
V05.00
 Output vector is 8 bits (cells) wide.
 dw can be altered.
 Image grabbing from HiRes screen during editing.
 Graphics can be switched on/off during learning to improve speed.
 Noise can be present during learning.
V06.00
 Same as V05.00 BUT:
  Multi-Layer neural network structure is used with full back-propagation;
  QT removed
  K introduced
  Connection save/load upgraded for multi-layers
  Active/Inhibitive/Connection Displays removed
}


Uses  Dos,Graph,Crt;

const
      Version     ='V06.00';
      PathToDriver='A:\BGI';

{$I SWI06000.pas}{Menu Definitions                }
{$I SWI06001.pas}{Global Declarations             }
{$I SWI06003.pas}{Displays, windows etc.          }
{$I SWI06005.pas}{Matrix and Vector Operations    }
{$I SWI06002.pas}{Cell Drawing procedures         }
{$I SWI04004.pas}{Menu Procedures                 }
{$I SWI05007.pas}{Cell Editor                     }
{$I SWI06008.pas}{Learning / Recalling procedures }
{$I SWI05009.pas}{Screen Display procedures       }

Procedure InstallFont(FontFileName:FileNameType);
{Installs fonts into the graphics system (on the Heap) to stop disk accesses}
{This procedure is out of the Turbo 5 reference manual                      }

var FontF:file;
    FontP:pointer;
begin
  if not Exist(FontFileName) then Error(FontFileName+' not found');
  Assign(FontF,FontFileName);
  Reset(FontF,1);
  GetMem(FontP,FileSize(FontF));
  BlockRead(FontF,FontP^,FileSize(FontF));
  if RegisterBGIFont(FontP)<0 then
    Error('Cant install font "'+FontFileName+'" '+GraphErrorMsg(GraphResult));
end;{InstallFont}

BEGIN
 grDriver := Detect;
 InitGraph(grDriver,grMode,PathToDriver);
 ErrCode := GraphResult;
 if ErrCode = grOk then begin
   InstallFont(PathToDriver+'\TRIP.CHR');
   InstallFont(PathToDriver+'\GOTH.CHR');
   InstallFont(PathToDriver+'\LITT.CHR');
   Randomize;
   X:=5;Y:=5;
   GrabX:=320;GrabY:=100;
   MenuSP:=0;
   Watch:=True;
   Normalization:=False;
   NoiseLevel:=0;
   K:=1;
   ImagePtr:=0;
   AssocTable.LastPair:=-1;
   Acc:=101;          {Undefined}
   ClearVector(Iput);
   ClearOutVector(Oput);
   MakeNetwork(Network,NetTail);
   RandomizeNetwork(Network);
   RandomizeMatrix(Cells,HCells,W);

   DrawScreen;
   DisplayK;
   DisplayAcc;
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
               #0 :Bin:=ReadKey;             {Dispose of unwanted Function Keys}
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
                   Edit(EdExCode);
                   if EdExCode=0 then with AssocTable do
                      if LastPair < MaxPairs then begin
                         Inc(LastPair);
                         Pair[LastPair].Image:=Iput;
                         Pair[LastPair].Ascii:=VecByte(Oput);
                         Acc:=101;DisplayAcc;
                         end
                         else Attention('Out of Training Space.',Bin);
                      end;
               else beep(1);
        end;
           until Key=#27;
           CloseMenu;
           end;
       'B':if AssocTable.LastPair>-1 then begin
              OpenMenu(MenuW);
              Setweights;
              CloseMenu;
              end
              else Attention('No Associations to Learn.',Bin);
       'T':begin                     {Test mode}
           Edit(EdExCode);
           if EdExCode=0 then begin
              OpenMenu(MenuW);
              ClearOutVector(Oput);
              DisplayO;
              Propagate;
              DisplayO;
              Beep(2);
              CloseMenu;
              end;
           end;
       'I':begin
           OpenMenu(MenuI);
           repeat                     {Image menu}
             Key:=Upcase(ReadKey);
             Case Key of
               #0 :Bin:=ReadKey;             {Dispose of unwanted Function Keys}
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
                      ImageTable[ImagePtr]:=Iput
                   end;
                   else beep(1);
               end;
        until Key =#27;
        CloseMenu;
        end;
    'C':begin                        {Connection menu}
        OpenMenu(MenuC);
        repeat
          Key:=Upcase(ReadKey);
          Case Key of
            #0 :Bin:=ReadKey;             {Dispose of unwanted Function Keys}
            'L':if not exist(ConSource) then Attention('File "'+ConSource+'" not found',Bin)
                else begin
                  OpenMenu(MenuW);
                  assign(ConFile,ConSource);  {Load connection matrix}
                  reset(ConFile);
                  read(ConFile,Li,Lj);
                  if (Li=MaxLayers) and (Lj=HCells) then begin
                    n:=Network^.next;
                    for i:=0 to Cells do
                      for j:=0 to HCells do
                        read(ConFile,W[i,j]);
                    while n<>nil do begin
                      for i:=0 to HCells do
                        for j:=0 to HCells do
                          read(ConFile,n^.W[i,j]);
                      n:=n^.next;
                      end;
                    Acc:=101;DisplayAcc;
                    end
                  else Attention('Incompatible Topology',Bin);
                  Close(ConFile);
                  CloseMenu;
                  end;
            'S':if Sure then begin
                   OpenMenu(MenuW);
                   Li:=LongInt(MaxLayers);Lj:=LongInt(HCells);
                   assign(ConFile,ConSource);
                   rewrite(ConFile);
                   n:=Network^.next;
                   write(ConFile,Li,Lj);
                   for i:=0 to Cells do
                     for j:=0 to HCells do
                       write(ConFile,W[i,j]);
                   while n<>nil do begin
                     for i:=0 to HCells do
                       for j:=0 to HCells do
                         write(ConFile,n^.W[i,j]);
                     n:=n^.next;
                     end;
                   Close(ConFile);
                   CloseMenu;
                   end;
            'Z':if Sure then Begin OpenMenu(MenuW);ZeroNetwork(Network);
                     ZeroMatrix(Cells,HCells,W);Acc:=101;DisplayAcc;CloseMenu;end;
            'R':if Sure then Begin OpenMenu(MenuW);RandomizeNetwork(Network);
                     RandomizeMatrix(Cells,HCells,W);Acc:=101;DisplayAcc;CloseMenu;end;
            else beep(1);
            end;
        until key=#27;
        CloseMenu
        end;
    'Q':if Sure then Done:=True;
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
    'K':begin
        OpenMenu(MenuV);
        repeat
             DisplayK;
             Key:=Upcase(ReadKey);
             if Key=#0 then begin
                Key:=ReadKey;
   {UPARROW}    if Key=#72 then Inc(K)
   {DNARROW}    else if Key=#80 then if K<>1 then Dec(K);
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
    else beep(1);
    end
   until Done;                    {Exit Program}
   CloseGraph;
   end
 else Writeln(GraphErrorMsg(ErrCode));
end.