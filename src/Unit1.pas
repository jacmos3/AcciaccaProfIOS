unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, MPlayer, jpeg, shellapi, FileCtrl;

type
  TForm1 = class(TForm)
    Image1: TImage;
    profbuon: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    Image17: TImage;
    Image18: TImage;
    Image19: TImage;
    Image21: TImage;
    Image22: TImage;
    Image23: TImage;
    Image24: TImage;
    Image25: TImage;
    Image26: TImage;
    Image27: TImage;
    Image28: TImage;
    Image29: TImage;
    Timer1: TTimer;
    Image30: TImage;
    Image31: TImage;
    Image32: TImage;
    Button1: TButton;
    Image33: TImage;
    Image34: TImage;
    Image35: TImage;
    profcatt: TImage;
    bidella: TImage;
    Label2: TLabel;
    Button17: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    profcolpiti: TLabel;
    profsfuggiti: TLabel;
    colpisbagliati: TLabel;
    Label9: TLabel;
    Button18: TButton;
    GroupBox1: TGroupBox;
    ckdlivello1: TRadioButton;
    ckdlivello2: TRadioButton;
    ckdlivello3: TRadioButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Image20: TImage;
    schizzi: TImage;
    Timer2: TTimer;
    Timer3: TTimer;
    zampilli1: TImage;
    zampilli2: TImage;
    zampilli3: TImage;
    Timer4: TTimer;
    lblvoto: TLabel;
    Label1: TLabel;
    MediaPlayer1: TMediaPlayer;
    MediaPlayer2: TMediaPlayer;
    ckdsottofondo: TCheckBox;
    ckdsuoni: TCheckBox;
    btnupvelocita: TButton;
    btndownvelocita: TButton;
    Editvelocita: TEdit;
    Image2: TImage;
    procedure Timer1Timer(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure profbuonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure profcattMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button8Click(Sender: TObject);
    procedure ckdlivello1Click(Sender: TObject);
    procedure ckdlivello2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditvelocitaKeyPress(Sender: TObject; var Key: Char);
    procedure bidellaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button17Click(Sender: TObject);
    procedure ckdlivello3Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer3Timer(Sender: TObject);
    procedure Image30MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image32MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image34MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer4Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Label1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Label1Click(Sender: TObject);
    procedure ckdsottofondoClick(Sender: TObject);
    procedure btnupvelocitaClick(Sender: TObject);
    procedure btndownvelocitaClick(Sender: TObject);
    procedure bambinomorto;
    procedure profmorto;
    procedure fuori;
    procedure bidellasound;
    procedure sottofondo;
    procedure bidellaa;
    procedure profcattivo;
    procedure profbuono;
    procedure scorribidella;
    procedure scorribuono;
    procedure scorricattivo;
    procedure resettabidella;
    procedure resettabuono;
    procedure resettacattivo;
    procedure Image2Click(Sender: TObject);
    procedure Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  alzatecatt,alzatebuon,alzatebidella:integer;
  mouse,attivabidella:boolean;
  nomedir:string;
  posizioni: array[0..25] of integer;
implementation

uses Unit2, Unit3;

{$R *.dfm}

procedure inizializzaposizioni;
begin
 posizioni[0]:=56;
 posizioni[1]:=26;

 posizioni[3]:=200;
 posizioni[4]:=26;

 posizioni[6]:=352;
 posizioni[7]:=26;

 posizioni[9]:=80;
 posizioni[10]:=162;

 posizioni[12]:=224;
 posizioni[13]:=162;

 posizioni[15]:=376;
 posizioni[16]:=162;

 posizioni[18]:=48;
 posizioni[19]:=290;

 posizioni[21]:=192;
 posizioni[22]:=290;

 posizioni[24]:=344;
 posizioni[25]:=290;
end;


procedure martellosu;
var
  Cursore : THandle;
begin
  if FileExists('dati\cursori\martsu.cur') then
  begin
    Cursore := LoadImage(0,'dati\cursori\martsu.cur',IMAGE_CURSOR,0,0,
                              LR_DEFAULTSIZE or LR_LOADFROMFILE);
    if Cursore <> 0 then
      Screen.Cursors[1] := Cursore;
  end;
end;

procedure martellogiu;
var
  Cursore : THandle;
begin
  if FileExists('dati\cursori\martgiu.cur') then
  begin
    Cursore := LoadImage(0,'dati\cursori\martgiu.cur',IMAGE_CURSOR,0,0,
                              LR_DEFAULTSIZE or LR_LOADFROMFILE);
    if Cursore <> 0 then
      Screen.Cursors[1] := Cursore;
  end;
  end;

procedure tform1.bambinomorto();
begin
 if (ckdsuoni.checked=true) and  (fileexists(nomedir+'dati\suoni\bambinomorto.wav')) then
  begin
   MediaPlayer1.FileName:=nomedir+'dati\suoni\bambinomorto.wav';
   MediaPlayer1.open;
  //MediaPlayer1.Wait:=true;
   MediaPlayer1.Play;

   if not fileexists(nomedir+'dati\suoni\bambinomorto.wav') then
   begin
    showmessage('Impossibile trovare il file "'+nomedir+'dati\suoni\bambinomorto.wav"');
    ckdsuoni.Checked:=false;
   end;
  end;
end;

procedure tform1.profmorto();
begin
 if (ckdsuoni.checked=true)  and  (fileexists(nomedir+'dati\suoni\profmorto.wav'))  then
  begin
  MediaPlayer1.FileName:=nomedir+'dati\suoni\profmorto.wav';
   MediaPlayer1.open;
  // MediaPlayer1.Wait:=true;
   MediaPlayer1.Play;

  if not fileexists(nomedir+'dati\suoni\profmorto.wav') then
   begin
    showmessage('Impossibile trovare il file "'+nomedir+'dati\suoni\profmorto.wav"');
    ckdsuoni.Checked:=false;
   end;
 end;
end;

procedure tform1.fuori();
begin
 if (ckdsuoni.checked=true)  and  (fileexists(nomedir+'dati\suoni\fuori.wav')) then
  begin
   MediaPlayer1.FileName:=nomedir+'dati\suoni\fuori.wav';
   MediaPlayer1.open;
   //MediaPlayer1.Wait:=true;
   MediaPlayer1.Play;

  if not fileexists(nomedir+'dati\suoni\fuori.wav') then
   begin
    showmessage('Impossibile trovare il file "'+nomedir+'dati\suoni\fuori.wav"');
    ckdsuoni.Checked:=false;
   end;
  end;
end;

procedure tform1.bidellasound();
begin
if ckdsuoni.checked=true then
  begin
   MediaPlayer1.FileName:=nomedir+'dati\suoni\bidella.wav';
   MediaPlayer1.open;
   //MediaPlayer1.Wait:=true;
   MediaPlayer1.Play;
  end;
end;

procedure TForm1.ckdsottofondoClick(Sender: TObject);
begin
 if ckdsottofondo.checked=true then
  begin
   if not fileexists(nomedir+'dati/suoni/sottofondo.mp3') then
    begin
     showmessage('Impossibile riprodurre il file, "dati/suoni/sottofondo.mp3" non esiste!');
     ckdsottofondo.Checked:=false;
     exit
    end
   else
    sottofondo;
  end
 else
 if  fileexists(nomedir+'dati/suoni/sottofondo.mp3') then
  MediaPlayer2.stop;
end;

procedure tform1.sottofondo();
begin
    MediaPlayer2.FileName:=nomedir+'dati\suoni\sottofondo.mp3';
    MediaPlayer2.open;
    MediaPlayer2.Play;
end;

procedure tform1.bidellaa();
var i:integer;
begin
 bidella.Height:=100;
 alzatebidella:=0;
 randomize;
 i:=random(9)+1;
 case  i of
 1: begin
     bidella.left:=posizioni[0];
     bidella.Top:=posizioni[1]+110;
    end;
 2: begin
     bidella.left:=posizioni[3];
     bidella.Top:=posizioni[4]+110;
    end;
 3: begin
     bidella.left:=posizioni[6];
     bidella.Top:=posizioni[7]+110;
    end;
 4: begin
     bidella.left:=posizioni[9];
     bidella.Top:=posizioni[10]+110;
    end;
 5: begin
     bidella.left:=posizioni[12];
     bidella.Top:=posizioni[13]+110;
    end;
 6: begin
     bidella.left:=posizioni[15];
     bidella.Top:=posizioni[16]+110;
    end;
 7: begin
     bidella.left:=posizioni[18];
     bidella.Top:=posizioni[19]+110;
    end;
 8: begin
     bidella.left:=posizioni[21];
     bidella.Top:=posizioni[22]+110;
    end;
 9: begin
     bidella.left:=posizioni[24];
     bidella.Top:=posizioni[25]+110;
    end;
 end;
 resettabidella;
 end;

procedure tform1.profcattivo();
var i,numero:integer;
begin
 //ora sceglie un prof cattivo dalla lista
 if ckdlivello3.checked=true then
 begin
  randomize;
  numero:=random(3)+1;
  if numero=1 then
   profcatt.Picture:=frmimpostazioni.profcatt1.Picture
  else
  if numero=2 then
   profcatt.Picture:=frmimpostazioni.profcatt2.Picture
  else
  if numero=3 then
   profcatt.Picture:=frmimpostazioni.profcatt3.Picture;
  end;

 profcatt.Height:=100;
 alzatecatt:=0;
 randomize;
 i:=random(9)+1;
 case  i of
 1: begin
     profcatt.left:=posizioni[0];
     profcatt.Top:=posizioni[1]+110;
    end;
 2: begin
     profcatt.left:=posizioni[3];
     profcatt.Top:=posizioni[4]+110;
    end;
 3: begin
     profcatt.left:=posizioni[6];
     profcatt.Top:=posizioni[7]+110;
    end;
 4: begin
     profcatt.left:=posizioni[9];
     profcatt.Top:=posizioni[10]+110;
    end;
 5: begin
     profcatt.left:=posizioni[12];
     profcatt.Top:=posizioni[13]+110;
    end;
 6: begin
     profcatt.left:=posizioni[15];
     profcatt.Top:=posizioni[16]+110;
    end;
 7: begin
     profcatt.left:=posizioni[18];
     profcatt.Top:=posizioni[19]+110;
    end;
 8: begin
     profcatt.left:=posizioni[21];
     profcatt.Top:=posizioni[22]+110;
    end;
 9: begin
     profcatt.left:=posizioni[24];
     profcatt.Top:=posizioni[25]+110;
    end;
 end;
 resettacattivo;
end;

procedure tform1.profbuono();
var i,numero:integer;
begin
// e ora uno buon
if ckdlivello3.checked=true then
 begin
   randomize;
   numero:=random(3)+1;
   if numero=1 then
   profbuon.Picture:=frmimpostazioni.profbuon1.Picture
  else
  if numero=2 then
   profbuon.Picture:=frmimpostazioni.profbuon2.Picture
  else
  if numero=3 then
   profbuon.Picture:=frmimpostazioni.profbuon3.Picture;
 end;


 profbuon.Height:=100;
 alzatebuon:=0;
 randomize;
 i:=random(9)+1;
 case  i of
 1: begin
     profbuon.left:=posizioni[0];
     profbuon.Top:=posizioni[1]+110;
    end;
 2: begin
     profbuon.left:=posizioni[3];
     profbuon.Top:=posizioni[4]+110;
    end;
 3: begin
     profbuon.left:=posizioni[6];
     profbuon.Top:=posizioni[7]+110;
    end;
 4: begin
     profbuon.left:=posizioni[9];
     profbuon.Top:=posizioni[10]+110;
    end;
 5: begin
     profbuon.left:=posizioni[12];
     profbuon.Top:=posizioni[13]+110;
    end;
 6: begin
     profbuon.left:=posizioni[15];
     profbuon.Top:=posizioni[16]+110;
    end;
 7: begin
     profbuon.left:=posizioni[18];
     profbuon.Top:=posizioni[19]+110;
    end;
 8: begin
     profbuon.left:=posizioni[21];
     profbuon.Top:=posizioni[22]+110;
    end;
 9: begin
     profbuon.left:=posizioni[24];
     profbuon.Top:=posizioni[25]+110;
    end;
 end;
 resettabuono;
end;

procedure tform1.scorribidella();
begin
//fa scorrere la bidella
 if bidella.height <121 then
  bidella.Height:=bidella.Height+strtoint(editvelocita.text);
 if alzatebidella<120/(strtoint(editvelocita.text)) then
  begin
   bidella.top:=bidella.top-strtoint(editvelocita.text);
   alzatebidella:=alzatebidella+1;
  end
  else
   begin
    attivabidella:=false;
    bidellaa;
   end;
end;

procedure tform1.scorribuono();
begin
//fa scorrere il prof buono
 if profbuon.height <121 then
  profbuon.Height:=profbuon.Height+strtoint(editvelocita.text) ;
 if alzatebuon<120/strtoint(editvelocita.text) then
  begin
   profbuon.top:=profbuon.top-strtoint(editvelocita.text);
   alzatebuon:=alzatebuon+1
   end
  else
   begin
    profbuono;
   end;
end;

procedure tform1.scorricattivo();
begin
//fa scorrere il prof cattivo
 if profcatt.height <120 then
  profcatt.Height:=profcatt.Height+strtoint(editvelocita.text) ;
 if alzatecatt<120 /strtoint(editvelocita.text) then
  begin
   profcatt.top:=profcatt.top-strtoint(editvelocita.text);
   alzatecatt:=alzatecatt+1
  end
 else
  begin
   profcattivo;
   profsfuggiti.caption:=inttostr(strtoint(profsfuggiti.caption)+1); //penalità
  end;
end;

procedure tform1.resettabidella();
begin
 bidella.Top:=bidella.Top+bidella.Height;
 bidella.Height:=1;
end;

procedure tform1.resettabuono();
begin
//posiziona l'immagine del prof buono, e la resetta per una prossima alzata
 profbuon.Top:=profbuon.Top+profbuon.Height;
 profbuon.Height:=1;
end;

procedure tform1.resettacattivo();
begin
//posiziona l'immagine del prof cattivo, e la resetta per una prossima alzata
 profcatt.Top:=profcatt.Top+profcatt.Height;
 profcatt.Height:=1;
end;






procedure TForm1.Timer1Timer(Sender: TObject);
var numero:integer;
begin
 if ckdlivello1.checked=true then
  begin
  profcatt.Picture:=frmimpostazioni.profcatt1.Picture;
   profbuon.Picture:=frmimpostazioni.profbuon1.Picture;
   scorricattivo;
  end
 else
 if ckdlivello2.checked =true then
  begin
   profcatt.Picture:=frmimpostazioni.profcatt1.Picture;
   profbuon.Picture:=frmimpostazioni.profbuon1.Picture;
   scorricattivo;
   scorribuono;
  end
 else
 if ckdlivello3.Checked= true then
  begin
  bidella.Picture:=frmimpostazioni.bidella.Picture;
  


   if attivabidella=true then
    scorribidella
   else
   if random(100)+1= 30 then
    begin
     attivabidella:=true;
     scorribidella;
    end
   else
    begin
     scorricattivo;
     scorribuono;
    end;
  end;
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
 if timer1.enabled=true then
 colpisbagliati.Caption:=inttostr(strtoint(colpisbagliati.caption)+1);
 //label1.caption:=inttostr(strtoint(label1.caption)-1);//penalità di 1 punti
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
showmessage('Apparirà una sola immagine alla volta, se la colpisci guadagni punti, se non la colpisci, o se sbagli a colpirla perdi punti');
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
 showmessage('Appariranno 1 prof "buono" e 1 prof "cattivo". Se colpisci quello "buono" perdi punti se colpisci quello "cattivo" li guadagni');
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 screen.Cursor:= crDefault;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
 NuovoCursore: Integer;
begin
 martellosu;
  NuovoCursore := Screen.Cursor;
  Screen.Cursor := 1;
  image1.Cursor := NuovoCursore
end;

procedure TForm1.profbuonMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

var
 NuovoCursore: Integer;
begin
  martellogiu;
  NuovoCursore := Screen.Cursor;
  Screen.Cursor := 1;
  profcatt.Cursor := NuovoCursore;

  schizzi.Top:=profbuon.Top+y-25;
  schizzi.Left:=profbuon.left+x-45;
  schizzi.visible:=true;
  timer3.Enabled:=true;

  (* if ckdlivello1.Checked=false then
  timer1.Interval:=timer1.Interval+2;    *)

 //button11.click;
 colpisbagliati.caption:=inttostr(strtoint(colpisbagliati.caption)+1);
 //lblvoto.caption:=inttostr(strtoint(label1.caption)-punteggionegativo);
 profcattivo;
 bidellaa;
 attivabidella:=false;
 refresh;
 profmorto;
end;

procedure TForm1.profcattMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 NuovoCursore: Integer;
begin
  martellogiu;
  NuovoCursore := Screen.Cursor;
  Screen.Cursor := 1;
  profcatt.Cursor := NuovoCursore;

  schizzi.Top:=profcatt.Top+y-25;
  schizzi.Left:=profcatt.left+x-45;
  schizzi.visible:=true;

   profcattivo;
  timer2.Enabled:=true;

  profcolpiti.caption:=inttostr(strtoint(profcolpiti.caption)+1);

 (* if ckdlivello1.Checked=false then
  timer1.Interval:=timer1.Interval-2;*)

   profbuono;
   bidellaa;
   attivabidella:=false;
   refresh;
  profmorto;
  
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
 showmessage('Come il livello 2 solo che i prof buoni e cattivi sono scelti a caso tra quelli salvati, e ci sarà la bidella che ogni tanto porta circolari...');
end;

procedure TForm1.ckdlivello1Click(Sender: TObject);
begin
 //lblvoto.Visible:=false;
 //lblvoto.Caption:='1';
 profcatt.Left:=800;
 profbuon.Left:=800;
 bidella.Left:=800;
end;

procedure TForm1.ckdlivello2Click(Sender: TObject);
begin
 //lblvoto.Visible:=false;
 //lblvoto.Caption:='1';
 profcatt.Left:=800;
 profbuon.Left:=800;
 bidella.Left:=800;
end;

procedure TForm1.FormCreate(Sender: TObject);
var lunghezza,i:integer;
begin
 attivabidella:=false;


 nomedir:=application.ExeName;
 lunghezza:=length(nomedir);
 for i:=lunghezza downto 1 do
  begin
   if nomedir[lunghezza]<>'\' then
    lunghezza:=lunghezza-1
   else
    begin
     nomedir:=copy(nomedir,1,lunghezza);
     //openpicturedialog1.FileName:=(nomedir);
     exit
    end;
  end;

end;

procedure TForm1.EditvelocitaKeyPress(Sender: TObject; var Key: Char);
begin
 if not (ord(key) in [48..57] ) then
  key:=chr(0);
end;

procedure TForm1.bidellaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 NuovoCursore: Integer;
begin
  martellogiu;
  NuovoCursore := Screen.Cursor;
  Screen.Cursor := 1;
  profcatt.Cursor := NuovoCursore;
  profcattivo;
  timer1.enabled:=false;

  refresh;
  bidellasound;
  frmcirc.showmodal;
  attivabidella:=false;
  bidellaa;

 end;

procedure TForm1.Button17Click(Sender: TObject);
var colpiti, sfuggiti, sbagliati,voto,totali:integer;
begin
 inizializzaposizioni;
 profcattivo;
 profbuono;
 bidellaa;
 lblvoto.Visible:=true;
 timer1.enabled:=not timer1.enabled;
 if button17.caption='Start' then
  begin
   button17.caption:='Stop';
   btnUpvelocita.Enabled:=false;
   btnDownvelocita.Enabled:=false;
   button18.Visible:=true;
   groupbox1.Enabled:=false;
   profcolpiti.caption:='0';
   profsfuggiti.caption:='0';
   colpisbagliati.caption:='0';
   lblvoto.caption:='0';
  end
 else
  begin
  if button18.caption='Riprendi' then
   button18.click;
   button17.caption:='Start' ;
   btnUpvelocita.Enabled:=true;
   btnDownvelocita.Enabled:=true;
   button18.visible:=false;
   groupbox1.Enabled:=true;

  //ORA CALCOLA IL VOTO
  //N.B. la scelta del voto è molto severa..cosi invoglia la gente a colpire con più gusto i prof hehe
   colpiti:=strtoint(profcolpiti.caption);
     sfuggiti:=(strtoint(profsfuggiti.caption));
     sbagliati:=(strtoint(colpisbagliati.caption));
     totali:=colpiti+sfuggiti+sbagliati;
 //    if ckdlivello1.checked=true then
      voto:=((colpiti-sfuggiti)- ((2)* sbagliati)) ;
 //    else

                   if totali<1 then totali:=1;
    if ((voto * 10)div totali) <=0 then //se il voto verrebbe negativo allora metti il voto 1 altrimetni mette il voto da 2 a 10
     lblvoto.caption:='1'
    else
    lblvoto.caption:=(inttostr((voto * 10)div totali))
   // lblvoto.caption:=copy((floattostr((voto * 10)/ totali)),0,3) ;
  end;
end;

procedure TForm1.ckdlivello3Click(Sender: TObject);
begin
 //lblvoto.Visible:=false;
 //lblvoto.Caption:='1';
 profcatt.Left:=800;
 profbuon.Left:=800;
 bidella.Left:=800;
end;

procedure TForm1.Button18Click(Sender: TObject);
begin
 profcattivo;
 profbuono;
 bidellaa;
 timer1.enabled:=not timer1.enabled;
  if button18.caption='Pausa' then
  begin
   button18.caption:='Riprendi';
   //editvelocita.Enabled:=false;
  end
 else
  begin
   button18.caption:='Pausa' ;
   //editvelocita.Enabled:=true;
  end;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
 schizzi.Visible:=false;
 timer2.Enabled:=false;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 NuovoCursore: Integer;
begin
  martellogiu;
 // NuovoCursore := Screen.Cursor;
  //Screen.Cursor := 1;
  //image1.Cursor := NuovoCursore;
  refresh;
  fuori;
end;

procedure TForm1.Timer3Timer(Sender: TObject);
begin
 profbuono;
 schizzi.Visible:=false;
 timer3.Enabled:=false;
end;

procedure TForm1.Image30MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 NuovoCursore: Integer;
begin
  martellogiu;
  NuovoCursore := Screen.Cursor;
  Screen.Cursor := 1;
  profcatt.Cursor := NuovoCursore;
  zampilli1.Visible:=true;
  refresh;
  timer4.enabled:=true;

  bambinomorto;
end;

procedure TForm1.Image32MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 NuovoCursore: Integer;
begin
  martellogiu;
  NuovoCursore := Screen.Cursor;
  Screen.Cursor := 1;
  profcatt.Cursor := NuovoCursore;
  zampilli2.Visible:=true;
  refresh;
  timer4.enabled:=true;
  bambinomorto;
end;

procedure TForm1.Image34MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 NuovoCursore: Integer;
begin
  martellogiu;
  NuovoCursore := Screen.Cursor;
  Screen.Cursor := 1;
  profcatt.Cursor := NuovoCursore;
  zampilli3.Visible:=true;
  refresh;
  timer4.enabled:=true;
  bambinomorto;
end;

procedure TForm1.Timer4Timer(Sender: TObject);
begin
//questo timer tiene il conto di quanto devono restare visibili gli zampilli di sangue
// che escono quando si colpiscono i bambini
 zampilli1.Visible:=false;
 zampilli2.Visible:=false;
 zampilli3.Visible:=false;
 timer4.enabled:=false;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 frmimpostazioni.show;
end;

procedure TForm1.Label1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 screen.Cursor:= crDefault;
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
 ShellExecute(Application.Handle,'Open',PansiChar('http://www.moscio88.altervista.org/SAP.php'),'','',SW_SHOW);

end;

procedure TForm1.btnupvelocitaClick(Sender: TObject);
begin
if editvelocita.text<>'20' then
 editvelocita.text:=inttostr(strtoint(editvelocita.text)+1);
end;

procedure TForm1.btndownvelocitaClick(Sender: TObject);
begin
if editvelocita.text<>'1' then
 editvelocita.text:=inttostr(strtoint(editvelocita.text)-1);
end;

procedure TForm1.Image2Click(Sender: TObject);
begin
 ShellExecute(Application.Handle,'Open',PansiChar('http://www.pierotofy.it'),'','',SW_SHOW);
end;

procedure TForm1.Image2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 screen.Cursor:= crDefault;
end;

end.

