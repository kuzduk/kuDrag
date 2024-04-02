unit Main;
{
ver 2024.1 free
kuzduk@mail.ru
http://kuzduk.ru/delphi/kulibrary
}
interface

uses
  Windows, Messages, Controls, Forms, ActiveX, ShlObj, ComObj, Classes, Dialogs,
  StdCtrls, SysUtils, FileCtrl, ShellAPI,

  kuDrag;

type
  TForm1 = class(TForm)
    FileListBox1: TFileListBox;
    btnMail: TButton;
    btnSait: TButton;
    DirectoryListBox1: TDirectoryListBox;
    Label1: TLabel;
    Label2: TLabel;

    procedure FileListBox1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FileListBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure btnSaitClick(Sender: TObject);
    procedure btnMailClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  end;

var
  Form1: TForm1;


implementation

{$R *.DFM}




//------------------------------------------------------------------------------ Form1 Create
procedure TForm1.FormCreate(Sender: TObject);
begin
DirectoryListBox1.Directory :=ExtractFilePath(Application.ExeName) + 'FilesForDrag'
end;







//------------------------------------------------------------------------------ Mouse Dn
procedure TForm1.FileListBox1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

if Button =  mbLeft
then
begin
  _kuDragPointDn := True; //исходная точка Drag нажата
  _kuDragPoint1 := Point(X, Y); //запоминаем исходную точку
end;

end;



//------------------------------------------------------------------------------ Mouse Move
procedure TForm1.FileListBox1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  FileList: TStrings;

begin

if not kuDragCan(Shift, X, Y) then exit;

FileList := TStringList.Create;


for i := 0 to FileListBox1.Items.Count - 1 do
  if FileListBox1.Selected[i] then FileList.Add( FileListBox1.Items[i] );

//ShowMessage(FileList.Text);

kuDragDo(FileListBox1, Label1.Caption, FileList, False, False);

FileList.Free;

end;






//------------------------------------------------------------------------------ email
procedure TForm1.btnMailClick(Sender: TObject);
begin
ShellExecute(Form1.Handle, nil, 'mailto:kuzduk@mail.ru?subject=kuDrag', nil, nil, SW_RESTORE);
end;



//------------------------------------------------------------------------------ Sait
procedure TForm1.btnSaitClick(Sender: TObject);
begin
ShellExecute(Form1.Handle, nil, PChar('https://kuzduk.ru/delphi/kulibrary'), nil, nil, SW_RESTORE);
end;


end.
