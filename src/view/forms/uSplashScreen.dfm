object SplashScreen: TSplashScreen
  Left = 0
  Top = 0
  Cursor = crHourGlass
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'SplashScreen'
  ClientHeight = 358
  ClientWidth = 496
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object iSplash: TImage
    Left = 0
    Top = 0
    Width = 496
    Height = 358
    Align = alClient
    Stretch = True
    ExplicitLeft = 128
    ExplicitTop = 96
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object iLogo: TImage
    Left = 30
    Top = 30
    Width = 64
    Height = 64
    Stretch = True
    Transparent = True
  end
  object cxLCopyright: TcxLabel
    Left = 30
    Top = 332
    AutoSize = False
    Caption = '(c) 2007 - 2015 Sebastian Klatte. All rights reserved.'
    ParentColor = False
    Style.Color = clBlack
    Style.TextColor = clWhite
    Style.TextStyle = [fsBold]
    Transparent = True
    Height = 18
    Width = 299
  end
  object cxLProgrammName: TcxLabel
    Left = 112
    Top = 30
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -32
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.TextStyle = [fsBold]
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLProgrammBuild: TcxLabel
    Left = 112
    Top = 67
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -19
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.TextStyle = [fsBold]
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cxLPleaseDonate: TcxLabel
    Left = 30
    Top = 252
    Caption = 'If you like this program, please consider a donation. '
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -16
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.TextColor = clWhite
    Style.TextStyle = [fsBold]
    Style.IsFontAssigned = True
    Transparent = True
  end
end
