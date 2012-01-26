object HelpForm: THelpForm
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = #1057#1087#1088#1072#1074#1082#1072
  ClientHeight = 351
  ClientWidth = 508
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object HelpContent: TRichEdit
    Left = 0
    Top = 0
    Width = 508
    Height = 351
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    Lines.Strings = (
      'HelpContent')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitWidth = 418
    ExplicitHeight = 216
  end
end
