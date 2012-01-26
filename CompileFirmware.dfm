object frmCompileFirmware: TfrmCompileFirmware
  Left = 0
  Top = 0
  Width = 560
  Height = 202
  TabOrder = 0
  DesignSize = (
    560
    202)
  object Label1: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 554
    Height = 13
    Align = alTop
    Caption = #1048#1085#1092#1086#1088#1084#1072#1094#1080#1103' '#1086' '#1087#1088#1086#1096#1080#1074#1082#1077':'
    ExplicitWidth = 143
  end
  object UbuntuProgress1: TUbuntuProgress
    AlignWithMargins = True
    Left = 19
    Top = 172
    Width = 535
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
  object Memo1: TMemo
    AlignWithMargins = True
    Left = 30
    Top = 19
    Width = 527
    Height = 110
    Margins.Left = 30
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    TabOrder = 0
  end
  object Button1: TButton
    Left = 232
    Top = 141
    Width = 109
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    Caption = #1050#1086#1084#1087#1080#1083#1080#1088#1086#1074#1072#1090#1100
    TabOrder = 1
    OnClick = Button1Click
  end
end
