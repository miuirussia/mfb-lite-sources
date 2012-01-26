object frmAddons: TfrmAddons
  Left = 0
  Top = 0
  Width = 616
  Height = 245
  TabOrder = 0
  DesignSize = (
    616
    245)
  object GroupBox1: TGroupBox
    Left = 3
    Top = 3
    Width = 610
    Height = 127
    Anchors = [akLeft, akTop, akRight]
    Caption = #1048#1085#1090#1077#1075#1088#1072#1094#1080#1103' '#1076#1086#1087#1086#1083#1085#1077#1085#1080#1081
    TabOrder = 0
    object chkCPUControl: TCheckBox
      Left = 16
      Top = 16
      Width = 217
      Height = 17
      Caption = #1048#1085#1090#1077#1075#1088#1080#1088#1086#1074#1072#1090#1100' CPU Control'
      TabOrder = 0
      OnClick = chkCPUControlClick
    end
    object chkKDGAddons: TCheckBox
      Left = 16
      Top = 39
      Width = 217
      Height = 17
      Caption = #1044#1086#1087#1086#1083#1085#1077#1085#1080#1103' '#1086#1090' KDG'
      TabOrder = 1
      OnClick = chkCPUControlClick
    end
    object chkKDGFont: TCheckBox
      Left = 16
      Top = 62
      Width = 217
      Height = 17
      Caption = #1064#1088#1080#1092#1090' '#1080#1079' Android 4.0'
      TabOrder = 2
      OnClick = chkCPUControlClick
    end
    object chkSonyBravia: TCheckBox
      Left = 16
      Top = 85
      Width = 233
      Height = 17
      Caption = #1059#1083#1091#1095#1096#1077#1085#1080#1077' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1103' Sony Bravia'
      TabOrder = 3
      OnClick = chkCPUControlClick
    end
    object chkSonyXLoud: TCheckBox
      Left = 239
      Top = 16
      Width = 258
      Height = 17
      Caption = #1059#1083#1091#1095#1096#1077#1085#1080#1077' '#1079#1074#1091#1082#1072' Sony XLoud'
      TabOrder = 4
      OnClick = chkCPUControlClick
    end
    object chkTheme: TCheckBox
      Left = 239
      Top = 39
      Width = 258
      Height = 17
      Caption = #1058#1077#1084#1072' '#1089' '#1080#1082#1086#1085#1082#1072#1084#1080
      TabOrder = 5
      OnClick = chkCPUControlClick
    end
    object chkPrepareOTA: TCheckBox
      Left = 239
      Top = 62
      Width = 258
      Height = 17
      Caption = #1055#1086#1076#1075#1086#1090#1086#1074#1080#1090#1100' '#1082' '#1086#1090#1087#1088#1072#1074#1082#1077' '#1085#1072' '#1089#1077#1088#1074#1077#1088' OTA'
      TabOrder = 6
      OnClick = chkCPUControlClick
    end
    object chkTranslate4Way: TCheckBox
      Left = 239
      Top = 85
      Width = 258
      Height = 17
      Caption = #1055#1077#1088#1077#1074#1077#1089#1090#1080' 4WayReboot ('#1042#1086#1079#1084#1086#1078#1085#1099' '#1086#1096#1080#1073#1082#1080')'
      TabOrder = 7
      OnClick = chkCPUControlClick
    end
    object chkMineField: TCheckBox
      Left = 16
      Top = 107
      Width = 217
      Height = 17
      Caption = #1052#1077#1090#1086#1076' MineField ('#1058#1077#1089#1090#1080#1088#1086#1074#1072#1085#1080#1077'!)'
      TabOrder = 8
      OnClick = chkMineFieldClick
    end
    object chkOdexAddon: TCheckBox
      Left = 239
      Top = 107
      Width = 258
      Height = 17
      Caption = #1054#1087#1090#1080#1084#1080#1079#1080#1088#1086#1074#1072#1090#1100' '#1087#1088#1086#1096#1080#1074#1082#1091' ('#1089#1084'. '#1087#1086#1076#1089#1082#1072#1079#1082#1091')'
      TabOrder = 9
      OnClick = chkCPUControlClick
    end
  end
  object lstDelete: TListBox
    Left = 3
    Top = 136
    Width = 586
    Height = 106
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 1
  end
  object btnAdd: TButton
    Left = 595
    Top = 136
    Width = 18
    Height = 17
    Anchors = [akTop, akRight]
    Caption = '+'
    TabOrder = 2
    OnClick = btnAddClick
  end
  object btnRemove: TButton
    Left = 595
    Top = 159
    Width = 18
    Height = 17
    Anchors = [akTop, akRight]
    Caption = '-'
    TabOrder = 3
    OnClick = btnRemoveClick
  end
end
