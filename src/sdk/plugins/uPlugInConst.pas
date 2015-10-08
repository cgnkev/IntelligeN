unit uPlugInConst;

interface

type
  TPlugInType = (ptApp, ptCAPTCHA, ptCMS, ptCrawler, ptCrypter, ptFileFormats, ptFileHoster, ptImageHoster);
  TCAPTCHAInput = function(const ACAPTCHA: WideString; const AName: WideString; out AText: WideString; var ACookies: WideString): WordBool of object; safecall;
  TCAPTCHAType = (ctImage, ctText);
  TIntelligentPostingHelper = function(var ASearchValue: WideString; const ASearchResults: WideString; var ASearchIndex: Integer; out ARedoSearch: WordBool): WordBool of object; safecall;
  TCMSType = (cmsBoard, cmsBlog, cmsFormbased);
  TCMSIDType = (citCategory, citPrefix, citIcon);
  TFoldertype = (ftWeb, ftPlain, ftContainer);
  TFoldertypes = set of TFoldertype;
  TContainertype = (ctDLC, ctCCF, ctRSDF);
  TContainertypes = set of TContainertype;
  TAdvertismenttype = (atLayer, atLink, atBanner);
  TImageHostResize = (irNone, ir320x240, ir450x338, ir640x480, ir800x600);
  TLinkStatus = (lsOffline, lsOnline, lsUnknown, lsTemporaryOffline);
  TChecksumType = (ctMD5);

  TIDInfo = packed record
    ID, Path: WideString;
  end;

  TLinkInfo = packed record
    Link: WideString;
    Status: TLinkStatus;
    Size: Int64; { in Bytes }
    FileName, Checksum: WideString;
    ChecksumType: TChecksumType;
  end;

  TLinksInfo = packed record
    Status: Byte; { 0=offline|1=online|2=unknown;3=notyet;4=mixed;255=noinfo }
    Size: Extended;
    PartSize: Extended;
    Links: array of TLinkInfo;
  end;

  TCrypterFolderInfo = packed record
    Link: WideString;
    Status: Byte; { 0=offline|1=online|2=unknown;3=notyet;4=mixed;255=noinfo }
    Size: Double; { in Megabytes }
    Hoster: WideString; { Uploaded.to or Uploaded or up.to }
    HosterShort: WideString;
    Parts: Integer;
    StatusImage, StatusImageText: WideString;
  end;
  // PCrypterFolderInfo = ^TCrypterFolderInfo;

implementation

end.
