Procedure ClearVector(var Vector:vector);
var i:integer;
begin
   for i:= 0 to Cells do Vector[i]:=false; {Initialize arrays}
end;

Procedure ClearOutVector(var Vector:OutVector);
var i:integer;
begin
   for i:= 0 to 7 do Vector[i]:=false; {Initialize arrays}
end;

Procedure InvertVector(var Vector:vector);
var i:integer;
begin
   for i:= 0 to Cells do Vector[i]:=not Vector[i]; {Initialize arrays}
end;

Procedure CorruptVector(var Vector:vector;Prob:real);
{Flip Prob% of the units    (0<Prob<1)    }
var i:integer;
begin
   for i:= 0 to Cells do
     if Random<Prob then Vector[i]:=not Vector[i]; {Initialize arrays}
end;

Procedure ZeroMatrix(ICells,OCells:integer;var Matrix:matrix);
var i,j:integer;
begin
    for i:= 0 to ICells do
      for j:= 0 to OCells do
        Matrix[i,j]:=0;
end;

Function RandomBipolar:integer;
var    RNum :real;
begin
        RNum:=random;
        if RNum>0.5 then RandomBipolar:=1
        else If RNum>0.33 then RandomBipolar:=0
        else RandomBipolar:=-1;
end;

Procedure RandomizeMatrix(ICells,OCells:integer;var Matrix:matrix);
const Max:integer = 2;
var i,j  :integer;
begin
    for i:= 0 to ICells do
      for j:= 0 to OCells do Matrix[i,j]:=10*RandomBipolar
end;

Procedure CharVec(ch:Char;var OutVec:OutVector);
var i    : integer;
    Mask : integer;
begin
  Mask:=$01;
  for i:=0 to 7 do begin
    OutVec[i]:=((Lo(ord(ch)) and Mask)=Mask);
    Mask:=Mask shl 1;
    end;
end;

Function VecByte(Vec:OutVector):byte;
var i          : integer;
    R          : byte;
    PowerOfTwo : integer;
begin
  R:=0;
  PowerOfTwo:=1;
  for i:=0 to 7 do begin
    if Vec[i] then R:=R+PowerOfTwo;
    PowerOfTwo:=PowerOfTwo shl 1;
    end;
  VecByte:=R;
end;

procedure MakeNetWork(var Head,Tail:HiddenPtr);
{ Builds a doubly-linked list of connection matrices on the heap.}

var
  n : HiddenPtr;
  i : Integer;
begin
  Head := nil;
  n:=nil;
  for i := 0 to MaxLayers do begin
    if MaxAvail<SizeOf(HiddenLayer) then HeapOverflow;
    New(n);
    n^.Prev := nil;
    n^.Next := nil;
    n^.Number:=i;
    if Head = nil then Head := n
      else begin
      Tail^.Next := n;          {link to end }
      Tail^.Next^.Prev := Tail; {link to previous}
      end;
    Tail := n;                  {point tail pointer to end}
    end;
end;

procedure ZeroNetWork(n:HiddenPtr);
{ Zeros a doubly-linked list of connection matrices}

var
  i,j : integer;
begin
  if n<>nil then
  while n<>nil do begin
    for i:= 0 to HCells do  begin
      for j:= 0 to HCells do
        n^.W[i,j]:=0;
      n^.C[i]:=False;
      end;
    n:=n^.Next;
    end
  else Error('Bad call to procedure ZeroNetwork');
end;

procedure RandomizeNetWork(n:HiddenPtr);
{ Randomizes a doubly-linked list of connection matrices
 and Randomizes the cell outputs}

var
  i,j : integer;
begin
  if n<>nil then
  while n<>nil do begin
    for i:= 0 to HCells do begin
      for j:= 0 to HCells do
        n^.W[i,j]:=10*RandomBipolar;
      n^.C[i]:=False;
      end;
    n:=n^.Next;
    end
  else Error('Bad call to procedure RandomizeNetwork');
end;
