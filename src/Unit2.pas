unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, MPlayer;

type
  Tfrmcirc = class(TForm)
    Button1: TButton;
    ckdcirc1: TRadioButton;
    ckdcirc2: TRadioButton;
    Label1: TLabel;
    Image1: TImage;
    MediaPlayer1: TMediaPlayer;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmcirc: Tfrmcirc;

implementation

uses Unit1, Unit4;

{$R *.dfm}

procedure Tfrmcirc.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 form1.timer1.enabled:=true;
end;

procedure Tfrmcirc.Button1Click(Sender: TObject);
var numero,numeroscelto:integer;
begin
 randomize;
 numero:=random(2)+1;
 //showmessage(inttostr(numero));
 if ckdcirc1.checked=true then
  numeroscelto:=1
 else
  numeroscelto:=2;

 if numero=numeroscelto then
  begin
   with frmshowcirc do
    begin
     label7.Visible:=true;
     label6.visible:=true;
     label6bis.visible:=false;
     label7bis.visible:=false;
     form1.profcolpiti.caption:=inttostr(strtoint(form1.profcolpiti.caption)+100);
     if form1.ckdsuoni.checked=true then
     begin
     MediaPlayer1.FileName:='dati\suoni\siii.wav';
     MediaPlayer1.open;
     MediaPlayer1.Play;
     end;
    end;
   end
    //frmshowcirc.ckdbellanotizia.checked:=true
   else
    begin
     with frmshowcirc do
      begin
       label7.Visible:=false;
       label6.visible:=false;
       label6bis.visible:=true;
       label7bis.visible:=true;
       form1.profcolpiti.caption:=inttostr(strtoint(form1.profcolpiti.caption)-100);
       if form1.ckdsuoni.checked=true then
        begin
       MediaPlayer1.FileName:='dati\suoni\nooo.wav';
       MediaPlayer1.open;
       MediaPlayer1.Play;
       end;
     end;
    end;
  close;
  frmshowcirc.Showmodal;
end;

procedure Tfrmcirc.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 screen.Cursor:= crDefault;
end;

end.
