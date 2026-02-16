unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  Tfrmshowcirc = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label9: TLabel;
    Label8: TLabel;
    Label7bis: TLabel;
    Label6bis: TLabel;
    procedure Image1Click(Sender: TObject);
    procedure ckdbellanotiziaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmshowcirc: Tfrmshowcirc;

implementation

{$R *.dfm}

procedure Tfrmshowcirc.Image1Click(Sender: TObject);
begin
 close;
end;

procedure Tfrmshowcirc.ckdbellanotiziaClick(Sender: TObject);
begin
 label7.Visible:=true;
 label6.visible:=true;
 label6bis.visible:=false;
 label7bis.visible:=false;

end;

end.
