////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Project   : FWZip
//  * Unit Name : FWZipWriter
//  * Purpose   : ����� ��� �������� ZIP ������
//  * Author    : ��������� (Rouse_) ������
//  * Copyright : � Fangorn Wizards Lab 1998 - 2011.
//  * Version   : 1.0.3
//  * Home Page : http://rouse.drkb.ru
//  ****************************************************************************
//
//  ������������ ���������:
//  ftp://ftp.info-zip.org/pub/infozip/doc/appnote-iz-latest.zip
//  http://zlib.net/zlib-1.2.5.tar.gz
//

unit FWZipWriter;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Contnrs,
  FWZipConsts,
  FWZipCrc32,
  FWZipCrypt,
  FWZipStream,
  {$IFDEF USE_ZLIB_DLL}
  ZLib_external
  {$ELSE}
  ZLib
  {$ENDIF};

type
  TFWZipWriter = class;
  
  TFWZipWriterItem = class
  private
    FOwner: TFWZipWriter;
    FComment: string;                // ���������� � ��������
    FFilePath: string;               // ���� � �������� ����� (��� ��. TFWZipWriterItemEx.Data)
    FFileName: string;               // ��� �������� � ������ - �� ����� ���� ������
    FPassword: string;               // ������
    FCmpLevel: TCompressionLevel;    // ������� ������
    FNeedDescriptor: Boolean;        // ���� ���������� ������ �������� ������
                                     // � ��������, (���������� ��� ��������� ���������)
    FSize: Int64;
    FData: TMemoryStream;            // ������ �������� � ������ ���� ����
                                     // ����������� �� �����
    FAttributes:                     // ������� ��������� �����
      TWin32FileAttributeData;
    FTag: Integer;
    procedure SetBool(const Value: Boolean);
    procedure SetCmpLevel(const Value: TCompressionLevel);
    procedure SetString(const Index: Integer; const Value: string);
  protected
    property Data: TMemoryStream read FData;
  public
    constructor Create(Owner: TFWZipWriter;
      const InitFilePath: string;
      InitAttributes: TWin32FileAttributeData;
      const InitFileName: string = '');
    destructor Destroy; override;
    procedure ChangeDataStream(Value: TStream);
    procedure ChangeAttributes(Value: TWin32FileAttributeData);
    property Comment: string index 0 read FComment write SetString;
    property FilePath: string index 1 read FFilePath write SetString;
    property FileName: string index 2 read FFileName write SetString;
    property Password: string index 3 read FPassword write SetString;
    property CompressionLevel: TCompressionLevel
      read FCmpLevel write SetCmpLevel;
    property NeedDescriptor: Boolean read FNeedDescriptor write SetBool;
    property Size: Int64 read FSize;
    property Attributes: TWin32FileAttributeData read FAttributes;
    property Tag: Integer read FTag write FTag;
  end;

  // ��������� �������� ������
  TBuildZipResult = 
  (
    brDone,         // ����� ������ �������
    brFailed,       // ������ �������� ������
    brAborted,      // �������� ������ �������� �������������
    brPartialBuild  // ��������� �������� ��������� ��-�� ��������� ������
  );

  TFWZipWriter = class
  private
    FDefaultDescryptorState: Boolean;
    FDefaultCompressionLevel: TCompressionLevel;
    FDefaultPassword: string;
    FItems: TObjectList;
    FCD: array of TCentralDirectoryFileHeaderEx;
    FVersionToExtract: Word;
    FcdfhOffset, FTotalSizeCount, FTotalProcessedCount: Int64;
    FCompressedStream: TStream;
    FProcessedItemIndex: Integer;
    FComment: string;
    FOnProgress: TZipProgressEvent;
    FBuildState: Boolean;
    FSaveExData: TZipSaveExDataEvent;
    FExceptionCount: Integer;
    FBuidException: TZipBuildExceptionEvent;
    function GetItem(Index: Integer): TFWZipWriterItem;
  protected
    procedure CompressorOnProcess(Sender: TObject);
  protected
    function CheckFileNameSlashes(const Value: string): string;
    function GetVersionToExtract(Index: Integer): Word;
    function GetCurrentFileTime: TFileTime;
    procedure SaveItemToStream(Stream: TStream; Index: Integer);
    procedure SaveCentralDirectory(Stream: TStream);
    procedure SaveEndOfCentralDirectory(Stream: TStream);
    procedure SaveString(Stream: TStream; const Value: string);
    procedure UpdateLocalHeaders(Stream: TStream);
    property BuildState: Boolean read FBuildState;
  public
    constructor Create; overload;
    constructor Create(CompressionLevel: TCompressionLevel); overload;
    constructor Create(UseDescryptors: Boolean; 
      CompressionLevel: TCompressionLevel;
      const DefaultPassword: string); overload;
    destructor Destroy; override;
    function AddFile(const FilePath: string;
      const FileName: string = ''): Integer; overload;
    function AddFile(const FilePath: string;
      Attributes: TWin32FileAttributeData;
      const FileName: string = ''): Integer; overload;
    function AddStream(const FileName: string; Value: TStream): Integer;
    function AddFiles(Value: TStringList): Integer;
    function AddFolder(const Path: string;
      SubFolders: Boolean = True): Integer; overload;
    function AddFolder(const RelativePath, Path, Mask: string;
      SubFolders: Boolean = True): Integer; overload;
    function BuildZip(const ZipFilePath: string): TBuildZipResult; overload;
    function BuildZip(Stream: TStream): TBuildZipResult; overload;
    function Count: Integer;
    procedure DeleteItem(Index: Integer);
    property Item[Index: Integer]: TFWZipWriterItem read GetItem; default;
    property Comment: string read FComment write FComment;
    property OnException: TZipBuildExceptionEvent read FBuidException write FBuidException;
    property OnProgress: TZipProgressEvent read FOnProgress write FOnProgress;
    property OnSaveExData: TZipSaveExDataEvent read FSaveExData write FSaveExData;
  end;

implementation

{ TFWZipWriterItem }

//
//  ��������� �������� ��������� �������� ������
// =============================================================================
procedure TFWZipWriterItem.ChangeAttributes(Value: TWin32FileAttributeData);
begin
  if not FOwner.BuildState then
    FAttributes := Value;
end;

//
//  ��������� �������� ���� ������ � �����. ������������� �������� ��� � �����.
// =============================================================================
procedure TFWZipWriterItem.ChangeDataStream(Value: TStream);
begin
  if not FOwner.BuildState then
    if Value.Size <> 0 then
    begin
      if FData = nil then
        FData := TMemoryStream.Create;
      FData.Clear;
      FData.CopyFrom(Value, 0);
      FSize := FData.Size;
      FFilePath := '';
    end;
end;

//
//  ����������� ����������� ������
// =============================================================================
constructor TFWZipWriterItem.Create(Owner: TFWZipWriter;
  const InitFilePath: string;
  InitAttributes: TWin32FileAttributeData; const InitFileName: string);
begin
  inherited Create;
  FData := nil;
  FOwner := Owner;
  FFilePath := InitFilePath;
  FAttributes := InitAttributes;
  FSize :=
    FileSizeToInt64(FAttributes.nFileSizeLow, FAttributes.nFileSizeHigh);  
  FFileName := InitFileName;
end;

//
//  ����������� ���������� ������
// =============================================================================
destructor TFWZipWriterItem.Destroy;
begin
  FData.Free;
  inherited;
end;

//
//  ��������� �������� ���� ����������� ��������
// =============================================================================
procedure TFWZipWriterItem.SetBool(const Value: Boolean);
begin
  if not FOwner.BuildState then
    FNeedDescriptor := Value;
end;

//
//  ��������� �������� ������� ������ ��������
// =============================================================================
procedure TFWZipWriterItem.SetCmpLevel(const Value: TCompressionLevel);
begin
  if not FOwner.BuildState then
    FCmpLevel := Value;
end;

//
//  ��������� �������� ��������� �������� ��������.
//  ��� ��������� ���� � �����, ������������� ��������������
//  ����� ��������� ����� � ��������� ����� FData �� �������������
// =============================================================================
procedure TFWZipWriterItem.SetString(const Index: Integer;
  const Value: string);
var
  Attributes: TWin32FileAttributeData;
begin
  if not FOwner.BuildState then
    case Index of
      0: FComment := Value;
      1:
      begin
        if FileExists(Value) then
        begin
          // �������� ������ � ��� ������ ���� ������ ��������
          // � �� ������ ����� ��� ���������
          if GetFileAttributesEx(PChar(Value),
            GetFileExInfoStandard, @Attributes) then
          begin
            FAttributes := Attributes;
            FSize :=
              FileSizeToInt64(Attributes.nFileSizeLow, Attributes.nFileSizeHigh);
            FFilePath := Value;
            if FData <> nil then
              FreeAndNil(FData);
          end;
        end;
      end;
      2:
        if Length(Value) >= MAX_PATH then
          raise Exception.Create('������� ������� ����.')
        else
          FFileName := Value;
      3: FPassword := Value;
    end;
end;

{ TFWZipWriter }

//
//  ������� ��������� ��������� ���� � ������.
//  � �������� ���������� ���������� ������ �������� � ������.
//  ���������:
//  FilePath - ���� � �����
//  FileName - ������������ ����� � ������
//    (������� ������������� ���� �� ����� ������)
// =============================================================================
function TFWZipWriter.AddFile(const FilePath,
  FileName: string): Integer;
var
  Attributes: TWin32FileAttributeData;
  FullFilePath: string;
begin
  Result := -1;
  FullFilePath := PathCanonicalize(FilePath);
  // ��������� ������ � ��� ������ ���� ������ ��������
  // � �� ������ ����� ��� ���������
  if GetFileAttributesEx(PChar(FullFilePath),
    GetFileExInfoStandard, @Attributes) then
    Result := AddFile(FullFilePath, Attributes, FileName);
end;

//
//  ������� ��������� ��������� ���� � ������.
//  � �������� ���������� ���������� ������ �������� � ������.
//  ���������:
//  FilePath - ���� � �����
//  Attributes - ��������� �����
//  FileName - ������������ ����� � ������
//    (������� ������������� ���� �� ����� ������)
// =============================================================================
function TFWZipWriter.AddFile(const FilePath: string;
  Attributes: TWin32FileAttributeData; const FileName: string): Integer;
var
  Item: TFWZipWriterItem;
  InitFileName, FullFilePath: string;
begin
  // �������� ��� ��� ��������. ����� ��� ����?
  Result := -1;
  FullFilePath := PathCanonicalize(FilePath);
  if not FileExists(FullFilePath) then Exit;
  if FileName = '' then
    InitFileName := ExtractFileName(ExcludeTrailingPathDelimiter(FullFilePath))
  else
    InitFileName := CheckFileNameSlashes(FileName);

  Item := TFWZipWriterItem.Create(Self, FullFilePath, Attributes, InitFileName);
  Item.CompressionLevel := FDefaultCompressionLevel;
  Item.Password := FDefaultPassword;

  // � ������ ������� ����������� �� �����
  // ����������� ������ ����������� ����� �� ����, �.�. ��� ����������
  // ������ ���������� ��� �� ��������� � ��������� ��������� �������������
  Item.NeedDescriptor := FDefaultDescryptorState;

  Result := FItems.Add(Item);
end;

//
//  ������� ��������� ����� ������ � ������.
//  � �������� ���������� ���������� ���������� ������� ����������� ���������.
// =============================================================================
function TFWZipWriter.AddFiles(Value: TStringList): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Value.Count - 1 do
    if AddFile(Value.ValueFromIndex[I], Value.Names[I]) >= 0 then
      Inc(Result);
end;

//
//  ������� ��������� ����� �� �������� �����
//  � �������� ���������� ���������� ���������� ������� ����������� ���������.
//  ���������:
//  Path - ���� � ����� �� ������� ����� ����������� ������
//  SubFolders - ��������� ������ �� �������� ��� ���.
// =============================================================================
function TFWZipWriter.AddFolder(const Path: string; SubFolders: Boolean): Integer;
begin
  Result := AddFolder(ExtractFileName(
    ExcludeTrailingPathDelimiter(PathCanonicalize(Path))),
    Path, '*.*', SubFolders);
end;

//
//  ����������� ������� AddFolder
//  ������� ��������� ����� �� �������� �����
//  � �������� ���������� ���������� ���������� ������� ����������� ���������.
//  ���������:
//  RelativePath - ���� � �������� � ������ ������������ �����.
//  Path - ���� � ����� �� ������� ����� ����������� ������
//  Mask - ����� ������ ������
//  SubFolders - ��������� ������ �� �������� ��� ���.
// =============================================================================
function TFWZipWriter.AddFolder(const RelativePath, Path, Mask: string;
  SubFolders: Boolean): Integer;
var
  SR: TSearchRec;
  TrailingPath, TrailingRelativePath, ResultMask: string;
  Attributes: TWin32FileAttributeData;
begin
  Result := 0;
  // ������� ����������� ������������ �����
  // ������������ ����� - �������� RelativePath
  // � ������� ���������� ���� � ����� ��� ����� ������������ �������� �����
  if RelativePath = '' then
    TrailingRelativePath := ''
  else
    TrailingRelativePath := IncludeTrailingPathDelimiter(RelativePath);
  TrailingPath := IncludeTrailingPathDelimiter(PathCanonicalize(Path));
  if Mask = '' then
    ResultMask := '*.*'
  else
    ResultMask := Mask;
  if FindFirst(TrailingPath + ResultMask, faAnyFile, SR) = 0 then
  try
    repeat
      if (SR.Name = '.') or (SR.Name = '..') then Continue;
      if SR.Attr and faDirectory <> 0 then
      begin
        if SubFolders then
          AddFolder(TrailingRelativePath + SR.Name,
            TrailingPath + SR.Name, ResultMask, SubFolders);
      end
      else
      begin
        {$WARN SYMBOL_PLATFORM OFF}
        Attributes.dwFileAttributes := SR.FindData.dwFileAttributes;
        Attributes.ftCreationTime := SR.FindData.ftCreationTime;
        Attributes.ftLastAccessTime := SR.FindData.ftLastAccessTime;
        Attributes.ftLastWriteTime := SR.FindData.ftLastWriteTime;
        Attributes.nFileSizeHigh := SR.FindData.nFileSizeHigh;
        Attributes.nFileSizeLow := SR.FindData.nFileSizeLow;
        {$WARN SYMBOL_PLATFORM ON}
        if AddFile(TrailingPath + SR.Name, Attributes,
          TrailingRelativePath + SR.Name) >= 0 then
          Inc(Result);
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

//
//  ������� ��������� � ����� ������ �� ����������� ������.
//  � �������� ���������� ���������� ������ �������� � ������
// =============================================================================
function TFWZipWriter.AddStream(const FileName: string;
  Value: TStream): Integer;
var
  Size: Int64;
  InitFileName: string;
  Item: TFWZipWriterItem;
  Attributes: TWin32FileAttributeData;
begin
  // �������� �� �����
  InitFileName := CheckFileNameSlashes(FileName);

  Size := Value.Size;
  ZeroMemory(@Attributes, SizeOf(TWin32FileAttributeData));
  Attributes.ftCreationTime := GetCurrentFileTime;
  Attributes.ftLastAccessTime := Attributes.ftCreationTime;
  Attributes.ftLastWriteTime := Attributes.ftCreationTime;
  Attributes.nFileSizeLow := Size and MAXDWORD;
  Attributes.nFileSizeHigh := Size shr 32;
  Item := TFWZipWriterItem.Create(Self, '', Attributes, InitFileName);
  Item.CompressionLevel := FDefaultCompressionLevel;
  Item.Password := FDefaultPassword;

  // � ������ ������� ����������� �� �����
  // ����������� ������ ����������� ����� �� ����, �.�. ��� ����������
  // ������ ���������� ��� �� ��������� � ��������� ��������� �������������
  Item.NeedDescriptor := FDefaultDescryptorState;

  Item.ChangeDataStream(Value);
  Result := FItems.Add(Item);
end;

//
//  ��������� ��������� ����� � ��������� ��� � ��������� �����.
// =============================================================================
function TFWZipWriter.BuildZip(Stream: TStream): TBuildZipResult;
var
  I, TotalCount: Integer;
  BeforeExceptPosition: Int64;
  ExceptAction: TExceptionAction;
  OldPathName, NewFilePath: string;
  NewFileData: TMemoryStream;
  DeletePackedFile: Boolean;
begin
  FBuildState := True;
  try
    Result := brFailed;
    if Count > 0 then
    begin
      // ���������� ������� CentralDirectory
      SetLength(FCD, Count);

      // ������������ ����� ������ ��������� ��� ����������� ���������
      FTotalSizeCount := 0;
      FTotalProcessedCount := 0;
      for I := 0 to Count - 1 do
        Inc(FTotalSizeCount, Item[I].Size);

      // ������� ��� ����� ������ � �������� �� � ��������� �����
      // ��� ���� ������������� ����� ��� LocalHeader � DataDescryptor
      // �.�. ������ ������������� ����� ����� �������� ������ ����� �����
      // ��������� � �� ������� ���� �������� ��������:
      // � LocalHeader, DataDescryptor ��� � ZIP64 ���� ������ � CentralDirectory
      FExceptionCount := 0;
      BeforeExceptPosition := 0;
      TotalCount := 0;
      Result := brDone;
      I := 0;
      DeletePackedFile := False;
      OldPathName := '';
      while I < Count do      
      begin
        try

          BeforeExceptPosition := Stream.Position;
          SaveItemToStream(Stream, I);
          Inc(TotalCount);
          Inc(I);

          // � ������ ���� ��� ��������� ������� ������ � ��� ��������
          // �������� acUseNewFilePathAndDel, �� ���������� ������� ����.
          if DeletePackedFile then
          begin
            DeletePackedFile := False;
            NewFilePath := Item[I - 1].FilePath;
            SetFileAttributes(PChar(NewFilePath), FILE_ATTRIBUTE_NORMAL);
            DeleteFile(NewFilePath);
          end;

          // ���� ���� � ����� ��� �������� ������� ��-�� ���������� ����������
          // acUseNewFilePath ��� acUseNewFilePathAndDel,
          // ���������� ������������ ������ ��������
          if OldPathName <> '' then
          begin
            FBuildState := False;
            try
              Item[I - 1].FilePath := OldPathName;
            finally
              OldPathName := '';
              FBuildState := True;
            end;
          end;

        except

          // ���� ������������ ������� �������� ������, ������� �� �����
          on E: EAbort do
          begin
            Result := brAborted;
            Exit;
          end;

          on E: Exception do
          begin
            // ���������� ������� � ������ �� ������ �����
            Stream.Position := BeforeExceptPosition;

            // ����������� ������������, ��� ������ � �����������?         
            ExceptAction := eaSkip;
            NewFilePath := ''; 
            
            NewFileData := TMemoryStream.Create;
            try
            
              if Assigned(FBuidException) then
                FBuidException(Self, E, I, ExceptAction, 
                  NewFilePath, NewFileData);
                  
              // ������������ ����� �������������
              case ExceptAction of

                // ��������� �������
                eaRetry:
                  Continue;

                // ���������� �������
                eaSkip:
                begin
                  // �� �������� ������� ����������� ����������.
                  // �� �� ����� �������������� ��� �����������.
                  FCD[I].ExceptOnWrite := True;
                  // ����� �������� ����� ����������, ��� ���������� ������
                  // ���������� ��������� ������ � �������� ����������
                  Inc(FExceptionCount); 
                  Inc(I);
                  Result := brPartialBuild;                                
                end;

                // ���������� �������� ������
                eaAbort:
                begin
                  Result := brAborted;
                  Exit;                  
                end;

                // ������������ ������ �� ������� �����
                eaUseNewFilePath, eaUseNewFilePathAndDel:
                begin
                  // ���������� ������� ���� � �����,
                  // ��� ������������ ��������������
                  OldPathName := Item[I].FilePath;
                  FBuildState := False;
                  try
                    Item[I].FilePath := NewFilePath;
                  finally
                    FBuildState := True;
                  end;
                  // ���������� ����, ��� ��� ��������� ������,
                  // ���� ������ �������
                  DeletePackedFile := ExceptAction = eaUseNewFilePathAndDel;
                  Continue;
                end;
                
                // ������������ ������ �� ������
                eaUseNewFileData:
                begin
                  FBuildState := False;
                  try
                    Item[I].ChangeDataStream(NewFileData);                    
                  finally
                    FBuildState := True;
                  end;                
                  Continue;
                end;
              end;

            finally
              NewFileData.Free;
            end;                      
          end;
          
        end;
      end;

      // ���� � ����� �� �������� �� ���� �� ���������,
      // �� ���������� ������ ������ �� ������� �������� � ������� � �������
      if TotalCount = 0 then
      begin
        Stream.Size := Stream.Position;
        Result := brFailed;
        Exit;
      end;

      // ������ ������� ������ ������ ��������,
      // ��������� LocalHeader � DataDescryptor
      UpdateLocalHeaders(Stream);

      // ���������� CentralDirectory
      SaveCentralDirectory(Stream);

      // ����� ��������� EndOfCentralDirectory ��� ���� ��� �������������
      // ����������� � ������� ����� ��������� Zip64EOFCentralDirectoryRecord
      // � Zip64EOFCentralDirectoryLocator
      SaveEndOfCentralDirectory(Stream);
    end;
  finally
    FBuildState := False;
  end;
end;

//
//  ��������� ��������� ����� � ��������� ��� � ��������� ����.
// =============================================================================
function TFWZipWriter.BuildZip(const ZipFilePath: string): TBuildZipResult;
var
  ZIP: TFileStream;
begin
  Result := brFailed;
  if Count = 0 then Exit;
  ZIP := TFileStream.Create(ZipFilepath, fmCreate);
  try
    Result := BuildZip(ZIP);
  finally
    ZIP.Free;
  end;
  if Result in [brFailed, brAborted] then
    DeleteFile(ZipFilePath);
end;

//
//  ������� �������� �������� ������������ ������������ ����� � ������
// =============================================================================
function TFWZipWriter.CheckFileNameSlashes(const Value: string): string;
begin
  {
        The name of the file, with optional relative path.
          The path stored should not contain a drive or
          device letter, or a leading slash.  All slashes
          should be forward slashes '/' as opposed to
          backwards slashes '\' for compatibility with Amiga
          and Unix file systems etc.
  }

  Result := StringReplace(Value, '\', '/', [rfReplaceAll]);
end;

//
//  ��������� �������� ������� OnProcess
// =============================================================================
procedure TFWZipWriter.CompressorOnProcess(Sender: TObject);
var
  CurrentProgress, TotalProgress: Byte;
  Cancel: Boolean;
begin
  if Assigned(FOnProgress) then
  begin
    if FCompressedStream.Size = 0 then
      CurrentProgress := 100
    else
      CurrentProgress :=
        Round(FCompressedStream.Position / (FCompressedStream.Size / 100));
    if FTotalSizeCount = 0 then
      TotalProgress := 100
    else
      TotalProgress :=
        Round((FTotalProcessedCount + FCompressedStream.Position) /
          (FTotalSizeCount / 100));
    Cancel := False;
    FOnProgress(Self, Item[FProcessedItemIndex].FileName,
      CurrentProgress, TotalProgress, Cancel);
    if Cancel then Abort;
  end;
end;

//
//  ������� ���������� ���������� ����������� ��������� ������
// =============================================================================
function TFWZipWriter.Count: Integer;
begin
  Result := FItems.Count;
end;

//
//  ����������� ����������� ������
// =============================================================================
constructor TFWZipWriter.Create;
begin
  Create(False, clDefault, '');
end;

//
//  ����������� ����������� ������,
//  � ������� ����� ������� ������� ������,
//  ������������ ��� ���� ��������� �� ���������.
// =============================================================================
constructor TFWZipWriter.Create(CompressionLevel: TCompressionLevel);
begin
  Create(False, CompressionLevel, '');
end;

//
//  ����������� ����������� ������,
//  � ������� ����� �������� ��������� ��������� ��������� ������ �� ��������.
// =============================================================================
constructor TFWZipWriter.Create(UseDescryptors: Boolean;
  CompressionLevel: TCompressionLevel; const DefaultPassword: string);
begin
  inherited Create;
  FDefaultDescryptorState := UseDescryptors;
  FDefaultCompressionLevel := CompressionLevel;
  FDefaultPassword := DefaultPassword;
  FItems := TObjectList.Create;
  FItems.Capacity := 100000;
end;

//
//  ��������� ������� �������� ������ ������
// =============================================================================
procedure TFWZipWriter.DeleteItem(Index: Integer);
begin
  FItems.Delete(Index);
end;

//
//  ����������� ���������� ������
// =============================================================================
destructor TFWZipWriter.Destroy;
begin
  FItems.Free;
  inherited;
end;

//
//  ������� ���������� ������� ����� � ������� TFileTime
// =============================================================================
function TFWZipWriter.GetCurrentFileTime: TFileTime;
var
  SystemTime: TSystemTime;
begin
  DateTimeToSystemTime(Now, SystemTime);
  SystemTimeToFileTime(SystemTime, Result);
  FileTimeToLocalFileTime(Result, Result);
end;

//
//  ���������� �������� Items
// =============================================================================
function TFWZipWriter.GetItem(Index: Integer): TFWZipWriterItem;
begin
  Result := TFWZipWriterItem(FItems[Index]);
end;

//
//  ������� ������������ ����������� ������ ��� ����������
//  ���������� �������� ������
// =============================================================================
function TFWZipWriter.GetVersionToExtract(Index: Integer): Word;
begin
{
          Current minimum feature versions are as defined below:

          1.0 - Default value
          1.1 - File is a volume label
          2.0 - File is a folder (directory)
          2.0 - File is compressed using Deflate compression
          2.0 - File is encrypted using traditional PKWARE encryption
          2.1 - File is compressed using Deflate64(tm)
          2.5 - File is compressed using PKWARE DCL Implode
          2.7 - File is a patch data set
          4.5 - File uses ZIP64 format extensions
          4.6 - File is compressed using BZIP2 compression*
          5.0 - File is encrypted using DES
          5.0 - File is encrypted using 3DES
          5.0 - File is encrypted using original RC2 encryption
          5.0 - File is encrypted using RC4 encryption
          5.1 - File is encrypted using AES encryption
          5.1 - File is encrypted using corrected RC2 encryption**
          5.2 - File is encrypted using corrected RC2-64 encryption**
          6.1 - File is encrypted using non-OAEP key wrapping***
          6.2 - Central directory encryption
}

  // TGSZIPWriter ������������ ��������� ���������� ���������:
  // 1. ������������� ���������� (������ ��� ���������� - 2.0)
  // 2. ������������� ZIP64 ���������� (������ ��� ���������� - 4.5)

  // ��� �����������, ����� �� ��� ������������ ZIP64 ���������� ���������
  // ��������� ���������:
  // ������ ������� �������� ������ ������� � �� �������,
  // ������ �� ������ ����� ������ ��� ������� ��������
  // ���� ����� �� ���� �������� ������� �� �������� MAXDWORD,
  // ��� ���������� ��������� ������ ������� �� �������� MAXWORD,
  // ��� ���������� ��������� ZIP64

  Result := 20;
  if (FCD[Index].UncompressedSize > MAXDWORD) or
    (FCD[Index].CompressedSize > MAXDWORD) or
    (FCD[Index].RelativeOffsetOfLocalHeader > MAXDWORD) or
    (FCD[Index].DiskNumberStart > MAXWORD) then
    Result := 45;
end;

//
//  ��������� �������� ���������� ������ CentralDirectory
// =============================================================================
procedure TFWZipWriter.SaveCentralDirectory(Stream: TStream);
var
  I, UserExDataBlockCount: Integer;
  EmptyNTFS: TNTFSFileTime;
  ExDataHeader: TExDataHeaderAndSize;
  ExDataNTFS: TExDataNTFS;
  ZIP64Data: TMemoryStream;
  TotalExDataStream, ExDataStream: TMemoryStream;
  EmptyExData: Boolean;
  ExDataHeaderTag, ExDataSize: Word;
begin
  ZeroMemory(@EmptyNTFS, SizeOf(TNTFSFileTime));
  ZeroMemory(@ExDataNTFS, SizeOf(TExDataNTFS));
  for I := 0 to Count - 1 do
  begin

    // ���������� �������� ��� ������ ������� ��������� ����������
    if FCD[I].ExceptOnWrite then Continue;

    // ����� ������� ������� �������� CentralDirectory
    // ���������� ����������� ������� � ������������ �������
    // � ������� �� ������
    ZIP64Data := TMemoryStream.Create;
    try
      // ������������� ������ � ZIP64 �������

      {
          The order of the fields in the ZIP64 extended
          information record is fixed, but the fields will
          only appear if the corresponding Local or Central
          directory record field is set to 0xFFFF or 0xFFFFFFFF.
      }

      if FCD[I].UncompressedSize > MAXDWORD then
        ZIP64Data.WriteBuffer(FCD[I].UncompressedSize, 8);
      if FCD[I].CompressedSize > MAXDWORD then
        ZIP64Data.WriteBuffer(FCD[I].CompressedSize, 8);
      if FCD[I].RelativeOffsetOfLocalHeader > MAXDWORD then
        ZIP64Data.WriteBuffer(FCD[I].RelativeOffsetOfLocalHeader, 8);
      if FCD[I].DiskNumberStart > MAXWORD then
        ZIP64Data.WriteBuffer(FCD[I].DiskNumberStart, 4);

      ZeroMemory(@ExDataNTFS, SizeOf(TExDataHeaderAndSize));
      if IsAttributesPresent(FCD[I].Attributes) then
      begin
        // �������������� ������ � NTFS ��������
        FCD[I].Header.ExtraFieldLength := SizeOf(TExDataNTFS);

        //   (NTFS)  0x000a        Short       Tag for this "extra" block type
        ExDataNTFS.HS.Header := SUPPORTED_EXDATA_NTFSTIME;
        {
          In the current implementations, this field has
          a fixed total data size of 32 bytes and is only stored as local
          extra field
        }
        ExDataNTFS.HS.Size := 32;
        // Reserved      Long        for future use
        ExDataNTFS.Reserved := 0;
        // Tag1          Short       NTFS attribute tag value #1
        ExDataNTFS.Tag := 1;
        //Size1      2 bytes    Size of attribute #1, in bytes (24)
        ExDataNTFS.RecordSize := 24;
        ExDataNTFS.Data.Mtime := FCD[I].Attributes.ftLastWriteTime;
        ExDataNTFS.Data.Atime := FCD[I].Attributes.ftLastAccessTime;
        ExDataNTFS.Data.Ctime := FCD[I].Attributes.ftCreationTime;
      end;
      if ZIP64Data.Size > 0 then
        Inc(FCD[I].Header.ExtraFieldLength,
          ZIP64Data.Size + SizeOf(TExDataHeaderAndSize));

      // ����������� ����� ExData �� ������������
      TotalExDataStream := TMemoryStream.Create;
      try
        if Assigned(FSaveExData) then
        begin
          ExDataStream := TMemoryStream.Create;
          try
            EmptyExData := False;
            UserExDataBlockCount := 0;
            while not EmptyExData do
            begin
              ExDataHeaderTag := 0;
              ExDataStream.Clear;
              FSaveExData(Self, I, UserExDataBlockCount,
                ExDataHeaderTag, ExDataStream);
              Inc(UserExDataBlockCount);
              EmptyExData := ExDataStream.Size = 0;
              if not EmptyExData then
              begin
                if ExDataStream.Size > MAXWORD then
                  raise Exception.Create(
                    '������ ������� ����� ����������� ������' +
                    ' �� ����� ��������� 65535 ����.')
                else
                  ExDataSize := ExDataStream.Size;
                if ExDataHeaderTag in
                  [0, SUPPORTED_EXDATA_ZIP64, SUPPORTED_EXDATA_NTFSTIME] then
                  raise Exception.Create(
                    '������ ������������ ����������������� ����' +
                    ' ����� ����������� ������.');
                TotalExDataStream.WriteBuffer(ExDataHeaderTag, 2);
                TotalExDataStream.WriteBuffer(ExDataSize, 2);
                TotalExDataStream.CopyFrom(ExDataStream, 0);
              end;
            end;
          finally
            ExDataStream.Free;
          end;
        end;

        Inc(FCD[I].Header.ExtraFieldLength, TotalExDataStream.Size);

        // ����� ���� ���������
        Stream.WriteBuffer(FCD[I].Header, SizeOf(TCentralDirectoryFileHeader));
        // ����� ������������ ��������
        SaveString(Stream, FCD[I].FileName);

        // � ��� ���������� � ������� ZIP64
        if ZIP64Data.Size > 0 then
        begin
          ExDataHeader.Header := SUPPORTED_EXDATA_ZIP64;
          ExDataHeader.Size := ZIP64Data.Size;
          Stream.WriteBuffer(ExDataHeader, SizeOf(TExDataHeaderAndSize));
          Stream.CopyFrom(ZIP64Data, 0);
        end;
        // ���������� � NTFSTime
        if ExDataNTFS.HS.Header = SUPPORTED_EXDATA_NTFSTIME then
          Stream.WriteBuffer(ExDataNTFS, SizeOf(TExDataNTFS));

        // � ����������� ���������� ���������� �� ������������
        if TotalExDataStream.Size > 0 then
          Stream.CopyFrom(TotalExDataStream, 0);

      finally
         TotalExDataStream.Free;
      end;

      // ����� ���������� � ��������
      SaveString(Stream, FCD[I].FileComment);

    finally
      ZIP64Data.Free;
    end;
  end;
end;

//
//  ��������� �������� ���������� ������ EndOfCentralDirectory
// =============================================================================
procedure TFWZipWriter.SaveEndOfCentralDirectory(Stream: TStream);
var
  oe64cd: TZip64EOFCentralDirectoryRecord;
  locator: TZip64EOFCentralDirectoryLocator;
  eocd: TEndOfCentralDir;
  oe64cdOffset, SizeOfCentralDir: Int64;
begin
  oe64cdOffset := Stream.Position;
  SizeOfCentralDir := oe64cdOffset - FcdfhOffset;
  // �������� �� ������ ���������� ��������� ������ ���������� ����������
  oe64cd.TotalNumber1 := Count - FExceptionCount;
  // ������ ZIP64 ������������ � ������ ���� ���������� ���������  
  // ������ ��������� MAXWORD, ��� �������� �� ������ ����������� ����������
  // ��������� MAXDWORD ��� �� ������ ��������� MAXDWORD
  if (FcdfhOffset > MAXDWORD) or (SizeOfCentralDir > MAXDWORD) or
    (oe64cd.TotalNumber1 > MAXWORD) then
  begin
    // � ������ ������������� ������� ZIP64
    // ���������� �������� �������������� ���������

    // TZip64EOFCentralDirectoryRecord
    oe64cd.Zip64EndOfCentralDirSignature := ZIP64_END_OF_CENTRAL_DIR_SIGNATURE;
    oe64cd.SizeOfZip64EOFCentralDirectoryRecord :=
      SizeOf(TZip64EOFCentralDirectoryRecord);
    oe64cd.VersionMadeBy := CurrentVersionMadeBy;
    oe64cd.VersionNeededToExtract := FVersionToExtract;
    oe64cd.Number1 := 0;
    oe64cd.Number2 := 0;
    oe64cd.TotalNumber2 := oe64cd.TotalNumber1;
    oe64cd.Size := SizeOfCentralDir;
    oe64cd.Offset := FcdfhOffset;
    Stream.WriteBuffer(oe64cd, SizeOf(TZip64EOFCentralDirectoryRecord));

    // TZip64EOFCentralDirectoryLocator
    locator.Signature := ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIGNATURE;
    locator.NumberOfTheDisk := 0;
    locator.RelativeOffset := oe64cdOffset;
    locator.TotalNumberOfDisks := 0;
    Stream.WriteBuffer(locator, SizeOf(TZip64EOFCentralDirectoryLocator));
  end;
  eocd.EndOfCentralDirSignature := END_OF_CENTRAL_DIR_SIGNATURE;
  eocd.NumberOfThisDisk := 0;
  eocd.NumberOfTheDiskWithTheStart := 0;
  if oe64cd.TotalNumber1 > MAXWORD then
    eocd.TotalNumberOfEntriesOnThisDisk := MAXWORD
  else
    eocd.TotalNumberOfEntriesOnThisDisk := oe64cd.TotalNumber1;
  eocd.TotalNumberOfEntries := eocd.TotalNumberOfEntriesOnThisDisk;
  if SizeOfCentralDir > MAXDWORD then
    eocd.SizeOfTheCentralDirectory := MAXDWORD
  else
    eocd.SizeOfTheCentralDirectory := SizeOfCentralDir;
  if FcdfhOffset > MAXDWORD then
    eocd.OffsetOfStartOfCentralDirectory := MAXDWORD
  else
    eocd.OffsetOfStartOfCentralDirectory := FcdfhOffset;
  eocd.ZipfileCommentLength := Length(FComment);
  Stream.WriteBuffer(eocd, SizeOf(TEndOfCentralDir));
  if eocd.ZipfileCommentLength > 0 then
    SaveString(Stream, FComment);
end;

//
//  ��������� �������� ������ � ���������� ���������� �������� ������
// =============================================================================
procedure TFWZipWriter.SaveItemToStream(Stream: TStream; Index: Integer);

  function CopyWithProgress(Src, Dst: TStream;
    Cryptor: TFWZipCryptor): Cardinal;
  var
    Buff: Pointer;
    Size: Integer;
  begin
    Result := $FFFFFFFF;
    GetMem(Buff, MAXWORD);
    try
      Src.Position := 0;
      FCompressedStream := Src;
      while True do
      begin
        Size := Src.Read(Buff^, MAXWORD);
        Result := CRC32Calc(Result, Buff, Size);
        if Size <> 0 then
        begin
          if Cryptor <> nil then
            Cryptor.EncryptBuffer(Buff, Size);
          Dst.WriteBuffer(Buff^, Size);
          CompressorOnProcess(nil);
        end
        else
          Break;
      end;
    finally
      FreeMem(Buff);
    end;
    Result := Result xor $FFFFFFFF;
  end;

var
  CurrentItem: TFWZipWriterItem;
  SystemTyme: TSystemTime;
  FileDate: Cardinal;
  F: TFileStream;
  Compressor: TCompressionStream;
  FileNameOffset, StreamSizeBeforeCompress: Int64;
  Cryptor: TFWZipCryptor;
  ZipItemStream: TFWZipItemStream;
  CRC32Stream: TFWZipCRC32Stream;
  EncryptedHeaderStream: TMemoryStream;
begin
  CurrentItem := Item[Index];

  // �������� �� ������������������
  if (CurrentItem.FilePath = '') and (CurrentItem.Data = nil) then
    raise Exception.Create('������ �������� �����������');  

  FProcessedItemIndex := Index;

  // ��������� ���������� � CentralDirectory
  // ===========================================================================
  FCD[Index].Header.CentralFileHeaderSignature := CENTRAL_FILE_HEADER_SIGNATURE;
  FCD[Index].Header.VersionMadeBy := CurrentVersionMadeBy;
  FCD[Index].Header.VersionNeededToExtract := 0; // �������������� �������

  FCD[Index].Header.GeneralPurposeBitFlag := 0;
  if CurrentItem.Password <> '' then
    FCD[Index].Header.GeneralPurposeBitFlag :=
      FCD[Index].Header.GeneralPurposeBitFlag or PBF_CRYPTED;

  case CurrentItem.CompressionLevel of
    clNone:; // ������ ����� ���������� �� ��������������, ����� ������ �� Store
    clFastest:
      FCD[Index].Header.GeneralPurposeBitFlag :=
        FCD[Index].Header.GeneralPurposeBitFlag or PBF_COMPRESS_SUPERFAST;
    clDefault:
      FCD[Index].Header.GeneralPurposeBitFlag :=
        FCD[Index].Header.GeneralPurposeBitFlag or PBF_COMPRESS_NORMAL;
    clMax:
      FCD[Index].Header.GeneralPurposeBitFlag :=
        FCD[Index].Header.GeneralPurposeBitFlag or PBF_COMPRESS_MAXIMUM;
  end;
  if CurrentItem.NeedDescriptor then
      FCD[Index].Header.GeneralPurposeBitFlag :=
        FCD[Index].Header.GeneralPurposeBitFlag or PBF_DESCRIPTOR;

  if CurrentItem.CompressionLevel = clNone then
    FCD[Index].Header.CompressionMethod := Z_NO_COMPRESSION
  else
    FCD[Index].Header.CompressionMethod := Z_DEFLATED;

  if not CurrentItem.NeedDescriptor then
    if CurrentItem.Password <> '' then
    begin
      // � ������ ���� ����������� ��������� � �������� ���������� ��������
      // �� ���������� ���������� ��� ����������� ����� �����
      // ���������� ��������� ������������� ����� ����������
      if CurrentItem.Data = nil then
        FCD[Index].Header.Crc32 := FileCRC32(CurrentItem.FilePath)
      else
        FCD[Index].Header.Crc32 := 
          CRC32Calc(CurrentItem.Data.Memory, CurrentItem.Data.Size);
    end;
  FCD[Index].UncompressedSize := CurrentItem.Size;


  FileTimeToSystemTime(CurrentItem.Attributes.ftLastWriteTime, SystemTyme);
  FileDate := DateTimeToFileDate(SystemTimeToDateTime(SystemTyme));
  FCD[Index].Header.LastModFileTimeTime := FileDate and $FFFF;
  FCD[Index].Header.LastModFileTimeDate := FileDate shr 16;

  FCD[Index].Filename := CurrentItem.FileName;
  FCD[Index].Header.FilenameLength := Length(FCD[Index].Filename);
  FCD[Index].Header.ExtraFieldLength := 0;
  FCD[Index].FileComment := CurrentItem.Comment;
  FCD[Index].Header.FileCommentLength := Length(FCD[Index].FileComment);
  FCD[Index].Header.DiskNumberStart := 0;
  FCD[Index].Header.InternalFileAttributes := 0;
  FCD[Index].Header.ExternalFileAttributes := 
    CurrentItem.Attributes.dwFileAttributes;
  FCD[Index].Attributes := CurrentItem.Attributes;
  FCD[Index].RelativeOffsetOfLocalHeader := Stream.Position;

  // �������� ������ � �������������� ����
  // ===========================================================================

  // ���������� ������ �� �������� ���������� ����� ������ ��� �����
  FileNameOffset := Stream.Position + SizeOf(TLocalFileHeader);

  // ������������ ������ �������������� ����� ���
  // LocalFileHeader � ��� �����
  StreamSizeBeforeCompress := FileNameOffset + Length(FCD[Index].Filename);

  // �������� ���� ������ ��� LocalFileHeader � ��� �����
  Stream.Size := StreamSizeBeforeCompress;
  Stream.Position := Stream.Size;

  Cryptor := nil;
  try
    EncryptedHeaderStream := TMemoryStream.Create;
    try
      if CurrentItem.Password <> '' then
      begin
        Cryptor := TFWZipCryptor.Create(AnsiString(CurrentItem.Password));
        Cryptor.GenerateEncryptionHeader(EncryptedHeaderStream,
          CurrentItem.NeedDescriptor,
          FCD[Index].Header.Crc32,
          FCD[Index].Header.LastModFileTimeTime +
          FCD[Index].Header.LastModFileTimeDate shl 16);
        // ����������� ����� ��� EncryptedHeaderStream
        Stream.Size := StreamSizeBeforeCompress + EncryptedHeaderSize;
        Stream.Position := Stream.Size;
      end;

      // ����� ��� ������ ����
      case FCD[Index].Header.CompressionMethod of
        Z_NO_COMPRESSION:
        begin
          if CurrentItem.Data <> nil then
            FCD[Index].Header.Crc32 :=
              CopyWithProgress(CurrentItem.Data, Stream, Cryptor)
          else
          begin
            F := TFileStream.Create(CurrentItem.FilePath,
              fmOpenRead or fmShareDenyWrite);
            try
              FCD[Index].Header.Crc32 :=
                CopyWithProgress(F, Stream, Cryptor)
            finally
              F.Free;
            end;
          end;
          // �������� ������ ������ ������
          // � ������ ���� �������������� ���������� � ������� ����� �����
          // ����� 12-�� ������� ��������� ������������� ����� �����������
          FCD[Index].CompressedSize := Stream.Size - StreamSizeBeforeCompress;
        end;
        Z_DEFLATED:
        begin
          // ������� �������� �� ��� ����� �����,
          // ����� ������� �� ������ �������� ��� ��������� ZLib
          Stream.Position := Stream.Position - 2;
          if CurrentItem.Data <> nil then
          begin
            // ��������� ������ �� ����� � ������� ��� �������� ���������
            FCompressedStream := CurrentItem.Data;
            ZipItemStream := TFWZipItemStream.Create(Stream, Cryptor, nil,
              0, CurrentItem.Size);
            try
              Compressor := TCompressionStream.Create(
                CurrentItem.CompressionLevel, ZipItemStream);
              try
                Compressor.OnProgress := CompressorOnProcess;
                CRC32Stream := TFWZipCRC32Stream.Create(CurrentItem.Data);
                try
                  Compressor.CopyFrom(CRC32Stream, 0);
                  FCD[Index].Header.Crc32 := CRC32Stream.CRC32;
                finally
                  CRC32Stream.Free;
                end;
                CompressorOnProcess(Compressor);
              finally
                Compressor.Free;
              end;
            finally
              ZipItemStream.Free;
            end;
          end
          else
          begin
            // TFWZipItemStream ��������� ��� ��������� ����� ��������������
            // ������� � TCompressionStream.
            // ��� ������ ����������� ��� ���������� ����� ����� ������
            ZipItemStream := TFWZipItemStream.Create(Stream, Cryptor, nil,
              0, CurrentItem.Size);
            try
              Compressor := TCompressionStream.Create(
                CurrentItem.CompressionLevel, ZipItemStream);
              try
                F := TFileStream.Create(CurrentItem.FilePath,
                  fmOpenRead or fmShareDenyWrite);
                try
                  // ��������� ������ �� ����� � ������� ��� �������� ���������
                  FCompressedStream := F;
                  F.Position := 0;
                  Compressor.OnProgress := CompressorOnProcess;
                  // TFWZipCRC32Stream ��������� ��� ��������� �����
                  // ���������������� ������� � TCompressionStream,
                  // � ������� ���������� ������ ������.
                  // ��� ������ ��������� ��� ���������� ����� ����
                  // ����� ������ � ���������� �� ����������� �����
                  // �� ���� ��� ��� ����� �����
                  CRC32Stream := TFWZipCRC32Stream.Create(F);
                  try
                    Compressor.CopyFrom(CRC32Stream, 0);
                    FCD[Index].Header.Crc32 := CRC32Stream.CRC32;
                  finally
                    CRC32Stream.Free;
                  end;
                  CompressorOnProcess(Compressor);
                finally
                  F.Free;
                end;
              finally
                Compressor.Free;
              end;
            finally
              ZipItemStream.Free;
            end;
          end;
          // �������� ������ ������ ������
          // � ������ ���� �������������� ���������� � ������� ����� �����
          // ����� 12-�� ������� ��������� ������������� ����� �����������
          FCD[Index].CompressedSize := Stream.Size - StreamSizeBeforeCompress;
        end;
      end;
      
      // ���� ���� ����������,
      // ���������� ��������� ������������� ����� �����������
      if EncryptedHeaderStream.Size > 0 then
      begin
        Stream.Position := StreamSizeBeforeCompress;
        Stream.CopyFrom(EncryptedHeaderStream, 0);
      end;
    finally
      EncryptedHeaderStream.Free;
    end;

  finally
    Cryptor.Free;
  end;

  Inc(FTotalProcessedCount, CurrentItem.Size);

  // ����� ��� �����
  Stream.Position := FileNameOffset;
  SaveString(Stream, FCD[Index].Filename);

  // ����������� ����� ��� ����������
  if CurrentItem.NeedDescriptor then
    Stream.Size := Stream.Size + SizeOf(TDataDescriptor);

  Stream.Position := Stream.Size;
end;

//
//  ��������� �������� �������������� ���������� ������  � OEM � �� ����������
// =============================================================================
procedure TFWZipWriter.SaveString(Stream: TStream; const Value: string);
var
  OemString: AnsiString;
begin
  if Value <> '' then
  begin
    OemString := AnsiString(Value);
    UniqueString(OemString);
    AnsiToOem(PAnsiChar(OemString), PAnsiChar(OemString));
    Stream.WriteBuffer(OemString[1], Length(OemString));
  end;
end;

//
//  ��������� ��������� ������ LocalFileHeader
// =============================================================================
procedure TFWZipWriter.UpdateLocalHeaders(Stream: TStream);
var
  I: Integer;
  lfh: TLocalFileHeader;
  dd: TDataDescriptor;
  UseDescriptor: Boolean;
begin
  FcdfhOffset := Stream.Position;  
  for I := 0 to Count - 1 do
  begin

    // ���������� �������� ��� ������ ������� ��������� ����������
    if FCD[I].ExceptOnWrite then Continue;

    // ���� �� ����� ��� ������ �������������� ��� LocalFileHeader
    // � DataDescriptor (���� ���������)
    lfh.LocalFileHeaderSignature := LOCAL_FILE_HEADER_SIGNATURE;

    // ������������ ������ ����������� ��� ���������� �������� ������
    lfh.VersionNeededToExtract := GetVersionToExtract(I);
    lfh.GeneralPurposeBitFlag := FCD[I].Header.GeneralPurposeBitFlag;
    UseDescriptor := lfh.GeneralPurposeBitFlag and PBF_DESCRIPTOR <> 0;
    lfh.CompressionMethod := FCD[I].Header.CompressionMethod;
    lfh.LastModFileTimeTime := FCD[I].Header.LastModFileTimeTime;
    lfh.LastModFileTimeDate := FCD[I].Header.LastModFileTimeDate;
    if UseDescriptor then
    begin
      dd.DescriptorSignature := DATA_DESCRIPTOR_SIGNATURE;
      // ���� � ��������� ������� ��� ��� ������������� ������������ 
      // ���� Crc32, CompressedSize � UncompressedSize ������ ���� �����������
      // � ����, �� ����������� ����������� ����� �� ������,
      // ������� ���������� �� :)
      lfh.Crc32 := FCD[I].Header.Crc32;
      dd.Crc32 := lfh.Crc32;
      if FCD[I].CompressedSize > MAXDWORD then
        dd.CompressedSize := MAXDWORD
      else
        dd.CompressedSize := FCD[I].CompressedSize;
      lfh.CompressedSize := dd.CompressedSize;
      if FCD[I].UncompressedSize > MAXDWORD then
        dd.UncompressedSize := MAXDWORD
      else
        dd.UncompressedSize := FCD[I].UncompressedSize;
      lfh.UncompressedSize := dd.UncompressedSize;
    end
    else
    begin
      lfh.Crc32 := FCD[I].Header.Crc32;
      if FCD[I].CompressedSize > MAXDWORD then
        lfh.CompressedSize := MAXDWORD
      else
        lfh.CompressedSize := FCD[I].CompressedSize;
      if FCD[I].UncompressedSize > MAXDWORD then
        lfh.UncompressedSize := MAXDWORD
      else
        lfh.UncompressedSize := FCD[I].UncompressedSize;
    end;
    lfh.FilenameLength := Length(FCD[I].FileName);
    // ���� � ����������� ����������� �� ����� -
    // ��� ������ ����� �������� ������ � CentralDirectoryFileHeader
    lfh.ExtraFieldLength := 0;

    Stream.Position := FCD[I].RelativeOffsetOfLocalHeader;
    Stream.WriteBuffer(lfh, SizeOf(TLocalFileHeader));
    if UseDescriptor then
    begin
      // ���������� ������� ����� ������� ����� ������
      Stream.Position := Stream.Position + lfh.FilenameLength +
        FCD[I].CompressedSize;
      Stream.WriteBuffer(dd, SizeOf(TDataDescriptor));
    end;

    // ��������� ���������� � ������� CentralDirectoryFileHeader
    FCD[I].Header.VersionNeededToExtract := FVersionToExtract;
    if UseDescriptor then
      FCD[I].Header.CompressedSize := dd.CompressedSize
    else
      FCD[I].Header.CompressedSize := lfh.CompressedSize;
    if UseDescriptor then
      FCD[I].Header.UncompressedSize := dd.UncompressedSize
    else
      FCD[I].Header.UncompressedSize := lfh.UncompressedSize;
    if FCD[I].RelativeOffsetOfLocalHeader > MAXDWORD then
      FCD[I].Header.RelativeOffsetOfLocalHeader := MAXDWORD
    else
      FCD[I].Header.RelativeOffsetOfLocalHeader :=
        FCD[I].RelativeOffsetOfLocalHeader;
  end;
  Stream.Position := FcdfhOffset;
end;

end.
