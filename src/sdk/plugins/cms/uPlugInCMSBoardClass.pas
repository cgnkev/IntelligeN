{ ********************************************************
  *                            IntelligeN PLUGIN SYSTEM  *
  *  PlugIn content management system class              *
  *  Version 2.5.0.0                                     *
  *  Copyright (c) 2016 Sebastian Klatte                 *
  *                                                      *
  ******************************************************** }
unit uPlugInCMSBoardClass;

interface

uses
  // Delphi
  SysUtils,
  // Common
  uBaseConst, uBaseInterface,
  // HTTPManager
  uHTTPInterface, uHTTPClasses, uHTTPConst,
  // Plugin system
  uPlugInConst, uPlugInCMSClass, uPlugInHTTPClasses;

type
  TCMSBoardPlugInSettings = class(TCMSPlugInSettings)
  strict private
    fforums, fthreads: Variant;
  published
    property forums: Variant read fforums write fforums;
    property threads: Variant read fthreads write fthreads;
  end;

  TCMSBoardPlugIn = class(TCMSPlugIn)
  private
    FPostReply: Boolean;
  protected
    property PostReply: Boolean read FPostReply write FPostReply;
  public
    property AccountName;
    property AccountPassword;
    property SettingsFileName;
    property Subject;
    property Tags;
    property Message;
    property Website;

    property ArticleID;

    function GetCMSType: TCMSType; override; safecall;
  end;

  TCMSBoardIPPlugInSettings = class(TCMSBoardPlugInSettings)
  strict private
    fintelligent_posting, fintelligent_posting_helper: Boolean;

    fprefix, ficon: Variant;
  public
    constructor Create; override;
  published
    property intelligent_posting: Boolean read fintelligent_posting write fintelligent_posting;
    property intelligent_posting_helper: Boolean read fintelligent_posting_helper write fintelligent_posting_helper;

    property prefix: Variant read fprefix write fprefix;
    property icon: Variant read ficon write ficon;
  end;

  TCMSBoardIPPlugIn = class(TCMSBoardPlugIn)
  protected
    function NeedBeforePostAction: Boolean; override;
    function DoBeforePostAction(var ARequestID: Double): Boolean; override;

    property PostReply;

    function GetSearchRequestURL: string; virtual;
    function IntelligentPosting(var ARequestID: Double): Boolean; virtual; abstract;
  public
    property AccountName;
    property AccountPassword;
    property SettingsFileName;
    property Subject;
    property Tags;
    property Message;
    property Website;

    property ArticleID;
  end;

resourcestring
  StrForumIdIsUndefine = 'forum id is undefined!';
  StrAbortedThrougthInt = 'Aborted througth intelligent_posting-Helper';

implementation

{ TCMSBoardPlugIn }

function TCMSBoardPlugIn.GetCMSType;
begin
  Result := cmsBoard;
end;

{ TCMSBoardIPPlugInSettings }

constructor TCMSBoardIPPlugInSettings.Create;
begin
  inherited Create;

  // default setup
  intelligent_posting := False;
  intelligent_posting_helper := False;
end;

{ TCMSBoardIPPlugIn }

function TCMSBoardIPPlugIn.NeedBeforePostAction: Boolean;
begin
  Result := (Settings as TCMSBoardIPPlugInSettings).intelligent_posting;
end;

function TCMSBoardIPPlugIn.DoBeforePostAction(var ARequestID: Double): Boolean;
begin
  Result := IntelligentPosting(ARequestID);
end;

function TCMSBoardIPPlugIn.GetSearchRequestURL: string;
begin
  Result := GetIDsRequestURL;
end;

end.
