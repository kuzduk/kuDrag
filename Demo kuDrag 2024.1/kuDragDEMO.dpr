program kuDragDEMO;

uses
  Forms,
  Main in 'Main.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'kuDragDEMO';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
