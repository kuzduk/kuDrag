unit kuDrag;
{
ver 2018 free
kuzduk@mail.ru
http://kuzduk.ru/delphi/kulibrary
}

interface

uses
  ActiveX, ComObj, ShlObj, Windows, Classes, ShellAPI, Controls;

type
  TDropEffect = (deNone, deCopy, deMove, deLink);
  TDropEffects = set of TDropEffect;

  TkuDrag = class(TComponent, IDropSource)
  
  private
    FDropEffects: TDropEffects;

  public
    constructor Create(AOwner: TComponent); override;
    function Drag(Directory: string; AFileName: string): Integer; overload;
    function Drag(Directory: string; AFileList: TStrings): Integer; overload;

    {IDropSource}
    function QueryContinueDrag(fEscapePressed: BOOL; grfKeyState: Longint): HResult; stdcall;
    function GiveFeedback(dwEffect: Longint): HResult; stdcall;

  published
    property DropEffects: TDropEffects read FDropEffects write FDropEffects;

  end;


var
  _kuDragPoint1: TPoint;
  _kuDragPointDn: Boolean = False;


function  kuDragCan(Shift: TShiftState; X, Y: Integer): Boolean;
procedure kuDragDo(MyComponent: TComponent; Directory: string; FileList: TStrings; SelfDrop, AverDrop: Boolean);



implementation


//------------------------------------------------------------------------------
constructor TkuDrag.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDropEffects := [deCopy];
end;

     
//------------------------------------------------------------------------------
function TkuDrag.Drag(Directory: string; AFileName: string): Integer;
var AStrings: TStrings;
begin

AStrings := TStringList.Create;
try
  AStrings.Add(AFileName);
  Result := Drag(Directory, AStrings);
finally
  AStrings.Free;
end;

end;


//------------------------------------------------------------------------------
function TkuDrag.Drag(Directory: string; AFileList: TStrings): Integer;
var
  dataObj: IDataObject; 
  Root: IShellFolder;
  pchEaten: ULONG;
  DirectoryItemIDList: PItemIDList;
  dwAttributes: ULONG;
  Folder: IShellFolder;
  i: Integer;
  ItemIDLists: array of PItemIDList;
  dwOKEffects: Longint;

begin

OleCheck(SHGetDesktopFolder(Root));

OleCheck(Root.ParseDisplayName(0, nil, PWideChar(WideString(Directory)), pchEaten, DirectoryItemIDList, dwAttributes));

try
  OleCheck(Root.BindToObject(DirectoryItemIDList, nil, IShellFolder, Folder));

  SetLength(ItemIDLists, AFileList.Count);

  for i := 0 to AFileList.Count - 1
  do OleCheck(Folder.ParseDisplayName(0, nil,
     PWideChar(WideString(AFileList[i])), pchEaten, ItemIDLists[i], dwAttributes));

  try
    OleCheck(Folder.GetUIObjectOf(0, AFileList.Count, ItemIDLists[0], IDataObject, nil, dataObj));
  finally
    for i := 0 to AFileList.Count - 1 do CoTaskMemFree(ItemIDLists[i]);
  end;

  dwOKEffects := 0;
  if deNone in FDropEffects then dwOKEffects := dwOKEffects or DROPEFFECT_NONE;
  if deCopy in FDropEffects then dwOKEffects := dwOKEffects or DROPEFFECT_COPY;
  if deMove in FDropEffects then dwOKEffects := dwOKEffects or DROPEFFECT_MOVE;
  if deLink in FDropEffects then dwOKEffects := dwOKEffects or DROPEFFECT_LINK;

  DoDragDrop(dataObj, Self, dwOKEffects, Result);
  
finally
  CoTaskMemFree(DirectoryItemIDList);
end;

end;


//------------------------------------------------------------------------------
function TkuDrag.QueryContinueDrag(fEscapePressed: BOOL; grfKeyState: Integer): HResult;
begin

if fEscapePressed

then Result := DRAGDROP_S_CANCEL

else if grfKeyState and MK_LBUTTON = 0
     then Result := DRAGDROP_S_DROP
     else Result := S_OK;
     
end;


//------------------------------------------------------------------------------
function TkuDrag.GiveFeedback(dwEffect: Integer): HResult;
begin
Result := DRAGDROP_S_USEDEFAULTCURSORS;
end;



//------------------------------------------------------------------------------ Drag Can
function kuDragCan(Shift: TShiftState; X, Y: Integer): Boolean;
//¬стал€ем енту процедуру в начало OnMouseMove - это проверка что можно начать Drag
begin

Result := False;

if not _kuDragPointDn then exit;
if not (ssLeft in Shift) then exit;
//if not KeyDownly(VK_LBUTTON) then exit;
if (Abs(X - _kuDragPoint1.X) < 5) and (Abs(Y - _kuDragPoint1.Y) < 5) then exit;
//if (X < 0) or (Y < 0) or (X > Self.Width) or (Y > Self.Height)
//then

_kuDragPointDn := False;

Result := True;

end;


//------------------------------------------------------------------------------ Drag Do
procedure kuDragDo(MyComponent: TComponent; Directory: string; FileList: TStrings; SelfDrop, AverDrop: Boolean);
//¬стал€ем енту процедуру в OnMouseMove после проверки DragCan
//SelfDrop - бросать на самого себ€
//AverDrop - разрешить бросать на себ€ с других компонентов после завершени€ текущего Drag
var kuDrag1: TkuDrag;
begin

DragAcceptFiles(TWinControl(MyComponent).Handle, SelfDrop); //Drop на самого себ€

kuDrag1 := TkuDrag.Create(MyComponent);
kuDrag1.Drag(Directory, FileList);
kuDrag1.Free;

DragAcceptFiles(TWinControl(MyComponent).Handle, AverDrop); //включить/выключить Drop, чтоб принимать с других мест

end;






initialization
  OleInitialize(nil);

finalization
  OleUninitialize;

end.

