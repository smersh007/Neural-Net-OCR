program Key_Finder;

uses crt;

var
   Key:char;
   Done:boolean;

Procedure CharVec(ch:Char);
var i    : integer;
    Mask : integer;
begin
  Mask:=$01;
  for i:=0 to 7 do begin
    if ((ord(ch) and Mask)=Mask) then write('1') else write('0');
    Mask:=Mask shl 1;
    end;
end;

begin
   done:=false;
   repeat
       Key:=ReadKey;
       if Key = #0 then begin
               Key:=ReadKey;                 { Function keys }
               write('Fn:',Key,' ',ord(Key),' ');
               CharVec(Key);writeln;
               end
         else if Key = #13 then Done:=True   {Enter }
         else begin
           write('   ',Key,' ',ord(Key),' ');
           CharVec(Key);writeln;
           end;
    until Done;  {Quit Editor}
end.
