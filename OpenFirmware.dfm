object frmOpenFirmware: TfrmOpenFirmware
  Left = 0
  Top = 0
  Width = 567
  Height = 287
  TabOrder = 0
  object grpGeneralGroup: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 561
    Height = 86
    Align = alTop
    Caption = 
      #1059#1082#1072#1078#1080#1090#1077' '#1080#1089#1093#1086#1076#1085#1099#1081' '#1092#1072#1081#1083' '#1087#1088#1086#1096#1080#1074#1082#1080' '#1080', '#1077#1089#1083#1080' '#1085#1091#1078#1085#1086' '#1087#1072#1087#1082#1091' '#1089' '#1076#1086#1087#1086#1083#1085#1077#1085#1080#1103#1084 +
      #1080
    TabOrder = 0
    DesignSize = (
      561
      86)
    object Label1: TLabel
      Left = 22
      Top = 25
      Width = 71
      Height = 13
      Caption = 'Firmware File:'
    end
    object btnBrowseAddon: TButton
      Left = 520
      Top = 48
      Width = 26
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '...'
      Enabled = False
      TabOrder = 0
      OnClick = btnBrowseAddonClick
    end
    object btnBrowseFirmware: TButton
      Left = 520
      Top = 17
      Width = 26
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 1
      OnClick = btnBrowseFirmwareClick
    end
    object btnRepository: TButton
      Left = 428
      Top = 48
      Width = 86
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1056#1077#1087#1086#1079#1080#1090#1086#1088#1080#1081
      Enabled = False
      TabOrder = 2
    end
    object CheckBox1: TCheckBox
      Left = 32
      Top = 49
      Width = 61
      Height = 17
      Caption = 'Addons:'
      TabOrder = 3
      OnClick = CheckBox1Click
    end
    object edtFirmwareFile: TEdit
      Left = 99
      Top = 21
      Width = 415
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      OnChange = edtFirmwareFileChange
    end
    object edtAddonsFolder: TEdit
      Left = 99
      Top = 48
      Width = 323
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 5
      OnChange = edtAddonsFolderChange
    end
  end
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 95
    Width = 561
    Height = 189
    Align = alClient
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1076#1086#1087#1086#1083#1085#1077#1085#1080#1081
    TabOrder = 1
    object Label2: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 551
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = #1048#1085#1090#1077#1075#1088#1080#1088#1086#1074#1072#1090#1100' '#1089#1082#1088#1080#1087#1090' '#1091#1089#1090#1072#1085#1086#1074#1082#1080' ('#1076#1083#1103' '#1103#1076#1077#1088')'
      ExplicitWidth = 234
    end
    object CheckListBox1: TCheckListBox
      AlignWithMargins = True
      Left = 5
      Top = 34
      Width = 551
      Height = 150
      OnClickCheck = CheckListBox1ClickCheck
      Align = alClient
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.zip'
    Filter = 'Firmware File|*.zip'
    Left = 96
    Top = 32
  end
  object JvBrowseForFolderDialog1: TJvBrowseForFolderDialog
    Left = 40
    Top = 56
  end
end
