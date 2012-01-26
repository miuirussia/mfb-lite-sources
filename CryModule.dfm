object CryMode: TCryMode
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'CryptModule'
  ClientHeight = 85
  ClientWidth = 209
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object UbuntuProgress1: TUbuntuProgress
    Left = 24
    Top = 58
    Width = 171
    Height = 19
    ColorSet = csOriginal
    ProgressDividers = True
    BackgroundDividers = True
    MarqueeWidth = 30
    Max = 100
    Mode = pmNormal
    Position = 0
    Shadow = True
    Speed = msMedium
    Step = 1
    Visible = True
  end
  object Button1: TButton
    Left = 24
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Crypt All'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 120
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Decrypt All'
    TabOrder = 1
    OnClick = Button2Click
  end
end
