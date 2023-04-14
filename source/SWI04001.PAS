const
     MaxImages   = 255;                         {Macro Images          }
     Cells       = 99;                          {Cells per Vector      }
     MaxPairs    = 26;                          {Training Pairs        }
     MaxPairsBy2 = 53;                          {Training Pairs Times 2+1}

     DialogHeight= 2;
     DialogWidth = 40;
     OnColor     = Blue;
     FlashColor  = Blue;
     OffColor    = Black;

     ConSource   = 'SAVE40.NET';        {Connection Matrix File}
     AssocSource = 'SAVE40.ASS';        {Association Matrix File}
     ImageSource = 'SAVE40.IMG';        {Macro Image File      }


type
    textline     = string[80];
    AttnString   = string[DialogWidth];
    DisplayString= string[40];
    filenametype = string[10];
    TitleString  = string[10];
    ValueString  = string[4];
    matrix       = array[0..Cells,0..Cells] of integer;
    vector       = array[0..Cells] of boolean;   {Input & Output Vectors}
    VectorTable  = array[0..MaxImages] of Vector;{Macro Images          }
    AssocPair    = array[0..MaxPairsBy2] of vector;{Training Pairs      }
    AssocPairRec = record
                      Pair  :AssocPair;      {Training Pairs         }
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
  Iput,Oput  : vector;                          {Input & Output Vectors }
  W          : matrix;                          {Connection  Matrix     }
  Done       : Boolean;                         {Quit Program           }
  QT         : Integer;                         {Threshold Level        }
  Acc        : Real;                            {Recognition Accuracy   }
  Anglestring: string[10];
  dw         : integer;                         {Magnitude of weight change}
  Watch      : Boolean;                         {Graphics update switch }
  Normalization:Boolean;                        {Normalization switch   }
  NoiseLevel : Integer;                         {noise level (corruption)}
