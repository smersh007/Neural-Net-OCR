const
     MaxImages   = 255;                         {Macro Images           }
     Cells       = 99;                          {Cells per Vector       }
     HCells      = 30;                          {Cells per Hidden Vector}
     MaxPairs    = 62;                          {Maximum Training Pairs }
     MaxLayers   = 1;                           {Maximum layers in net  }
     DialogHeight= 2;                           {Attention box height   }
     DialogWidth = 50;                          {Attention box width    }
     OnColor     = Blue;                        {Active cell color      }
     FlashColor  = Blue;                        {Flashing cell color    }
     OffColor    = Black;                       {Inactive cell color    }

     ConSource   = 'SAVE60.NET';      {Connection Matrix File }
     AssocSource = 'SAVE60.ASS';      {Association Matrix File}
     ImageSource = 'SAVE50.IMG';      {Macro Image File       }


type
    textline       = string[80];
    AttnString     = string[DialogWidth];
    DisplayString  = string[40];
    FileNameType   = string[40];
    TitleString    = string[10];
    ValueString    = string[5];
    Matrix         = array[0..Cells,0..HCells] of longint;  {First layer connections}
    HiddenMat      = array[0..HCells,0..HCells] of longInt; {All other layers}
    HiddenVec      = array[0..HCells] of Boolean;
    HiddenPtr      = ^HiddenLayer;
    HiddenLayer    = record
                     W         : HiddenMat; {Connection to previous layer}
                     C         : HiddenVec; {Output of current layer     }
                     Number    : integer;   {Level number (not used except for debugging)}
                     next,prev : HiddenPtr; {Pointers to next and previous layers}
                     end;
    Vector         = array[0..Cells] of boolean;   {Input Vector }
    OutVector      = array[0..7] of boolean;       {Output Vector}
    VectorTable    = array[0..MaxImages] of Vector;{Macro Images }
    AssocPair      = array[0..Maxpairs] of record
                                             Image : vector;
                                             Ascii : Byte {Training Pairs}
                                             end;
    AssocPairRec = record
                      Pair  :AssocPair;         {Training Pairs          }
                      LastPair:Integer;         {Number of Training Pairs}
                      end;

var
  ConFile    : file of longint;                 {Connection Storage     }
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
  X,Y        : Integer;                         {Editor co-ords         }
  Iput       : vector;                          {Input Vector           }
  Oput       : OutVector;                       {Output Vector          }
  W          : matrix;                          {First layer Connections}
  Done       : Boolean;                         {Quit Program           }
  Acc        : Real;                            {Recognition Accuracy   }
  K          : integer;                         {Weighted sum divisor   }
  GrabX,GrabY: integer;                         {X,Y co-ords of grabber }
  Watch      : Boolean;                         {Graphics switch        }
  Normalization:Boolean;                        {Normalization switch   }
  Network,                                      {Network Head pointer   }
  NetTail,                                      {Network Tail pointer   }
  n          : HiddenPtr;                       {Network layer pointer  }
  NoiseLevel : Integer;                         {learning Noise level   }
  Li,Lj      : LongInt;                         {temp longints          }
  i,j        : Integer;                         {temp vars              }