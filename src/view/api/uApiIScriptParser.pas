unit uApiIScriptParser;

interface

uses
  // Delphi
  Windows, SysUtils, StrUtils, Classes, Dialogs, Variants,
  // Indy
  IdURI,
  // RegEx
  RegExpr,
  // FastScript
  fs_iInterpreter, fs_iclassesrtti, fs_ijs, fs_itools,
  // FastScript Mod
  uMyfsScript,
  // Common
  uBaseConst, uBaseInterface, uAppConst, uAppInterface,
  // Api
  uApiControlsBase, uApiMirrorControlBase,
  // DLLs
  uExport,
  // Utils
  uNFOUtils, uPathUtils, uStringUtils, uURLUtils;

type
  TIScirptParser = class
  private type
    IMirror = interface
      ['{C95BF878-CC2E-4DC1-8EE6-2A0CAE81A5D8}']
      function GetMirror(const IndexOrName: OleVariant): IMirrorContainer;
      function GetCount: Integer;

      property Mirror[const IndexOrName: OleVariant]: IMirrorContainer read GetMirror; default;
      property Count: Integer read GetCount;
    end;

    TIMirror = class(TInterfacedObject, IMirror)
    private
      FCMSWebsiteData: ITabSheetData;
      FMirrorControllerBase: IMirrorControllerBase;
    protected
      function GetMirror(const IndexOrName: OleVariant): IMirrorContainer;
      function GetCount: Integer;
    public
      constructor Create(const ACMSWebsiteData: ITabSheetData); overload;
      constructor Create(const AMirrorControllerBase: IMirrorControllerBase); overload;

      property Mirror[const IndexOrName: OleVariant]: IMirrorContainer read GetMirror; default;
      property Count: Integer read GetCount;

      destructor Destroy; override;
    end;

  var

    FfsScript: TMyfsScript;
    FIScript: string;
    FIScriptResult : RIScriptResult;
    FResult: string;

    FIMirror: TIMirror;

    function CallMethod(Instance: TObject; ClassType: TClass; const MethodName: string; var Params: Variant): Variant;

    function GetCrypterProperties(Instance: TObject; ClassType: TClass; const PropName: string): Variant;
    function GetDirectlinkProperties(Instance: TObject; ClassType: TClass; const PropName: string): Variant;
    function GetMirrorProperties(Instance: TObject; ClassType: TClass; const PropName: string): Variant;
    function CallCrypterMethod(Instance: TObject; ClassType: TClass; const MethodName: string; var Params: Variant): Variant;
    function CallDirectlinkMethod(Instance: TObject; ClassType: TClass; const MethodName: string; var Params: Variant): Variant;
    function CallMirrorMethod(Instance: TObject; ClassType: TClass; const MethodName: string; var Params: Variant): Variant;

    procedure PrepareSimple();
    procedure PrepareExtended(const AWebsiteCMS, AWebsite: string; const ACMSWebsiteData: ITabSheetData); overload;
    procedure PrepareExtended(const ATabSheetController: ITabSheetController); overload;
    function Compile(const AIScript: string): Boolean;
    function RunErrorAnalysis(): RIScriptResult;
  public
    constructor Create(const AIScript: string); overload;
    constructor Create(const AWebsiteCMS, AWebsite: string; const ACMSWebsiteData: ITabSheetData; const AIScript: string); overload;
    // constructor Create(const AWebsiteCMS, AWebsite: string; AControlList: TControlDataList; AMirrorList: TMirrorContainerList; const AIScript: string); overload;
    constructor Create(const ATabSheetController: ITabSheetController; const AIScript: string); overload;
    function CallFunction(const AName: string; AParams: Variant; out AResult: Variant): RIScriptResult;
    function CallFunction3(const AName: string; AParams: Variant; out AResult: Variant): RIScriptResult;
    function Execute(): RIScriptResult;
    function ErrorAnalysis(): RIScriptResult;
    destructor Destroy; override;
  end;

implementation

{ TIScirptParser.TIMirror }

constructor TIScirptParser.TIMirror.Create(const ACMSWebsiteData: ITabSheetData);
begin
  inherited Create;
  FCMSWebsiteData := ACMSWebsiteData;
end;

constructor TIScirptParser.TIMirror.Create(const AMirrorControllerBase: IMirrorControllerBase);
begin
  inherited Create;
  FMirrorControllerBase := AMirrorControllerBase;
end;

function TIScirptParser.TIMirror.GetMirror(const IndexOrName: OleVariant): IMirrorContainer;
begin
  if Assigned(FCMSWebsiteData) then
    Result := FCMSWebsiteData.Mirror[IndexOrName]
  else if Assigned(FMirrorControllerBase) then
    Result := FMirrorControllerBase.Mirror[IndexOrName]
end;

function TIScirptParser.TIMirror.GetCount: Integer;
begin
  if Assigned(FCMSWebsiteData) then
    Result := FCMSWebsiteData.MirrorCount
  else if Assigned(FMirrorControllerBase) then
    Result := FMirrorControllerBase.MirrorCount
end;

destructor TIScirptParser.TIMirror.Destroy;
begin
  FMirrorControllerBase := nil;
  FCMSWebsiteData := nil;
  inherited Destroy;
end;

{ TIScirptParser }

function TIScirptParser.CallMethod(Instance: TObject; ClassType: TClass; const MethodName: string; var Params: Variant): Variant;
var
  LFileName: string;
begin
  Result := 0;
  if MethodName = 'PRINT' then
    FResult := FResult + Params[0]
  else if MethodName = 'PRINTFILE' then
  begin
    LFileName := Params[0];
    if not FileExists(LFileName) then
      LFileName := PathCombineEx(GetTemplatesCMSFolder, LFileName);

    with TStringList.Create do
      try
        LoadFromFile(LFileName);
        FResult := FResult + UnicodeString(Text);
      finally
        Free;
      end;
  end
  else if MethodName = 'CHARCOUNT' then
    Result := CharCount(Params[0], Params[1])
  else if MethodName = 'NFOSTRIPPER' then
    Result := TNFOUtils.AsStrippedText(Params[0], Params[1])
  else if MethodName = 'POSEX' then
    Result := PosEx(Params[0], Params[1], Params[2])
  else if MethodName = 'REDUCECAPITALS' then
    Result := ReduceCapitals(Params[0])
  else if MethodName = 'STRINGREPLACE' then
    Result := StringReplace(Params[0], Params[1], Params[2], [rfReplaceAll])
  else if MethodName = 'URLENCODE' then
    Result := TIdURI.URLEncode(Params[0])
  else if MethodName = 'URLDECODE' then
    Result := TIdURI.URLDecode(Params[0])
  else if MethodName = 'EXTRACTURLFILENAME' then
    Result := ExtractUrlFileName(Params[0])
  else if MethodName = 'EXTRACTURLPATH' then
    Result := ExtractUrlPath(Params[0])
  else if MethodName = 'EXTRACTURLPROTOCOL' then
    Result := ExtractUrlProtocol(Params[0])
  else if MethodName = 'EXTRACTURLHOST' then
    Result := ExtractUrlHost(Params[0])
  else if MethodName = 'EXTRACTURLHOSTWITHPATH' then
    Result := ExtractUrlHostWithPath(Params[0])
  else if MethodName = 'BUILDWEBSITEURL' then
    Result := BuildWebsiteUrl(Params[0])
  else if MethodName = 'INCLUDETRAILINGURLDELIMITER' then
    Result := IncludeTrailingUrlDelimiter(Params[0])
  else if MethodName = 'EXCLUDETRAILINGURLDELIMITER' then
    Result := ExcludeTrailingUrlDelimiter(Params[0])
  else if MethodName = 'MATCHTEXT' then
    Result := MatchTextMask(Params[0], Params[1], Params[2])
  else if MethodName = 'REPLACEREGEXPR' then
  begin
    with TRegExpr.Create do
      try
        Result := ReplaceRegExpr(Params[0], Params[1], Params[2], Params[3]);
      finally
        Free;
      end;
  end;
end;

function TIScirptParser.GetCrypterProperties(Instance: TObject; ClassType: TClass; const PropName: string): Variant;
begin
  Result := 0;
  if PropName = 'NAME' then
    Result := ICrypter(Instance as TICrypter).Name
  else if PropName = 'SIZE' then
    Result := ICrypter(Instance as TICrypter).Size
  else if PropName = 'PARTSIZE' then
    Result := ICrypter(Instance as TICrypter).PartSize
  else if PropName = 'HOSTER' then
    Result := ICrypter(Instance as TICrypter).Hoster
  else if PropName = 'HOSTERSHORT' then
    Result := ICrypter(Instance as TICrypter).HosterShort
  else if PropName = 'PARTS' then
    Result := ICrypter(Instance as TICrypter).Parts
  else if PropName = 'VALUE' then
    Result := ICrypter(Instance as TICrypter).Value
  else if PropName = 'STATUSIMAGE' then
    Result := ICrypter(Instance as TICrypter).StatusImage
  else if PropName = 'STATUSIMAGETEXT' then
    Result := ICrypter(Instance as TICrypter).StatusImageText
end;

function TIScirptParser.GetDirectlinkProperties(Instance: TObject; ClassType: TClass; const PropName: string): Variant;
begin
  Result := 0;
  if PropName = 'SIZE' then
    Result := IDirectlink(Instance as TIDirectlink).Size
  else if PropName = 'PARTSIZE' then
    Result := IDirectlink(Instance as TIDirectlink).PartSize
  else if PropName = 'HOSTER' then
    Result := IDirectlink(Instance as TIDirectlink).Hoster
  else if PropName = 'HOSTERSHORT' then
    Result := IDirectlink(Instance as TIDirectlink).HosterShort
  else if PropName = 'PARTS' then
    Result := IDirectlink(Instance as TIDirectlink).Parts
  else if PropName = 'VALUE' then
    Result := IDirectlink(Instance as TIDirectlink).Value
end;

function TIScirptParser.GetMirrorProperties(Instance: TObject; ClassType: TClass; const PropName: string): Variant;
begin
  Result := 0;
  if PropName = 'SIZE' then
    Result := IMirrorContainer(Instance as TIMirrorContainer).Size
  else if PropName = 'PARTSIZE' then
    Result := IMirrorContainer(Instance as TIMirrorContainer).PartSize
  else if PropName = 'HOSTER' then
    Result := IMirrorContainer(Instance as TIMirrorContainer).Hoster
  else if PropName = 'HOSTERSHORT' then
    Result := IMirrorContainer(Instance as TIMirrorContainer).HosterShort
  else if PropName = 'PARTS' then
    Result := IMirrorContainer(Instance as TIMirrorContainer).Parts
    // -->
  else if PropName = 'CRYPTERCOUNT' then
    Result := IMirrorContainer(Instance as TIMirrorContainer).CrypterCount
  else if PropName = 'DIRECTLINKCOUNT' then
    Result := IMirrorContainer(Instance as TIMirrorContainer).DirectlinkCount
    // -->
  else if PropName = 'COUNT' then
    Result := IMirror(Instance as TIMirror).Count
end;

function TIScirptParser.CallCrypterMethod(Instance: TObject; ClassType: TClass; const MethodName: string; var Params: Variant): Variant;
begin
  Result := 0;
  if MethodName = 'VALUE.GET' then
    Result := (IMirrorContainer(Instance as TIMirrorContainer).Crypter[Params[0]] as TICrypter).Value
end;

function TIScirptParser.CallDirectlinkMethod(Instance: TObject; ClassType: TClass; const MethodName: string; var Params: Variant): Variant;
begin
  Result := 0;
  if MethodName = 'VALUE.GET' then
    Result := (IMirrorContainer(Instance as TIMirrorContainer).Directlink[Params[0]] as TIDirectlink).Value
end;

function TIScirptParser.CallMirrorMethod(Instance: TObject; ClassType: TClass; const MethodName: string; var Params: Variant): Variant;
begin
  Result := 0;
  if MethodName = 'MIRROR.GET' then
    Result := Integer(IMirror(Instance as TIMirror).Mirror[Params[0]] as TIMirrorContainer)
    // -->
  else if MethodName = 'CRYPTER.GET' then
    Result := Integer(IMirrorContainer(Instance as TIMirrorContainer).Crypter[Params[0]] as TICrypter)
  else if MethodName = 'DIRECTLINK.GET' then
    Result := Integer(IMirrorContainer(Instance as TIMirrorContainer).Directlink[Params[0]] as TIDirectlink)
end;

procedure TIScirptParser.PrepareSimple;
begin
  with FfsScript do
  begin
    Clear;
    Parent := fsGlobalUnit;
    IncludePath.Add(GetTemplatesCMSFolder);

    AddMethod('procedure print(Msg: string)', CallMethod);
    AddMethod('procedure printFile(const AFileName: string)', CallMethod);

    AddMethod('function CharCount(const SubStr, S: string): Integer', CallMethod);
    AddMethod('function NFOStripper(const NFO: string; const ARequiredOccurrences: Integer = 5): string', CallMethod);
    AddMethod('function PosEx(const SubStr, S: string; Offset: Integer = 1): Integer', CallMethod);
    AddMethod('function ReduceCapitals(const Str: string): string', CallMethod);
    AddMethod('function StringReplace(const S, OldPattern, NewPattern: string): string', CallMethod);

    AddMethod('function MatchText(const Mask, S: string; CaseSensitive: Boolean = False): Boolean', CallMethod);
    AddMethod('function ReplaceRegExpr(const ARegExpr, AInputStr, AReplaceStr : string; AUseSubstitution: Boolean = False): string', CallMethod);

    AddMethod('function URLEncode(const ASrc: string): string', CallMethod);
    AddMethod('function URLDecode(const ASrc: string): string', CallMethod);

    AddMethod('function ExtractUrlFileName(const AUrl: string): string', CallMethod);
    AddMethod('function ExtractUrlPath(const AUrl: string): string', CallMethod);
    AddMethod('function ExtractUrlProtocol(const AUrl: string): string', CallMethod);
    AddMethod('function ExtractUrlHost(const AUrl: string): string', CallMethod);
    AddMethod('function ExtractUrlHostWithPath(const AUrl: string): string', CallMethod);
    AddMethod('function BuildWebsiteUrl(const AUrl: string): string', CallMethod);

    AddMethod('function IncludeTrailingUrlDelimiter(const AUrl: string): string', CallMethod);
    AddMethod('function ExcludeTrailingUrlDelimiter(const AUrl: string): string', CallMethod);

    with AddClass(TICrypter, 'TICrypter') do
    begin
      AddProperty('Name', 'string', GetCrypterProperties, nil);
      AddProperty('Size', 'Extended', GetCrypterProperties, nil);
      AddProperty('PartSize', 'Extended', GetCrypterProperties, nil);
      AddProperty('Hoster', 'string', GetCrypterProperties, nil);
      AddProperty('HosterShort', 'string', GetCrypterProperties, nil);
      AddProperty('Parts', 'Integer', GetCrypterProperties, nil);
      AddProperty('Value', 'string', GetCrypterProperties, nil);
      // AddDefaultProperty('Value', 'Variant', 'string', CallCrypterMethod);
      AddProperty('StatusImage', 'string', GetCrypterProperties, nil);
      AddProperty('StatusImageText', 'string', GetCrypterProperties, nil);
    end;

    with AddClass(TIDirectlink, 'TIDirectlink') do
    begin
      AddProperty('Size', 'Extended', GetDirectlinkProperties, nil);
      AddProperty('PartSize', 'Extended', GetDirectlinkProperties, nil);
      AddProperty('Hoster', 'string', GetDirectlinkProperties, nil);
      AddProperty('HosterShort', 'string', GetDirectlinkProperties, nil);
      AddProperty('Parts', 'Integer', GetDirectlinkProperties, nil);
      AddProperty('Value', 'string', GetDirectlinkProperties, nil);
      // AddDefaultProperty('Value', 'Integer', 'string', CallDirectlinkMethod);
    end;

    with AddClass(TIMirrorContainer, 'TIMirrorContainer') do
    begin
      AddProperty('Size', 'Extended', GetMirrorProperties, nil);
      AddProperty('PartSize', 'Extended', GetMirrorProperties, nil);
      AddProperty('Hoster', 'string', GetMirrorProperties, nil);
      AddProperty('HosterShort', 'string', GetMirrorProperties, nil);
      AddProperty('Parts', 'Integer', GetMirrorProperties, nil);

      AddIndexProperty('Crypter', 'Variant', 'TICrypter', CallMirrorMethod);
      AddProperty('CrypterCount', 'Integer', GetMirrorProperties, nil);

      AddIndexProperty('Directlink', 'Integer', 'TIDirectlink', CallMirrorMethod);
      AddProperty('DirectlinkCount', 'Integer', GetMirrorProperties, nil);
    end;

    with AddClass(TIMirror, 'TIMirror') do
    begin
      AddDefaultProperty('Mirror', 'Variant', 'TIMirrorContainer', CallMirrorMethod);
      AddProperty('Count', 'Integer', GetMirrorProperties, nil);
    end;

    AddObject('IMirror', FIMirror);
    AddConst('IMirrorCount', 'Integer', FIMirror.Count);
  end;
end;

procedure TIScirptParser.PrepareExtended(const AWebsiteCMS, AWebsite: string; const ACMSWebsiteData: ITabSheetData);
var
  I: Integer;
begin
  with FfsScript do
  begin
    AddConst('IType', 'string', TypeIDToString(ACMSWebsiteData.TypeID));
    AddConst('ICMS', 'string', AWebsiteCMS);
    AddConst('IWebsite', 'string', AWebsite);

    with ACMSWebsiteData do
      for I := 0 to ControlCount - 1 do
        AddConst(ControlIDToString(Control[I].ControlID), 'string', Control[I].Value);
  end;
end;

procedure TIScirptParser.PrepareExtended(const ATabSheetController: ITabSheetController);
var
  I: Integer;
begin
  with FfsScript do
  begin
    AddConst('IType', 'string', TypeIDToString(ATabSheetController.TypeID));

    with ATabSheetController.ControlController do
      for I := 0 to ControlCount - 1 do
        AddConst(ControlIDToString(Control[I].ControlID), 'string', Control[I].Value);
  end;
end;

function TIScirptParser.Compile(const AIScript: string): Boolean;
begin
  with FfsScript do
  begin
    ClearItems(Self);

    FResult := '';
    Lines.Text := AIScript;

    Result := Compile;
  end;
end;

function TIScirptParser.RunErrorAnalysis(): RIScriptResult;
begin
  Result.Init;
  Result.HasError := not Compile(FIScript);
  if Result.HasError then
  begin
    with fsPosToPoint(FfsScript.ErrorPos) do
    begin
      Result.X := X;
      Result.Y := Y;
    end;
    with Result do
    begin
      ErrorMessage := FfsScript.ErrorMsg;
      ErrorUnit := FfsScript.ErrorUnit;
    end;
  end;
end;

constructor TIScirptParser.Create(const AIScript: string);
begin
  FfsScript := TMyfsScript.Create(nil);
  FfsScript.SyntaxType := 'JScript';
  FIScript := AIScript;
end;

constructor TIScirptParser.Create(const AWebsiteCMS, AWebsite: string; const ACMSWebsiteData: ITabSheetData; const AIScript: string);
begin
  Create(AIScript);

  FIMirror := TIMirror.Create(ACMSWebsiteData);

  PrepareSimple;
  PrepareExtended(AWebsiteCMS, AWebsite, ACMSWebsiteData);

  FIScriptResult := RunErrorAnalysis();
end;

constructor TIScirptParser.Create(const ATabSheetController: ITabSheetController; const AIScript: string);
begin
  Create(AIScript);

  FIMirror := TIMirror.Create(ATabSheetController.MirrorController);

  PrepareSimple;
  PrepareExtended(ATabSheetController);

  FIScriptResult := RunErrorAnalysis();
end;

function TIScirptParser.CallFunction(const AName: string; AParams: Variant; out AResult: Variant): RIScriptResult;
begin
  Result := FIScriptResult;
  if not Result.HasError then
  begin
    Result.Init;
    try
      AResult := FfsScript.CallFunction(AName, AParams, False);
    except
      on E: Exception do
      begin
        Result.HasError := True;
        Result.ErrorMessage := E.ClassName + ': ' + E.Message;
      end;
    end;
    Result.CompiledText := FResult;
  end;
end;

function TIScirptParser.CallFunction3(const AName: string; AParams: Variant; out AResult: Variant): RIScriptResult;
begin
  Result := FIScriptResult;
  if not Result.HasError then
  begin
    Result.Init;
    try
      AResult := FfsScript.CallFunction3(AName, AParams, False);
    except
      on E: Exception do
      begin
        Result.HasError := True;
        Result.ErrorMessage := E.ClassName + ': ' + E.Message;
      end;
    end;
    Result.CompiledText := FResult;
  end;
end;

function TIScirptParser.Execute(): RIScriptResult;
begin
  Result := FIScriptResult;
  if not Result.HasError then
  begin
    Result.Init;
    try
      FfsScript.Execute;
    except
      on E: Exception do
      begin
        Result.HasError := True;
        Result.ErrorMessage := E.ClassName + ': ' + E.Message;
      end;
    end;
    Result.CompiledText := FResult;
  end;
end;

function TIScirptParser.ErrorAnalysis: RIScriptResult;
begin
  Result := FIScriptResult;
end;

destructor TIScirptParser.Destroy;
begin
  FIMirror.Free;
  FfsScript.Free;
  inherited Destroy;
end;

end.
