object frmimpostazioni: Tfrmimpostazioni
  Left = 329
  Top = 182
  Width = 551
  Height = 455
  Caption = 'Imposta immagini'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnMouseMove = FormMouseMove
  PixelsPerInch = 96
  TextHeight = 13
  object profcatt1: TImage
    Left = 32
    Top = 88
    Width = 100
    Height = 120
    Stretch = True
  end
  object profcatt2: TImage
    Left = 152
    Top = 88
    Width = 100
    Height = 120
    Stretch = True
  end
  object profcatt3: TImage
    Left = 272
    Top = 88
    Width = 100
    Height = 120
    Stretch = True
  end
  object profbuon1: TImage
    Left = 32
    Top = 280
    Width = 100
    Height = 120
    Stretch = True
  end
  object profbuon2: TImage
    Left = 152
    Top = 280
    Width = 100
    Height = 120
    Stretch = True
  end
  object profbuon3: TImage
    Left = 272
    Top = 280
    Width = 100
    Height = 120
    Stretch = True
  end
  object bidella: TImage
    Left = 424
    Top = 160
    Width = 100
    Height = 120
    Stretch = True
  end
  object Label1: TLabel
    Left = 40
    Top = 40
    Width = 90
    Height = 13
    Caption = 'Prof 1 "cattivo"'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 152
    Top = 40
    Width = 90
    Height = 13
    Caption = 'Prof 2 "cattivo"'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 280
    Top = 40
    Width = 90
    Height = 13
    Caption = 'Prof 3 "cattivo"'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 40
    Top = 232
    Width = 86
    Height = 13
    Caption = 'Prof 1 "buono"'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 160
    Top = 232
    Width = 86
    Height = 13
    Caption = 'Prof 2 "buono"'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 280
    Top = 232
    Width = 86
    Height = 13
    Caption = 'Prof 3 "buono"'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 448
    Top = 104
    Width = 39
    Height = 13
    Caption = 'Bidella'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label8: TLabel
    Left = 136
    Top = 8
    Width = 187
    Height = 24
    Caption = 'IMPOSTA LE FOTO'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 38
    Top = 64
    Width = 41
    Height = 17
    Caption = 'Carica'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 160
    Top = 64
    Width = 41
    Height = 17
    Caption = 'Carica'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 278
    Top = 64
    Width = 41
    Height = 17
    Caption = 'Carica'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 40
    Top = 256
    Width = 41
    Height = 17
    Caption = 'Carica'
    TabOrder = 3
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 160
    Top = 256
    Width = 41
    Height = 17
    Caption = 'Carica'
    TabOrder = 4
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 277
    Top = 256
    Width = 41
    Height = 17
    Caption = 'Carica'
    TabOrder = 5
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 432
    Top = 136
    Width = 41
    Height = 17
    Caption = 'Carica'
    TabOrder = 6
    OnClick = Button7Click
  end
  object Button9: TButton
    Left = 86
    Top = 64
    Width = 41
    Height = 17
    Caption = 'Salva'
    Enabled = False
    TabOrder = 7
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 208
    Top = 64
    Width = 41
    Height = 17
    Caption = 'Salva'
    Enabled = False
    TabOrder = 8
    OnClick = Button10Click
  end
  object Button11: TButton
    Left = 326
    Top = 64
    Width = 41
    Height = 17
    Caption = 'Salva'
    Enabled = False
    TabOrder = 9
    OnClick = Button11Click
  end
  object Button12: TButton
    Left = 88
    Top = 256
    Width = 41
    Height = 17
    Caption = 'Salva'
    Enabled = False
    TabOrder = 10
    OnClick = Button12Click
  end
  object Button13: TButton
    Left = 208
    Top = 256
    Width = 41
    Height = 17
    Caption = 'Salva'
    Enabled = False
    TabOrder = 11
    OnClick = Button13Click
  end
  object Button14: TButton
    Left = 325
    Top = 256
    Width = 41
    Height = 17
    Caption = 'Salva'
    Enabled = False
    TabOrder = 12
    OnClick = Button14Click
  end
  object Button15: TButton
    Left = 480
    Top = 136
    Width = 41
    Height = 17
    Caption = 'Salva'
    Enabled = False
    TabOrder = 13
    OnClick = Button15Click
  end
  object Button8: TButton
    Left = 440
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 14
    OnClick = Button8Click
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 'JPEG Image File (*.jpg)|*.jpg'
    Left = 16
    Top = 32
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 200
    OnTimer = Timer1Timer
    Left = 408
    Top = 56
  end
end
