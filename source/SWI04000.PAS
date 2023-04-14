const MaxOptions = 11;
      MenuWidth  = 20;
      MaxOpen    = 5;

type MenuString  = string[MenuWidth];
     MenuType    = array[0..MaxOptions] of MenuString;

var  MenuSP       : integer;
     MenuStack    : array[0..MaxOpen] of record
                                               MenuX,
                                               MenuY        : Integer;
                                               Ptr          : Pointer;
                                               MenuImageSize: word;
                                               end;

const
   menu0:MenuType=
          (#11,
          'Network Menu',
          'Connections.. ',
          'Images..      ',
          'Associations..',
          'Back-propagate',
          'Test          ',
          'thresHold     ',
          'dW            ',
          'Normalization ',
          'noise Level   ',
          'Quit          ');
   menuC:MenuType=
          (#9,
          'Connection Menu',
          'Load         ',
          'Save         ',
          'Display      ',
          'Active       ',
          'Inhibitive   ',
          'Zero         ',
          'Randomize    ',
          'ESCape       ','','');
   menuI:MenuType=
          (#5,
          'Image Menu',
          'Load         ',
          'Save         ',
          'Edit         ',
          'ESCape       ','','','','','','');
   menuA:MenuType=
          (#6,
          'Association Menu',
          'Load         ',
          'Save         ',
          'Add Pairs    ',
          'Delete all Pairs',
          'ESCape','','','','','');
   menuV:MenuType=
          (#4,
          'Set New Value',
          '^            ',
          'v            ',
          'RET: Done    ','','','','','','','');
   menuE:MenuType=
          (#7,
          'Edit Menu',
          'F1 : Invert     ',
          'F2 : Clear      ',
          'F3 : Corrupt 10%',
          'INS: Scroll Mode',
          'RET: Done       ',
          'ESC: Abort   ','','','','');
   menuW:MenuType=
          (#1,
          'Please Wait ...',
          '','','','','','','','','','');
