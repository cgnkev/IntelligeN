unit uApiSettings;

interface

uses
  // Delphi
  Windows, SysUtils, Classes, Controls, Forms, Graphics, ImgList, Generics.Collections,
  // Dev Express
  dxDockControl, cxCheckListBox,
  // AnyDAC
  // uADStanIntf,
  // Common
  uBaseConst, uBaseInterface, uAppConst, uAppInterface, uFileInterface,
  // DLLs
  uExport,
  // Api
  uApiConst, uApiMain, uApiMultiCastEvent, uApiSettingsManager, uApiXML, uApiXmlSettings,
  // HTTPManager
  uHTTPConst, uHTTPInterface, uHTTPClasses,
  // Plugin system
  uPlugInConst, uPlugInInterface, uPlugInInterfaceAdv,
  // Utils
  uFileUtils, uPathUtils, uStringUtils, uURLUtils;

type
{$REGION 'T...PlugInCollectionItem'}
  TPlugInCollectionItem = class(TCollectionItem)
  private
    FName, FPath: string;
    FEnabled: Boolean;
    FIconHandle: Cardinal;
    FIcon: TIcon;
    function GetIconHandle: Cardinal;
    function GetIcon: TIcon;
    function GetEnabled: Boolean;
  public
    function GetPath: string; virtual;
    property IconHandle: Cardinal read GetIconHandle write FIconHandle;
    property Icon: TIcon read GetIcon;
    destructor Destroy; override;
  published
    property Name: string read FName write FName;
    property Enabled: Boolean read GetEnabled write FEnabled;
    property Path: string read FPath write FPath;
  end;

  TAppCollectionItem = class(TPlugInCollectionItem)
  private
    FLibraryID: Integer;
  public
    Plugin: IAppPlugIn;
    property LibraryID: Integer read FLibraryID write FLibraryID;
  published
    property Name;
    property Enabled;
  end;

  TCMSWebsitesCollectionItem = class(TPlugInCollectionItem) // TODO: Rename to: TCMSWebsiteCollectionItem
  private
    FAccountName, FAccountPassword, FSubjectFileName, FMessageFileName: string;
    FWebsite: string;
    FFilter: IFilter;
    FCustomFields: ICustomFields;
    function GetHostWithPath: string;
  public
    function GetPath: string; override;
    function GetSubjectFileName: string;
    function GetMessageFileName: string;
  public
    property HostWithPath: string read GetHostWithPath;
    property Website: string read FWebsite write FWebsite;
    property Filter: IFilter read FFilter write FFilter;
    property CustomFields: ICustomFields read FCustomFields write FCustomFields;
  published
    property Name;
    property Enabled;
    property Path;
    property AccountName: string read FAccountName write FAccountName;
    property AccountPassword: string read FAccountPassword write FAccountPassword;
    property SubjectFileName: string read FSubjectFileName write FSubjectFileName;
    property MessageFileName: string read FMessageFileName write FMessageFileName;
  end;

  TCMSCollectionItem = class(TPlugInCollectionItem)
  private
    FWebsites: TCollection;
    FOnSettingsChange, FOnWebsitesChange, FOnSubjectsChange, FOnMessagesChange: TICMSItemChangeEvent;
  public
    constructor Create(Collection: TCollection); override;
    function GetWebsite(AIndex: Integer): TCMSWebsitesCollectionItem;
    procedure UpdateWebsite(AIndex: Integer);
    procedure UpdateWebsites;
    function FindCMSWebsite(const ACMSWebsiteName: string): TCMSWebsitesCollectionItem;
    property OnSettingsChange: TICMSItemChangeEvent read FOnSettingsChange write FOnSettingsChange;
    property OnWebsitesChange: TICMSItemChangeEvent read FOnWebsitesChange write FOnWebsitesChange;
    property OnSubjectsChange: TICMSItemChangeEvent read FOnSubjectsChange write FOnSubjectsChange;
    property OnMessagesChange: TICMSItemChangeEvent read FOnMessagesChange write FOnMessagesChange;
    destructor Destroy; override;
  published
    property Name;
    property Enabled;
    property Websites: TCollection read FWebsites write FWebsites;
  end;

  TCrawlerContingentCollectionItem = class(TCollectionItem)
  private
    FTypeID: TTypeID;
    FControlID: TControlID;
    FStatus: Boolean;
  published
    property TypeID: TTypeID read FTypeID write FTypeID;
    property ControlID: TControlID read FControlID write FControlID;
    property Status: Boolean read FStatus write FStatus;
  end;

  TCrawlerCollectionItem = class(TPlugInCollectionItem)
  private
    FContingent: TCollection;
    FLimit: Integer;
    function GetContingentStatus(ATypeID: TTypeID; AComponentID: TControlID): Boolean;
    procedure SetContingentStatus(ATypeID: TTypeID; AComponentID: TControlID; Status: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    property ContingentStatus[ATypeID: TTypeID; AControlID: TControlID]: Boolean read GetContingentStatus write SetContingentStatus;
    destructor Destroy; override;
  published
    property Name;
    property Enabled;
    property Limit: Integer read FLimit write FLimit;
    property Contingent: TCollection read FContingent write FContingent;
  end;

  TFoldername = (fnFilename, fnReleasename, fnTitle);

  TCrypterCollectionItem = class(TPlugInCollectionItem)
  private
    FUseAccount, FUseCaptcha, FUseAdvertismentLink, FUseAdvertismentPicture, FUseCoverLink, FUseDescription, FUseCNL, FUseWebseiteLink, FUseEMailforStatusNotice, FUseFilePassword, FUseAdminPassword, FUseVisitorPassword: Boolean;

    FAccountName, FAccountPassword, FAdvertismentLayerName, FAdvertismentLayerValue, FAdvertismentLink, FAdvertismentPicture,
    { FDescription,FCoverLink, } FWebseiteLink, FEMailforStatusNotice, FAdminPassword, FVisitorPassword: string;

    FFoldertypes: TFoldertypes;
    FContainerTypes: TContainerTypes;
    FFolderName: TFoldername;
    FAdvertismentType: TAdvertismenttype;

    FCheckDelay: Integer;
  published
    property Name;
    property Enabled;
    property UseAccount: Boolean read FUseAccount write FUseAccount;
    property AccountName: string read FAccountName write FAccountName;
    property AccountPassword: string read FAccountPassword write FAccountPassword;

    property Foldertypes: TFoldertypes read FFoldertypes write FFoldertypes;
    property ContainerTypes: TContainerTypes read FContainerTypes write FContainerTypes;
    property UseCaptcha: Boolean read FUseCaptcha write FUseCaptcha;
    property FolderName: TFoldername read FFolderName write FFolderName;

    property AdvertismentType: TAdvertismenttype read FAdvertismentType write FAdvertismentType;
    property AdvertismentLayerName: string read FAdvertismentLayerName write FAdvertismentLayerName;
    property AdvertismentLayerValue: string read FAdvertismentLayerValue write FAdvertismentLayerValue;
    property UseAdvertismentLink: Boolean read FUseAdvertismentLink write FUseAdvertismentLink;
    property AdvertismentLink: string read FAdvertismentLink write FAdvertismentLink;
    property UseAdvertismentPicture: Boolean read FUseAdvertismentPicture write FUseAdvertismentPicture;
    property AdvertismentPicture: string read FAdvertismentPicture write FAdvertismentPicture;

    property UseCoverLink: Boolean read FUseCoverLink write FUseCoverLink;
    // property CoverLink:string read FCoverLink write FCoverLink;
    property UseDescription: Boolean read FUseDescription write FUseDescription;
    // property Description:string read FDescription write FDescription;
    property UseCNL: Boolean read FUseCNL write FUseCNL;
    property UseWebseiteLink: Boolean read FUseWebseiteLink write FUseWebseiteLink;
    property WebseiteLink: string read FWebseiteLink write FWebseiteLink;

    property UseEMailforStatusNotice: Boolean read FUseEMailforStatusNotice write FUseEMailforStatusNotice;
    property EMailforStatusNotice: string read FEMailforStatusNotice write FEMailforStatusNotice;
    property UseFilePassword: Boolean read FUseFilePassword write FUseFilePassword;
    property UseAdminPassword: Boolean read FUseAdminPassword write FUseAdminPassword;
    property AdminPassword: string read FAdminPassword write FAdminPassword;
    property UseVisitorPassword: Boolean read FUseVisitorPassword write FUseVisitorPassword;
    property VisitorPassword: string read FVisitorPassword write FVisitorPassword;

    property CheckDelay: Integer read FCheckDelay write FCheckDelay;
  end;

  TFileFormatsCollectionItem = class(TPlugInCollectionItem)
  private
    FForceAddCrypter, FForceAddImageMirror: Boolean;
  published
    property Name;
    property Enabled;
    property ForceAddCrypter: Boolean read FForceAddCrypter write FForceAddCrypter;
    property ForceAddImageMirror: Boolean read FForceAddImageMirror write FForceAddImageMirror;
  end;

  TImageHosterCollectionItem = class(TPlugInCollectionItem)
  private
    FUseAccount, FUploadAfterCrawling: Boolean;
    FAccountName, FAccountPassword: string;
    FImageHostResize: TImageHostResize;
  published
    property Name;
    property Enabled;
    property UseAccount: Boolean read FUseAccount write FUseAccount;
    property AccountName: string read FAccountName write FAccountName;
    property AccountPassword: string read FAccountPassword write FAccountPassword;
    property ImageHostResize: TImageHostResize read FImageHostResize write FImageHostResize;
    property UploadAfterCrawling: Boolean read FUploadAfterCrawling write FUploadAfterCrawling;
  end;
{$ENDREGION}

  TSettings_Plugins = class(TPersistent)
  private
    FCMS: TCollection;
    FApp, FCAPTCHA, FCrawler, FCrypter, FFileFormats, FFileHoster, FImageHoster: TCollection;
    FAppImageList, FCMSImageList, FCAPTCHAImageList, FCrawlerImageList, FCrypterImageList, FFileFormatsImageList, FFileHosterImageList, FImageHosterImageList: TImageList;
    FOnCMSChange: TIPluginChangeEvent;
  public
    constructor Create;
    function FindPlugInCollectionItemFromCollection(const APlugInCollectionItemName: string; ACollection: TCollection): TPlugInCollectionItem;
    property AppImageList: TImageList read FAppImageList;
    property CMSImageList: TImageList read FCMSImageList;
    property CAPTCHAImageList: TImageList read FCAPTCHAImageList;
    property CrawlerImageList: TImageList read FCrawlerImageList;
    property CrypterImageList: TImageList read FCrypterImageList;
    property FileFormatsImageList: TImageList read FFileFormatsImageList;
    property FileHosterImageList: TImageList read FFileHosterImageList;
    property ImageHosterImageList: TImageList read FImageHosterImageList;
    property OnCMSChange: TIPluginChangeEvent read FOnCMSChange write FOnCMSChange;
    destructor Destroy; override;
  published
    property App: TCollection read FApp write FApp;
    property CMS: TCollection read FCMS write FCMS;
    property CAPTCHA: TCollection read FCAPTCHA write FCAPTCHA;
    property Crawler: TCollection read FCrawler write FCrawler;
    property Crypter: TCollection read FCrypter write FCrypter;
    property FileFormats: TCollection read FFileFormats write FFileFormats;
    property FileHoster: TCollection read FFileHoster write FFileHoster;
    property ImageHoster: TCollection read FImageHoster write FImageHoster;
  end;

  TDatabaseCollectionItem = class(TCollectionItem)
  private
    FName: string;
    FEnabled: Boolean;
    // FConnectivity: TADRDBMSKind;
    FServer: string;
    FPort: Integer;
    FDatabase: string;
    FUsername: string;
    FPassword: string;
  published
    property Name: string read FName write FName;
    property Enabled: Boolean read FEnabled write FEnabled;
    // property Connectivity: TADRDBMSKind read FConnectivity write FConnectivity;
    property Server: string read FServer write FServer;
    property Port: Integer read FPort write FPort;
    property Database: string read FDatabase write FDatabase;
    property Username: string read FUsername write FUsername;
    property Password: string read FPassword write FPassword;
  end;

  TSettings_Database = class(TPersistent)
  private
    FActiveDatabaseName: string;
    FDatabase: TCollection;
    function GetActiveDatabase: TDatabaseCollectionItem;
    procedure SetActiveDatabase(ADatabaseCollectionItem: TDatabaseCollectionItem);
  public
    constructor Create;
    function GetDatabaseItemList: TStrings;
    property ActiveDatabase: TDatabaseCollectionItem read GetActiveDatabase write SetActiveDatabase;
    destructor Destroy; override;
  published
    property ActiveDatabaseName: string read FActiveDatabaseName write FActiveDatabaseName;
    property Database: TCollection read FDatabase write FDatabase;
  end;

  TControlItemsCollectionItem = class(TCollectionItem)
  private
    FItemName, FAlsoKnownAs: string;
  published
    property ItemName: string read FItemName write FItemName;
    property AlsoKnownAs: string read FAlsoKnownAs write FAlsoKnownAs;
  end;

  TControlCollectionItem = class(TCollectionItem)
  private
    FControlID: TControlID;
    FTitle, FHelpText, FValue: string;
    FItems: TCollection;
  public
    constructor Create(Collection: TCollection); override;
    function GetItems: string;
    destructor Destroy; override;
  published
    property ControlID: TControlID read FControlID write FControlID;
    property Title: string read FTitle write FTitle;
    property HelpText: string read FHelpText write FHelpText;
    property Value: string read FValue write FValue;
    property Items: TCollection read FItems write FItems;
  end;

  TControlsCollectionItem = class(TCollectionItem)
  private
    FTypeID: TTypeID;
    FControls: TCollection;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property TypeID: TTypeID read FTypeID write FTypeID;
    property Controls: TCollection read FControls write FControls;
  end;

  TSettings_Controls = class(TPersistent)
  private
    FControlsTT: TCollection;
    FIRichEditWrapText: Boolean;
    FDropDownRows: Integer;
    function GetControls(ATypeID: TTypeID; AComponentID: TControlID): TControlCollectionItem;
  public
    constructor Create;
    property Controls[ATypeID: TTypeID; AComponentID: TControlID]: TControlCollectionItem read GetControls;
    function GetCustomisedComponentValue(const AComponentID: TControlID; const ATypeID: TTypeID; const AValue: string): string;
    destructor Destroy; override;
  published
    property ControlsTT: TCollection read FControlsTT write FControlsTT;
    property IRichEditWrapText: Boolean read FIRichEditWrapText write FIRichEditWrapText;
    property DropDownRows: Integer read FDropDownRows write FDropDownRows default 8;
  end;

  TProxySubActivation = (psaMain, psaCMS, psaCrawler, psaCrypter, psaFileHoster, psaImageHoster);
  TProxySubActivations = set of TProxySubActivation;

  TSettings_Proxy = class(TPersistent)
  private
    FProxyType: TProxyType;
    FServer, FAccountName, FAccountPassword: string;
    FPort: Integer;
    FRequireAuthentication: Boolean;
    FProxySubActivations: TProxySubActivations;

    FProxyTypeLock, FServerLock, FPortLock, FRequireAuthenticationLock, FAccountNameLock, FAccountPasswordLock, FProxySubActivationsLock: TMultiReadExclusiveWriteSynchronizer;

    function GetProxyType: TProxyType;
    procedure SetProxyType(const Value: TProxyType);
    function GetServer: string;
    procedure SetServer(const Value: string);
    function GetPort: Integer;
    procedure SetPort(const Value: Integer);
    function GetAccountName: string;
    procedure SetAccountName(const Value: string);
    function GetAccountPassword: string;
    procedure SetAccountPassword(const Value: string);
    function GetProxySubActivations: TProxySubActivations;
    procedure SetProxySubActivations(const Value: TProxySubActivations);
    function GetRequireAuthentication: Boolean;
    procedure SetRequireAuthentication(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property ProxyType: TProxyType read GetProxyType write SetProxyType;
    property Server: string read GetServer write SetServer;
    property Port: Integer read GetPort write SetPort;
    property RequireAuthentication: Boolean read GetRequireAuthentication write SetRequireAuthentication;
    property AccountName: string read GetAccountName write SetAccountName;
    property AccountPassword: string read GetAccountPassword write SetAccountPassword;
    property ProxySubActivations: TProxySubActivations read GetProxySubActivations write SetProxySubActivations;
  end;

  TSettings_HTTP = class(TPersistent)
  private
    FMaxSimultaneousConnections, FConnectTimeout, FReadTimeout: Integer;
    FSettings_Proxy: TSettings_Proxy;

    FMaxSimultaneousConnectionsLock, FConnectTimeoutLock, FReadTimeoutLock: TMultiReadExclusiveWriteSynchronizer;

    function GetMaxSimultaneousConnections: Integer;
    procedure SetMaxSimultaneousConnections(const Value: Integer);
    function GetConnectTimeout: Integer;
    procedure SetConnectTimeout(const Value: Integer);
    function GetReadTimeout: Integer;
    procedure SetReadTimeout(const Value: Integer);
  public
    constructor Create;
    function GetProxy(AProxySubActivation: TProxySubActivation): IProxy;
    destructor Destroy; override;
  published
    property MaxSimultaneousConnections: Integer read GetMaxSimultaneousConnections write SetMaxSimultaneousConnections;
    property ConnectTimeout: Integer read GetConnectTimeout write SetConnectTimeout;
    property ReadTimeout: Integer read GetReadTimeout write SetReadTimeout;
    property Proxy: TSettings_Proxy read FSettings_Proxy write FSettings_Proxy;
  end;

  TSettings_Publish = class(TPersistent)
  private
    FPublishMaxCount, FPublishDelaybetweenUploads, FRetryCount: Integer;
  published
    property PublishMaxCount: Integer read FPublishMaxCount write FPublishMaxCount;
    property PublishDelaybetweenUploads: Integer read FPublishDelaybetweenUploads write FPublishDelaybetweenUploads;
    property RetryCount: Integer read FRetryCount write FRetryCount;
  end;

  TLayoutCollectionItem = class(TCollectionItem)
  private
    FName, FDockControls, FBarManager: string;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property Name: string read FName write FName;
    property DockControls: string read FDockControls write FDockControls;
    property BarManager: string read FBarManager write FBarManager;
    //
  end;

  TLayoutforForms = class(TPersistent)
  private
    FLeft: Integer;
    FHeight: Integer;
    FTop: Integer;
    FWidth: Integer;
    FWindowState: TWindowState;
  public
    procedure SaveLayout(const AForm: TForm);
    procedure LoadLayout(const AForm: TForm);
  published
    property Left: Integer read FLeft write FLeft;
    property Height: Integer read FHeight write FHeight;
    property Top: Integer read FTop write FTop;
    property Width: Integer read FWidth write FWidth;
    property WindowState: TWindowState read FWindowState write FWindowState;
  end;

  TSettings_Layout = class(TPersistent)
  private
    FActiveLayoutName: string;
    FMain, FSettings: TLayoutforForms;
    FLayout: TCollection;
    FOnLayoutChanged: TNotifyEvent;
    function GetActiveLayout: TLayoutCollectionItem;
    procedure SetActiveLayout(ALayoutCollectionItem: TLayoutCollectionItem);
    procedure SetActiveLayoutName(const AActiveLayoutName: string);
  public
    constructor Create;
    function GetLayoutItemList: TStrings;
    function FindLayout(const ALayoutName: string): TLayoutCollectionItem;
    property ActiveLayout: TLayoutCollectionItem read GetActiveLayout write SetActiveLayout;
    property OnLayoutChanged: TNotifyEvent read FOnLayoutChanged write FOnLayoutChanged;
    destructor Destroy; override;
  published
    property ActiveLayoutName: string read FActiveLayoutName write SetActiveLayoutName;
    property Main: TLayoutforForms read FMain write FMain;
    property Settings: TLayoutforForms read FSettings write FSettings;
    property Layout: TCollection read FLayout write FLayout;
  end;

  TSettings_Log = class(TPersistent)
  private
    FMaxLogEntries, FMaxHTTPLogEntries: Integer;
  published
    property MaxLogEntries: Integer read FMaxLogEntries write FMaxLogEntries;
    property MaxHTTPLogEntries: Integer read FMaxHTTPLogEntries write FMaxHTTPLogEntries;
  end;

  TSettings_DefaultStartup = class(TPersistent)
  private
    FA, FB, FC, FD, FE: Boolean;
    FTA, FTB, FTC, FTD, FTE: string;
  published
    property ActiveA: Boolean read FA write FA;
    property TypeA: string read FTA write FTA;
    property ActiveB: Boolean read FB write FB;
    property TypeB: string read FTB write FTB;
    property ActiveC: Boolean read FC write FC;
    property TypeC: string read FTC write FTC;
    property ActiveD: Boolean read FD write FD;
    property TypeD: string read FTD write FTD;
    property ActiveE: Boolean read FE write FE;
    property TypeE: string read FTE write FTE;
  end;

  TMirrorPosition = (mpBottom, mpTop);
  TDirectlinksView = (dlvGrid, dlvIcon);

  TSettings_ControlAligner = class(TPersistent)
  private
    FTSettings_DefaultStartup: TSettings_DefaultStartup;
    FMirrorCount, FMirrorColumns, FMirrorHeight: Integer;
    FDefaultMirrorTabIndex: string;
    FModyBeforeCrypt, FSwichAfterCrypt: Boolean;
    FMirrorPosition: TMirrorPosition;
    FDirectlinksView: TDirectlinksView;
    FPaddingLeft: Integer;
    FPaddingHeight: Integer;
    FPaddingWidth: Integer;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property DefaultStartup: TSettings_DefaultStartup read FTSettings_DefaultStartup write FTSettings_DefaultStartup;
    property MirrorCount: Integer read FMirrorCount write FMirrorCount;
    property MirrorColumns: Integer read FMirrorColumns write FMirrorColumns;
    property MirrorHeight: Integer read FMirrorHeight write FMirrorHeight;
    property MirrorPosition: TMirrorPosition read FMirrorPosition write FMirrorPosition;
    property DirectlinksView: TDirectlinksView read FDirectlinksView write FDirectlinksView;
    property DefaultMirrorTabIndex: string read FDefaultMirrorTabIndex write FDefaultMirrorTabIndex;
    property ModyBeforeCrypt: Boolean read FModyBeforeCrypt write FModyBeforeCrypt;
    property SwichAfterCrypt: Boolean read FSwichAfterCrypt write FSwichAfterCrypt;
    property PaddingLeft: Integer read FPaddingLeft write FPaddingLeft;
    property PaddingHeight: Integer read FPaddingHeight write FPaddingHeight;
    property PaddingWidth: Integer read FPaddingWidth write FPaddingWidth;
  end;

  TSettings_Mody = class(TPersistent)
  private
    FSort: Boolean;
    FRemoveDouble: Boolean;
    FFindMissing: Boolean;
    FNotifyOnChange: Boolean;
  published
    property Sort: Boolean read FSort write FSort;
    property RemoveDouble: Boolean read FRemoveDouble write FRemoveDouble;
    property FindMissing: Boolean read FFindMissing write FFindMissing;
    property NotifyOnChange: Boolean read FNotifyOnChange write FNotifyOnChange;
  end;

  TSettings_Login = class(TPersistent)
  private
    FAccountName, FAccountPassword: string;
    FSaveLoginData, FAutoLogin: Boolean;
  published
    property AccountName: string read FAccountName write FAccountName;
    property AccountPassword: string read FAccountPassword write FAccountPassword;
    property SaveLoginData: Boolean read FSaveLoginData write FSaveLoginData;
    property AutoLogin: Boolean read FAutoLogin write FAutoLogin;
  end;

  TCAPTCHAPosition = (cpBottomLeft, cpBottomRight, cpCentered, cpTopLeft, cpTopRight);

  TSettings_ = class(TPersistent)
  private
    FSettings_Plugins: TSettings_Plugins;
    FSettings_Database: TSettings_Database;
    FSettings_Controls: TSettings_Controls;
    FSettings_HTTP: TSettings_HTTP;
    FSettings_Publish: TSettings_Publish;
    FSettings_Layout: TSettings_Layout;
    FSettings_Log: TSettings_Log;
    FSettings_ControlAligner: TSettings_ControlAligner;
    FSettings_Mody: TSettings_Mody;
    FSettings_Login: TSettings_Login;

    FCheckForUpdates: Boolean;
    FActiveTypeName, FActiveEditorTypeName: string;
    FCAPTCHAPosition: TCAPTCHAPosition;
    FMoveWorkWhileHoldingLeftMouse: Boolean;
    FNativeStyle: Boolean;
    FUseSkins: Boolean;
    FDefaultSkin: string;
    FSaveOnClose: Boolean;
  public
    {
      MoveWorkWhileHoldingLeftMouse:Boolean;

      IPicture_ShowImageOnChange:Boolean;
      IPicture_ShowImageOnEnter:Boolean;
      IPicture_ClearImageOnLeave:Boolean;

      fImage_BringToFront:Boolean;
      }
    constructor Create;
    destructor Destroy; override;
  published
    property Plugins: TSettings_Plugins read FSettings_Plugins write FSettings_Plugins;
    property Database: TSettings_Database read FSettings_Database write FSettings_Database;
    property Controls: TSettings_Controls read FSettings_Controls write FSettings_Controls;
    property HTTP: TSettings_HTTP read FSettings_HTTP write FSettings_HTTP;
    property Publish: TSettings_Publish read FSettings_Publish write FSettings_Publish;
    property Layout: TSettings_Layout read FSettings_Layout write FSettings_Layout;
    property Log: TSettings_Log read FSettings_Log write FSettings_Log;
    property ControlAligner: TSettings_ControlAligner read FSettings_ControlAligner write FSettings_ControlAligner;
    property Mody: TSettings_Mody read FSettings_Mody write FSettings_Mody;
    property Login: TSettings_Login read FSettings_Login write FSettings_Login;

    property CheckForUpdates: Boolean read FCheckForUpdates write FCheckForUpdates;
    property ActiveTypeName: string read FActiveTypeName write FActiveTypeName;
    property ActiveEditorTypeName: string read FActiveEditorTypeName write FActiveEditorTypeName;
    property CAPTCHAPosition: TCAPTCHAPosition read FCAPTCHAPosition write FCAPTCHAPosition;
    property MoveWorkWhileHoldingLeftMouse: Boolean read FMoveWorkWhileHoldingLeftMouse write FMoveWorkWhileHoldingLeftMouse;
    property NativeStyle: Boolean read FNativeStyle write FNativeStyle;
    property UseSkins: Boolean read FUseSkins write FUseSkins;
    property DefaultSkin: string read FDefaultSkin write FDefaultSkin;
    property SaveOnClose: Boolean read FSaveOnClose write FSaveOnClose;
  end;

  TSettingsManager = class(TSettingsManager<TSettings_>)
  protected
    procedure LoadDefaultSettings; override;
    procedure VerifySettings; override;
  public
    procedure LoadSettings; override;
    function GetDefaultPluginLoadedFunc(const APluginType: TPlugInType; var ACollection: TCollection; var ACheckListBox: TcxCheckListBox): Boolean;
    procedure LoadDefaultPlugins;

  end;

var
  SettingsManager: TSettingsManager;

implementation

uses
  uApiPluginsAdd;
{$REGION 'T...PlugInCollectionItem'}

function TPlugInCollectionItem.GetPath: string;
begin
  Result := PathCombineEx(GetPluginFolder, Path);
end;

function TPlugInCollectionItem.GetIconHandle: Cardinal;
var
  LLibraryHandle: Cardinal;
begin
  if (FIconHandle = 0) then
  begin
    if FileExists(GetPath) then
    begin
      LLibraryHandle := LoadLibrary(PChar(GetPath));
      try
        if not(LLibraryHandle = 0) then
          FIconHandle := LoadImage(LLibraryHandle, MakeIntResource('icon'), IMAGE_ICON, 16, 16, LR_DEFAULTCOLOR);
      finally
        FreeLibrary(LLibraryHandle);
      end;
    end
  end;

  Result := FIconHandle;
end;

function TPlugInCollectionItem.GetIcon: TIcon;
begin
  if not Assigned(FIcon) then
  begin
    FIcon := TIcon.Create;
    FIcon.Handle := IconHandle;
  end;
  Result := FIcon;
end;

function TPlugInCollectionItem.GetEnabled: Boolean;
begin
  Result := FEnabled and FileExists(GetPath);
end;

destructor TPlugInCollectionItem.Destroy;
begin
  if not(FIconHandle = 0) then
    DestroyIcon(FIconHandle);
  FIcon.Free;
  inherited Destroy;
end;

function TCMSWebsitesCollectionItem.GetHostWithPath: string;
begin
  Result := RemoveW(ExtractUrlHostWithPath(Website));
end;

function TCMSWebsitesCollectionItem.GetPath: string;
begin
  Result := PathCombineEx(GetTemplatesSiteFolder, Path);
end;

function TCMSWebsitesCollectionItem.GetSubjectFileName: string;
begin
  Result := PathCombineEx(GetTemplatesCMSFolder, SubjectFileName);
end;

function TCMSWebsitesCollectionItem.GetMessageFileName: string;
begin
  Result := PathCombineEx(GetTemplatesCMSFolder, MessageFileName);
end;

constructor TCMSCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  FWebsites := TCollection.Create(TCMSWebsitesCollectionItem);
  FOnSettingsChange := TICMSItemChangeEvent.Create;
  FOnWebsitesChange := TICMSItemChangeEvent.Create;
  FOnSubjectsChange := TICMSItemChangeEvent.Create;
  FOnMessagesChange := TICMSItemChangeEvent.Create;
end;

function TCMSCollectionItem.GetWebsite(AIndex: Integer): TCMSWebsitesCollectionItem;
begin
  Result := TCMSWebsitesCollectionItem(Websites.Items[AIndex]);
end;

procedure TCMSCollectionItem.UpdateWebsite(AIndex: Integer);
var
  LCMSWebsitesCollectionItem: TCMSWebsitesCollectionItem;
begin
  LCMSWebsitesCollectionItem := GetWebsite(AIndex);
  with LCMSWebsitesCollectionItem, TWebsiteTemplateHelper.Load(GetPath) do
  begin
    Website := WebsiteURL;
    Filter := WebsiteFilter;
    CustomFields := WebsiteCustomFields;
  end;
  if Assigned(OnWebsitesChange) then
    OnWebsitesChange.Invoke(cctChange, LCMSWebsitesCollectionItem.Index, -1);
end;

procedure TCMSCollectionItem.UpdateWebsites;
var
  I: Integer;
begin
  for I := 0 to Websites.Count - 1 do
    UpdateWebsite(I);
end;

function TCMSCollectionItem.FindCMSWebsite(const ACMSWebsiteName: string): TCMSWebsitesCollectionItem;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Websites.Count - 1 do
    if SameStr(ACMSWebsiteName, TPlugInCollectionItem(Websites.Items[I]).Name) then
    begin
      Result := TCMSWebsitesCollectionItem(Websites.Items[I]);
      break;
    end;
end;

destructor TCMSCollectionItem.Destroy;
begin
  FOnMessagesChange.Free;
  FOnSubjectsChange.Free;
  FOnWebsitesChange.Free;
  FOnSettingsChange.Free;

  FWebsites.Free;

  inherited Destroy;
end;

function TCrawlerCollectionItem.GetContingentStatus(ATypeID: TTypeID; AComponentID: TControlID): Boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 0 to FContingent.Count - 1 do
  begin
    if (TCrawlerContingentCollectionItem(FContingent.Items[I]).TypeID = ATypeID) and (TCrawlerContingentCollectionItem(FContingent.Items[I]).ControlID = AComponentID) then
    begin
      Result := TCrawlerContingentCollectionItem(FContingent.Items[I]).Status;
      break;
    end;
  end;
end;

procedure TCrawlerCollectionItem.SetContingentStatus(ATypeID: TTypeID; AComponentID: TControlID; Status: Boolean);
var
  I: Integer;
begin
  for I := 0 to FContingent.Count - 1 do
  begin
    if (TCrawlerContingentCollectionItem(FContingent.Items[I]).TypeID = ATypeID) and (TCrawlerContingentCollectionItem(FContingent.Items[I]).ControlID = AComponentID) then
    begin
      TCrawlerContingentCollectionItem(FContingent.Items[I]).Status := Status;
      break;
    end;
  end;
end;

constructor TCrawlerCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  FContingent := TCollection.Create(TCrawlerContingentCollectionItem);
end;

destructor TCrawlerCollectionItem.Destroy;
begin
  FContingent.Free;

  inherited Destroy;
end;
{$ENDREGION}
{ ****************************************************************************** }
{$REGION 'TSettings_Plugins'}

constructor TSettings_Plugins.Create;
begin
  inherited Create;

  FApp := TCollection.Create(TAppCollectionItem);
  FCMS := TCollection.Create(TCMSCollectionItem);
  FCAPTCHA := TCollection.Create(TPlugInCollectionItem);
  FCrawler := TCollection.Create(TCrawlerCollectionItem);
  FCrypter := TCollection.Create(TCrypterCollectionItem);
  FFileFormats := TCollection.Create(TFileFormatsCollectionItem);
  FFileHoster := TCollection.Create(TPlugInCollectionItem);
  ImageHoster := TCollection.Create(TImageHosterCollectionItem);

  FAppImageList := TImageList.Create(nil);
  with FAppImageList do
  begin
    ColorDepth := cd32Bit;
    DrawingStyle := dsTransparent;
  end;
  FCMSImageList := TImageList.Create(nil);
  with FCMSImageList do
  begin
    ColorDepth := cd32Bit;
    DrawingStyle := dsTransparent;
  end;
  FCAPTCHAImageList := TImageList.Create(nil);
  with FCAPTCHAImageList do
  begin
    ColorDepth := cd32Bit;
    DrawingStyle := dsTransparent;
  end;
  FCrawlerImageList := TImageList.Create(nil);
  with FCrawlerImageList do
  begin
    ColorDepth := cd32Bit;
    DrawingStyle := dsTransparent;
  end;
  FCrypterImageList := TImageList.Create(nil);
  with FCrypterImageList do
  begin
    ColorDepth := cd32Bit;
    DrawingStyle := dsTransparent;
  end;
  FFileFormatsImageList := TImageList.Create(nil);
  with FFileFormatsImageList do
  begin
    ColorDepth := cd32Bit;
    DrawingStyle := dsTransparent;
  end;
  FFileHosterImageList := TImageList.Create(nil);
  with FFileHosterImageList do
  begin
    ColorDepth := cd32Bit;
    DrawingStyle := dsTransparent;
  end;
  FImageHosterImageList := TImageList.Create(nil);
  with FImageHosterImageList do
  begin
    ColorDepth := cd32Bit;
    DrawingStyle := dsTransparent;
  end;

  FOnCMSChange := TIPluginChangeEvent.Create;
end;

function TSettings_Plugins.FindPlugInCollectionItemFromCollection(const APlugInCollectionItemName: string; ACollection: TCollection): TPlugInCollectionItem;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to ACollection.Count - 1 do
    if (APlugInCollectionItemName = TPlugInCollectionItem(ACollection.Items[I]).Name) then
    begin
      Result := TPlugInCollectionItem(ACollection.Items[I]);
      break;
    end;
end;

destructor TSettings_Plugins.Destroy;
begin
  FOnCMSChange.Free;

  FImageHosterImageList.Free;
  FFileHosterImageList.Free;
  FFileFormatsImageList.Free;
  FCrypterImageList.Free;
  FCrawlerImageList.Free;
  FCAPTCHAImageList.Free;
  FCMSImageList.Free;
  FAppImageList.Free;

  FApp.Free;
  FCAPTCHA.Free;
  FCMS.Free;
  FCrawler.Free;
  FCrypter.Free;
  FFileHoster.Free;
  FFileFormats.Free;
  ImageHoster.Free;

  inherited Destroy;
end;
{$ENDREGION}
{ ****************************************************************************** }
{$REGION 'TSettings_Database'}

function TSettings_Database.GetActiveDatabase;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Database.Count - 1 do
    if (ActiveDatabaseName = TDatabaseCollectionItem(Database.Items[I]).Name) then
    begin
      Result := TDatabaseCollectionItem(Database.Items[I]);
      break;
    end;
end;

procedure TSettings_Database.SetActiveDatabase(ADatabaseCollectionItem: TDatabaseCollectionItem);
var
  I: Integer;
begin
  for I := 0 to Database.Count - 1 do
    if (ActiveDatabaseName = TDatabaseCollectionItem(Database.Items[I]).Name) then
    begin
      Database.Items[I] := ADatabaseCollectionItem;
      break;
    end;
end;

constructor TSettings_Database.Create;
begin
  inherited Create;

  FDatabase := TCollection.Create(TDatabaseCollectionItem);
end;

function TSettings_Database.GetDatabaseItemList;
var
  I: Integer;
begin
  Result := TStringList.Create;

  for I := 0 to Database.Count - 1 do
    Result.Add(TDatabaseCollectionItem(Database.Items[I]).Name);
end;

destructor TSettings_Database.Destroy;
begin
  FDatabase.Free;

  inherited Destroy;
end;
{$ENDREGION}
{ ****************************************************************************** }

constructor TControlCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  FItems := TCollection.Create(TControlItemsCollectionItem);
end;

function TControlCollectionItem.GetItems;
var
  I: Integer;

begin
  with TStringList.Create do
    try
      for I := 0 to FItems.Count - 1 do
        Add(TControlItemsCollectionItem(FItems.Items[I]).ItemName);

      Result := Text;
    finally
      Free;
    end;
end;

destructor TControlCollectionItem.Destroy;
begin
  FItems.Free;

  inherited Destroy;
end;

{ ****************************************************************************** }

constructor TControlsCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  FControls := TCollection.Create(TControlCollectionItem);
end;

destructor TControlsCollectionItem.Destroy;
begin
  FControls.Free;

  inherited Destroy;
end;

{ ****************************************************************************** }

function TSettings_Controls.GetControls(ATypeID: TTypeID; AComponentID: TControlID): TControlCollectionItem;
var
  I, X: Integer;
begin
  for I := 0 to FControlsTT.Count - 1 do
    if (TControlsCollectionItem(FControlsTT.Items[I]).FTypeID = ATypeID) then
      for X := 0 to TControlsCollectionItem(FControlsTT.Items[I]).Controls.Count - 1 do
        with TControlCollectionItem(TControlsCollectionItem(FControlsTT.Items[I]).Controls.Items[X]) do
          if (AComponentID = FControlID) then
          begin
            Result := TControlCollectionItem(TControlsCollectionItem(FControlsTT.Items[I]).Controls.Items[X]);
            break;
          end;
end;

constructor TSettings_Controls.Create;
begin
  inherited Create;

  FControlsTT := TCollection.Create(TControlsCollectionItem);
end;

function TSettings_Controls.GetCustomisedComponentValue(const AComponentID: TControlID; const ATypeID: TTypeID; const AValue: string): string;
var
  I, J: Integer;
begin
  with Controls[ATypeID, AComponentID].Items do
    for I := 0 to Count - 1 do
      if LowerCase(AValue) = LowerCase(TControlItemsCollectionItem(Items[I]).ItemName) then
      begin
        Result := TControlItemsCollectionItem(Items[I]).ItemName;
        break;
      end
      else
        with TStringList.Create do
          try
            Text := TControlItemsCollectionItem(Items[I]).AlsoKnownAs;
            for J := 0 to Count - 1 do
              if LowerCase(AValue) = LowerCase(Strings[J]) then
              begin
                Result := TControlItemsCollectionItem(Items[I]).ItemName;
                break;
              end;
          finally
            Free;
          end;
end;

destructor TSettings_Controls.Destroy;
begin
  FControlsTT.Free;

  inherited Destroy;
end;

{ ****************************************************************************** }

function TSettings_Proxy.GetProxyType: TProxyType;
begin
  FProxyTypeLock.BeginRead;
  try
    Result := FProxyType;
  finally
    FProxyTypeLock.EndRead;
  end;
end;

procedure TSettings_Proxy.SetProxyType(const Value: TProxyType);
begin
  FProxyTypeLock.BeginWrite;
  try
    FProxyType := Value;
  finally
    FProxyTypeLock.EndWrite;
  end;
end;

function TSettings_Proxy.GetServer: string;
begin
  FServerLock.BeginRead;
  try
    Result := FServer;
  finally
    FServerLock.EndRead;
  end;
end;

procedure TSettings_Proxy.SetServer(const Value: string);
begin
  FServerLock.BeginWrite;
  try
    FServer := Value;
  finally
    FServerLock.EndWrite;
  end;
end;

function TSettings_Proxy.GetPort: Integer;
begin
  FPortLock.BeginRead;
  try
    Result := FPort;
  finally
    FPortLock.EndRead;
  end;
end;

procedure TSettings_Proxy.SetPort(const Value: Integer);
begin
  FPortLock.BeginWrite;
  try
    FPort := Value;
  finally
    FPortLock.EndWrite;
  end;
end;

function TSettings_Proxy.GetRequireAuthentication: Boolean;
begin
  FRequireAuthenticationLock.BeginRead;
  try
    Result := FRequireAuthentication;
  finally
    FRequireAuthenticationLock.EndRead;
  end;
end;

procedure TSettings_Proxy.SetRequireAuthentication(const Value: Boolean);
begin
  FRequireAuthenticationLock.BeginWrite;
  try
    FRequireAuthentication := Value;
  finally
    FRequireAuthenticationLock.EndWrite;
  end;
end;

function TSettings_Proxy.GetAccountName: string;
begin
  FAccountNameLock.BeginRead;
  try
    Result := FAccountName;
  finally
    FAccountNameLock.EndRead;
  end;
end;

procedure TSettings_Proxy.SetAccountName(const Value: string);
begin
  FAccountNameLock.BeginWrite;
  try
    FAccountName := Value;
  finally
    FAccountNameLock.EndWrite;
  end;
end;

function TSettings_Proxy.GetAccountPassword: string;
begin
  FAccountPasswordLock.BeginRead;
  try
    Result := FAccountPassword;
  finally
    FAccountPasswordLock.EndRead;
  end;
end;

procedure TSettings_Proxy.SetAccountPassword(const Value: string);
begin
  FAccountPasswordLock.BeginWrite;
  try
    FAccountPassword := Value;
  finally
    FAccountPasswordLock.EndWrite;
  end;
end;

function TSettings_Proxy.GetProxySubActivations: TProxySubActivations;
begin
  FProxySubActivationsLock.BeginRead;
  try
    Result := FProxySubActivations;
  finally
    FProxySubActivationsLock.EndRead;
  end;
end;

procedure TSettings_Proxy.SetProxySubActivations(const Value: TProxySubActivations);
begin
  FProxySubActivationsLock.BeginWrite;
  try
    FProxySubActivations := Value;
  finally
    FProxySubActivationsLock.EndWrite;
  end;
end;

constructor TSettings_Proxy.Create;
begin
  inherited Create;
  FProxyTypeLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FServerLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FPortLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FRequireAuthenticationLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FAccountNameLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FAccountPasswordLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FProxySubActivationsLock := TMultiReadExclusiveWriteSynchronizer.Create;
end;

destructor TSettings_Proxy.Destroy;
begin
  FProxySubActivationsLock.Free;
  FAccountPasswordLock.Free;
  FAccountNameLock.Free;
  FRequireAuthenticationLock.Free;
  FPortLock.Free;
  FServerLock.Free;
  FProxyTypeLock.Free;
  inherited Destroy;
end;

{ ****************************************************************************** }

function TSettings_HTTP.GetMaxSimultaneousConnections;
begin
  FMaxSimultaneousConnectionsLock.BeginRead;
  try
    Result := FMaxSimultaneousConnections;
  finally
    FMaxSimultaneousConnectionsLock.EndRead;
  end;
end;

procedure TSettings_HTTP.SetMaxSimultaneousConnections(const Value: Integer);
begin
  FMaxSimultaneousConnectionsLock.BeginWrite;
  try
    FMaxSimultaneousConnections := Value;
  finally
    FMaxSimultaneousConnectionsLock.EndWrite;
  end;
end;

function TSettings_HTTP.GetConnectTimeout: Integer;
begin
  FConnectTimeoutLock.BeginRead;
  try
    Result := FConnectTimeout;
  finally
    FConnectTimeoutLock.EndRead;
  end;
end;

procedure TSettings_HTTP.SetConnectTimeout(const Value: Integer);
begin
  FConnectTimeoutLock.BeginWrite;
  try
    FConnectTimeout := Value;
  finally
    FConnectTimeoutLock.EndWrite;
  end;
end;

function TSettings_HTTP.GetReadTimeout: Integer;
begin
  FReadTimeoutLock.BeginRead;
  try
    Result := FReadTimeout;
  finally
    FReadTimeoutLock.EndRead;
  end;
end;

procedure TSettings_HTTP.SetReadTimeout(const Value: Integer);
begin
  FReadTimeoutLock.BeginWrite;
  try
    FReadTimeout := Value;
  finally
    FReadTimeoutLock.EndWrite;
  end;
end;

constructor TSettings_HTTP.Create;
begin
  inherited Create;
  FMaxSimultaneousConnectionsLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FConnectTimeoutLock := TMultiReadExclusiveWriteSynchronizer.Create;
  FReadTimeoutLock := TMultiReadExclusiveWriteSynchronizer.Create;
  Proxy := TSettings_Proxy.Create;
end;

function TSettings_HTTP.GetProxy(AProxySubActivation: TProxySubActivation): IProxy;
begin
  Result := TProxy.Create;

  with Proxy do
    if (AProxySubActivation in TProxySubActivations(Byte(Proxy.ProxySubActivations))) then
      Result.Activate(ProxyType, Server, Port, RequireAuthentication, AccountName, AccountPassword);
end;

destructor TSettings_HTTP.Destroy;
begin
  Proxy.Free;
  FReadTimeoutLock.Free;
  FConnectTimeoutLock.Free;
  FMaxSimultaneousConnectionsLock.Free;
  inherited Destroy;
end;

{ ****************************************************************************** }

constructor TLayoutCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);

end;

destructor TLayoutCollectionItem.Destroy;
begin

  inherited Destroy;
end;

{ ****************************************************************************** }

{ TLayoutforForms }

procedure TLayoutforForms.LoadLayout(const AForm: TForm);
begin
  AForm.Left := Left;
  AForm.Height := Height;
  AForm.Top := Top;
  AForm.Width := Width;

  if not (WindowState = wsNormal) then
  begin
    AForm.WindowState := wsNormal;
    if (WindowState = wsMinimized) then
    begin
      Application.Minimize; // required
      ShowWindowAsync(AForm.Handle, SW_MINIMIZE);
    end
    else
    begin
      ShowWindowAsync(AForm.Handle, SW_MAXIMIZE);
    end;
  end
  else
  begin
    AForm.WindowState := WindowState;
  end;
end;

procedure TLayoutforForms.SaveLayout(const AForm: TForm);
begin
  if not (AForm.WindowState = wsNormal) then
  begin
    WindowState := AForm.WindowState;
  end
  else
  begin
    Left := AForm.Left;
    Height := AForm.Height;
    Top := AForm.Top;
    Width := AForm.Width;
    WindowState := AForm.WindowState;
  end;
end;

{ ****************************************************************************** }
{$REGION 'TSettings_Layout'}

function TSettings_Layout.GetActiveLayout;
begin
  Result := FindLayout(ActiveLayoutName);
end;

procedure TSettings_Layout.SetActiveLayout(ALayoutCollectionItem: TLayoutCollectionItem);
var
  I: Integer;
begin
  for I := 0 to Layout.Count - 1 do
    if (ActiveLayoutName = TLayoutCollectionItem(Layout.Items[I]).name) then
    begin
      Layout.Items[I] := ALayoutCollectionItem;
      break;
    end;
end;

procedure TSettings_Layout.SetActiveLayoutName(const AActiveLayoutName: string);
begin
  FActiveLayoutName := AActiveLayoutName;

  if Assigned(FOnLayoutChanged) then
    FOnLayoutChanged(nil);
end;

constructor TSettings_Layout.Create;
begin
  inherited Create;

  FMain := TLayoutforForms.Create;
  FSettings := TLayoutforForms.Create;
  FLayout := TCollection.Create(TLayoutCollectionItem);
end;

function TSettings_Layout.GetLayoutItemList;
var
  I: Integer;
begin
  Result := TStringList.Create;

  for I := 0 to Layout.Count - 1 do
    Result.Add(TLayoutCollectionItem(Layout.Items[I]).name);
end;

function TSettings_Layout.FindLayout(const ALayoutName: string): TLayoutCollectionItem;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Layout.Count - 1 do
    if (ALayoutName = TLayoutCollectionItem(Layout.Items[I]).name) then
    begin
      Result := TLayoutCollectionItem(Layout.Items[I]);
      break;
    end;
end;

destructor TSettings_Layout.Destroy;
begin
  FLayout.Free;
  FSettings.Free;
  FMain.Free;

  inherited Destroy;
end;
{$ENDREGION}
{ ****************************************************************************** }

constructor TSettings_ControlAligner.Create;
begin
  inherited Create;
  FTSettings_DefaultStartup := TSettings_DefaultStartup.Create;
end;

destructor TSettings_ControlAligner.Destroy;
begin
  FTSettings_DefaultStartup.Free;
  inherited Destroy;
end;

{ ****************************************************************************** }

constructor TSettings_.Create;
begin
  inherited Create;
  Plugins := TSettings_Plugins.Create;
  Database := TSettings_Database.Create;
  Controls := TSettings_Controls.Create;
  HTTP := TSettings_HTTP.Create;
  Publish := TSettings_Publish.Create;
  Log := TSettings_Log.Create;
  Layout := TSettings_Layout.Create;
  ControlAligner := TSettings_ControlAligner.Create;
  Mody := TSettings_Mody.Create;
  Login := TSettings_Login.Create;
end;

destructor TSettings_.Destroy;
begin
  Plugins.Free;
  Database.Free;
  Controls.Free;
  HTTP.Free;
  Publish.Free;
  Log.Free;
  Layout.Free;
  ControlAligner.Free;
  Mody.Free;
  Login.Free;
  inherited Destroy;
end;

{ ****************************************************************************** }
{$REGION 'TSettingsManager'}

procedure TSettingsManager.LoadDefaultSettings;

  function LoadRes(AResName: string): string;
  var
    _StringStream: TStringStream;
  begin
    with TResourceStream.Create(0, AResName, RT_RCDATA) do
      try
        _StringStream := TStringStream.Create;
        try
          SaveToStream(_StringStream);
          Result := _StringStream.DataString;
        finally
          _StringStream.Free;
        end;
      finally
        Free;
      end;
  end;

begin
  ResetInternalSettings;

  with SettingsManager.Settings do
  begin
    {
      with Database do
      begin
      with TDatabaseCollectionItem(Database.Add) do
      begin
      Name := 'backup';
      Enabled := True;
      //Connectivity := mkSQLite;
      Database := GetSettingsFolder + BackupFilename;
      end;
      end;
      }
    with Controls do
    begin
      LoadDefaultControlValues(ControlsTT);
      IRichEditWrapText := False;
      DropDownRows := 8;
    end;

    with HTTP do
    begin
      MaxSimultaneousConnections := 4;
      // ConnectTimeout := 5000;
      // ReadTimeout := 10000;
    end;

    with Publish do
    begin
      PublishMaxCount := 2;
    end;

    with Layout do
    begin
      with Main do
      begin
        Left := 0;
        Height := 684;
        Top := 0;
        Width := 1046;
        WindowState := wsNormal;
      end;

      with Settings do
      begin
        Left := 0;
        Height := 412;
        Top := 0;
        Width := 622;
        WindowState := wsNormal;
      end;

      with TLayoutCollectionItem(Layout.Add) do
      begin
        name := 'default';

        DockControls := LoadRes('DOCKMANAGER');
        BarManager := LoadRes('BARMANAGER');
      end;

      ActiveLayoutName := 'default';
    end;

    with Log do
    begin
      MaxLogEntries := 200;
      MaxHTTPLogEntries := 15;
    end;

    with ControlAligner do
    begin
      MirrorCount := 1;
      MirrorColumns := 1;
      MirrorHeight := 120;
      MirrorPosition := mpBottom;
      DirectlinksView := dlvGrid;
      DefaultMirrorTabIndex := StrDirectlinks;
      PaddingLeft := 6;
      PaddingHeight := 6;
      PaddingWidth := 6;
    end;

    with Mody do
    begin
      Sort := True;
    end;

    CheckForUpdates := False;
    MoveWorkWhileHoldingLeftMouse := True;
    NativeStyle := True;
    // UseSkins := True;
    // DefaultSkin := 'Blue';
    SaveOnClose := True;
  end;
end;

procedure TSettingsManager.VerifySettings;
begin
  with SettingsManager.Settings do
  begin

    with ControlAligner do
    begin
      if not(MirrorCount > 0) then
        MirrorCount := 1;

      if not(MirrorColumns > 0) then
        MirrorColumns := 1;

      if not(MirrorHeight >= 50) then
        MirrorHeight := 50;
    end;

    with HTTP do
    begin
      if not(MaxSimultaneousConnections > 0) then
        MaxSimultaneousConnections := 1;
    end;

  end;
end;

procedure TSettingsManager.LoadSettings;
var
  LCMSIndex: Integer;
begin
  inherited LoadSettings;
  if not FirstStart then
  begin
    for LCMSIndex := 0 to Settings.Plugins.CMS.Count - 1 do
    begin
      TCMSCollectionItem(Settings.Plugins.CMS.Items[LCMSIndex]).UpdateWebsites;
    end;
  end;
end;

function TSettingsManager.GetDefaultPluginLoadedFunc(const APluginType: TPlugInType; var ACollection: TCollection; var ACheckListBox: TcxCheckListBox): Boolean;
begin
  ACheckListBox := nil;

  case APluginType of
    ptNone:
      Exit(False);
    ptApp:
      ACollection := SettingsManager.Settings.Plugins.App;
    ptCAPTCHA:
      ACollection := SettingsManager.Settings.Plugins.CAPTCHA;
    ptCMS:
      ACollection := SettingsManager.Settings.Plugins.CMS;
    ptCrawler:
      ACollection := SettingsManager.Settings.Plugins.Crawler;
    ptCrypter:
      ACollection := SettingsManager.Settings.Plugins.Crypter;
    ptFileFormats:
      ACollection := SettingsManager.Settings.Plugins.FileFormats;
    ptFileHoster:
      ACollection := SettingsManager.Settings.Plugins.FileHoster;
    ptImageHoster:
      ACollection := SettingsManager.Settings.Plugins.ImageHoster;
  end;

  Result := True;
end;

procedure TSettingsManager.LoadDefaultPlugins;
var
  LPlugInCollectionItem: TPlugInCollectionItem;
begin
  with SettingsManager.Settings.Plugins do
  begin
    if FileExists(GetPluginFolder + 'xrelto.dll') then
      TAddPlugin.Execute(GetDefaultPluginLoadedFunc, ptCrawler, GetPluginFolder + 'xrelto.dll', False, { make the error message silent } procedure(const AErrorMsg: string)begin end);

    if FileExists(GetPluginFolder + 'releasename.dll') then
      TAddPlugin.Execute(GetDefaultPluginLoadedFunc, ptCrawler, GetPluginFolder + 'releasename.dll', False, { make the error message silent } procedure(const AErrorMsg: string)begin end);

    LPlugInCollectionItem := FindPlugInCollectionItemFromCollection('Releasename', Crawler);
    if Assigned(LPlugInCollectionItem) then
      LPlugInCollectionItem.Enabled := True;

    if FileExists(GetPluginFolder + 'intelligenxml2.dll') then
      TAddPlugin.Execute(GetDefaultPluginLoadedFunc, ptFileFormats, GetPluginFolder + 'intelligenxml2.dll', False, { make the error message silent } procedure(const AErrorMsg: string)begin end);

    LPlugInCollectionItem := FindPlugInCollectionItemFromCollection('intelligen.xml.2', FileFormats);
    if Assigned(LPlugInCollectionItem) then
      LPlugInCollectionItem.Enabled := True;

    TAddPlugin.ExecuteFolder(GetDefaultPluginLoadedFunc, GetPluginFolder);
  end;
end;

initialization

SettingsManager := TSettingsManager.Create(GetSettingsFolder);

finalization

if SettingsManager.Settings.SaveOnClose then
  SettingsManager.SaveSettings;
SettingsManager.Free;

end.
