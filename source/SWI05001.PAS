const
     MaxImages   = 255;                         {Macro Images          }
     Cells       = 99;                          {Cells per Vector      }
     MaxPairs    = 62;                          {Training Pairs        }

     DialogHeight= 2;
     DialogWidth = 40;
     OnColor     = Blue;
     FlashColor  = Blue;
     OffColor    = Black;

     ConSource   = 'SAVE50.NET';        {Connection Matrix File}
     AssocSource = 'SAVE50.ASS';        {Association Matrix File}
     ImageSource = 'SAVE50.IMG';        {Macro Image File      }


type
    textline     = string[80];
    AttnString   = string[DialogWidth];
    DisplayString= string[40];
    FileNameType = string[20];
    TitleString  = string[10];
    ValueString  = string[5];
    Matrix       = array[0..Cells,0..7] of integer;
    Vector       = array[0..Cells] of boolean;   {Input Vectors}
    OutVector    = array[0..7] of boolean;
    VectorTable  = array[0..MaxImages] of Vector;{Macro Images          }
    AssocPair    = array[0..Maxpairs] of record
                                             Image : vector;
                                             Ascii : Byte   {Training Pairs}
                                             end;
    AssocPairRec = record
                      Pair  :AssocPair;         {Training Pairs         }
                      LastPair:Integer;
                      end;

var
  MatrixFile : file of matrix;                  {Connection Storage     }
  VectorFile : file of VectorTable;             {Macro Images           }
  AssocFile  : file of AssocPairRec;
  AssocTable : AssocPairRec;
  ImageTable : VectorTable;                     {Macro Images           }
  EdExCode   : Integer;                         {Editor Exit Code       }
  ImagePtr   : Integer;                         {Macro Pointer          }
  grDriver   : integer;                         { \                     }
  grMode     : integer;                         {  \__Graphics stuff    }
  ErrCode    : integer;                         {  /                    }
  Inf        : TextSettingsType;                { /                     }
  Key,Bin    : char;                            {Keyboard Results       }
  X,Y,                                          {General Martix indexes }
  i,j        : integer;                         {General Matrix indexes }
  Iput       : vector;                          {Input & Output Vectors }
  Oput       : OutVector;
  W          : matrix;                          {Connection  Matrix     }
  Done       : Boolean;                         {Quit Program           }
  QT         : Integer;                         {Threshold Level        }
  Acc        : Real;                            {Recognition Accuracy   }
  Anglestring: string[10];                      {}
  dw         : integer;                         {Magnitude of weight change}
  GrabX,GrabY: integer;                         {X,Y of graphics grabing routine}
  Watch      : Boolean;                         {Graphics update switch }
  Normalization:Boolean;                        {Normalization switch   }
  NoiseLevel : Integer;                         {noise level (corruption)}