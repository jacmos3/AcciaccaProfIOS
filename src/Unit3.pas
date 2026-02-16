unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtDlgs, ExtCtrls;

type
  Tfrmimpostazioni = class(TForm)
    OpenPictureDialog1: TOpenPictureDialog;
    Button1: TButton;
    profcatt1: TImage;
    Button2: TButton;
    profcatt2: TImage;
    profcatt3: TImage;
    Button3: TButton;
    profbuon1: TImage;
    profbuon2: TImage;
    profbuon3: TImage;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    bidella: TImage;
    Button7: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Label7: TLabel;
    Button15: TButton;
    Timer1: TTimer;
    Label8: TLabel;
    Button8: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmimpostazioni: Tfrmimpostazioni;
  nomedir:string;
implementation

uses Unit1;

{$R *.dfm}

procedure Tfrmimpostazioni.Button1Click(Sender: TObject);
begin
 if openpicturedialog1.execute then
  begin
   profcatt1.Picture.LoadFromFile(openpicturedialog1.filename);
   form1.profcatt.Picture:=profcatt1.Picture;
   if button9.enabled=false then
    button9.click;
   button9.enabled:=true;
  end;
end;

procedure Tfrmimpostazioni.Button2Click(Sender: TObject);
begin
 if openpicturedialog1.execute then
  begin
   profcatt2.Picture.LoadFromFile(openpicturedialog1.filename);
   if button10.enabled=false then
    button10.click;
   button10.enabled:=true;
  end;
end;

procedure Tfrmimpostazioni.Button3Click(Sender: TObject);
begin
 if openpicturedialog1.execute then
  begin
   profcatt3.Picture.LoadFromFile(openpicturedialog1.filename);
   if button11.enabled=false then
    button11.click;
   button11.enabled:=true;
  end;
end;

procedure Tfrmimpostazioni.Button4Click(Sender: TObject);
begin
 if openpicturedialog1.execute then
  begin
   profbuon1.Picture.LoadFromFile(openpicturedialog1.filename);
   form1.profbuon.Picture:=profbuon1.Picture;
   if button12.enabled=false then
    button12.click;
   button12.enabled:=true;
  end;
end;

procedure Tfrmimpostazioni.Button5Click(Sender: TObject);
begin
 if openpicturedialog1.execute then
 begin
  profbuon2.Picture.LoadFromFile(openpicturedialog1.filename);
  if button13.enabled=false then
    button13.click;
   button13.enabled:=true;
  end;
end;

procedure Tfrmimpostazioni.Button6Click(Sender: TObject);
begin
 if openpicturedialog1.execute then
 begin
  profbuon3.Picture.LoadFromFile(openpicturedialog1.filename);
  if button14.enabled=false then
    button14.click;
   button14.enabled:=true;
  end;
end;

procedure Tfrmimpostazioni.Button7Click(Sender: TObject);
begin
 if openpicturedialog1.execute then
 begin
  bidella.Picture.LoadFromFile(openpicturedialog1.filename);
  if button15.enabled=false then
    button15.click;
   button15.enabled:=true;
  end;
end;

procedure Tfrmimpostazioni.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 screen.Cursor:= crDefault;
end;

procedure Tfrmimpostazioni.FormCreate(Sender: TObject);
var impossibile:boolean;
 lunghezza,i:integer;
begin

 if fileexists('dati/immagini/cattivi/1.jpg') then
  frmimpostazioni.profcatt1.Picture.LoadFromFile('dati/immagini/cattivi/1.jpg')
 else
  impossibile:=true;
 if fileexists('dati/immagini/cattivi/2.jpg') then
  frmimpostazioni.profcatt2.Picture.LoadFromFile('dati/immagini/cattivi/2.jpg')
 else
  impossibile:=true;
 if fileexists('dati/immagini/cattivi/3.jpg') then
  frmimpostazioni.profcatt3.Picture.LoadFromFile('dati/immagini/cattivi/3.jpg')
 else
  impossibile:=true;
 if fileexists('dati/immagini/buoni/1.jpg') then
  frmimpostazioni.profbuon1.Picture.LoadFromFile('dati/immagini/buoni/1.jpg')
 else
  impossibile:=true;
 if fileexists('dati/immagini/buoni/2.jpg') then
  frmimpostazioni.profbuon2.Picture.LoadFromFile('dati/immagini/buoni/2.jpg')
 else
  impossibile:=true;
 if fileexists('dati/immagini/buoni/3.jpg') then
  frmimpostazioni.profbuon3.Picture.LoadFromFile('dati/immagini/buoni/3.jpg')
 else
  impossibile:=true;
 if fileexists('dati/immagini/bidella/1.jpg') then
  frmimpostazioni.bidella.Picture.LoadFromFile('dati/immagini/bidella/1.jpg')
 else
  impossibile:=true;
 if impossibile=true then
  begin
   frmimpostazioni.Show;
   showmessage('Impossibile aprire una o più foto, controllare nella cartella immagini che siano presenti i file');
   timer1.enabled:=true;
  end;


  
 nomedir:=application.ExeName;
 lunghezza:=length(nomedir);
 for i:=lunghezza downto 1 do
 begin
 if nomedir[lunghezza]<>'\' then
  lunghezza:=lunghezza-1
 else
 begin
 nomedir:=copy(nomedir,1,lunghezza);
 exit
 end;
 end;
end;

procedure Tfrmimpostazioni.Button9Click(Sender: TObject);
begin
 profcatt1.Picture.SaveToFile(nomedir+'dati/immagini/cattivi/1.jpg');
end;

procedure Tfrmimpostazioni.Button10Click(Sender: TObject);
begin
 profcatt2.Picture.SaveToFile(nomedir+'dati/immagini/cattivi/2.jpg');
end;

procedure Tfrmimpostazioni.Button11Click(Sender: TObject);
begin
 profcatt3.Picture.SaveToFile(nomedir+'dati/immagini/cattivi/3.jpg');
end;

procedure Tfrmimpostazioni.Button12Click(Sender: TObject);
begin
 profbuon1.Picture.SaveToFile(nomedir+'dati/immagini/buoni/1.jpg');
end;

procedure Tfrmimpostazioni.Button13Click(Sender: TObject);
begin
 profbuon2.Picture.SaveToFile(nomedir+'dati/immagini/buoni/2.jpg');
end;

procedure Tfrmimpostazioni.Button14Click(Sender: TObject);
begin
 profbuon3.Picture.SaveToFile(nomedir+'dati/immagini/buoni/3.jpg');
end;

procedure Tfrmimpostazioni.Button15Click(Sender: TObject);
begin
 bidella.Picture.SaveToFile(nomedir+'dati/immagini/bidella/1.jpg');
end;

procedure Tfrmimpostazioni.Timer1Timer(Sender: TObject);
begin
 form1.Visible:=false;
 timer1.enabled:=false;
end;

procedure Tfrmimpostazioni.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 if form1.Visible=false then
 halt
end;

procedure Tfrmimpostazioni.Button8Click(Sender: TObject);
begin
 if form1.Visible=false then
  begin
   showmessage('E'' necessario riavviare il programma');
   halt;
  end;
  close
end;

end.
