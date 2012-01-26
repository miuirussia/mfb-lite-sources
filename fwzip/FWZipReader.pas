////////////////////////////////////////////////////////////////////////////////
//
//  ****************************************************************************
//  * Project   : FWZip
//  * Unit Name : FWZipReader
//  * Purpose   : Набор классов для распаковки ZIP архива
//  * Author    : Александр (Rouse_) Багель
//  * Copyright : © Fangorn Wizards Lab 1998 - 2011.
//  * Version   : 1.0.3
//  * Home Page : http://rouse.drkb.ru
//  ****************************************************************************
//
//  Используемые источники:
//  ftp://ftp.info-zip.org/pub/infozip/doc/appnote-iz-latest.zip
//  http://zlib.net/zlib-1.2.5.tar.gz
//

unit FWZipReader;

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
  TFWZipReader = class;

  TExtractResult = (erError, erDone, erNeedPassword, erWrongCRC32, erSkiped);

  TFWZipReaderItem = class
  private
    FOwner: TFWZipReader;
    FFileHeader: TCentralDirectoryFileHeaderEx;
    FIsFolder: Boolean;
    FOnProgress: TZipExtractItemEvent;
    FTotalExtracted, FExtractStreamStartSize: Int64;
    FExtractStream: TStream;
    FItemIndex, FTag: Integer;
    FDuplicate: TZipDuplicateEvent;
    function GetString(const Index: Integer): string;
  protected
    procedure DecompressorOnProcess(Sender: TObject);
    procedure LoadExData;
    procedure LoadStringValue(var Value: string; nSize: Cardinal);
    procedure LoadLocalFileHeader;
    constructor InitFromStream(Owner: TFWZipReader;
      Index: Integer; Value: TStream);
  public
    function Extract(Path: string; const Password: string): TExtractResult;
    function ExtractToStream(Value: TStream; const Password: string;
      CheckCRC32: Boolean = True): TExtractResult;
    property Attributes: TWin32FileAttributeData read FFileHeader.Attributes;
    property Comment: string index 0 read GetString;
    property IsFolder: Boolean read FIsFolder;
    property FileName: string index 1 read GetString;
    property VersionMadeBy: Word read FFileHeader.Header.VersionMadeBy;
    property VersionNeededToExtract: Word read
      FFileHeader.Header.VersionNeededToExtract;
    property CompressionMethod: Word read FFileHeader.Header.CompressionMethod;
    property LastModFileTime: Word read FFileHeader.Header.LastModFileTimeTime;
    property LastModFileDate: Word read FFileHeader.Header.LastModFileTimeDate;
    property Crc32: Cardinal read FFileHeader.Header.Crc32;
    property CompressedSize: Int64 read FFileHeader.CompressedSize;
    property Tag: Integer read FTag write FTag;
    property UncompressedSize: Int64 read FFileHeader.UncompressedSize;
    property OnProgress: TZipExtractItemEvent
      read FOnProgress write FOnProgress;
    property OnDuplicate: TZipDuplicateEvent read FDuplicate write FDuplicate;
  end;

  TFWZipReader = class
  private
    FZIPStream, FFileStream: TStream;
    FLocalFiles: TObjectList;
    FZip64EOFCentralDirectoryRecord: TZip64EOFCentralDirectoryRecord;
    FZip64EOFCentralDirectoryLocator: TZip64EOFCentralDirectoryLocator;
    FEndOfCentralDir: TEndOfCentralDir;
    FEndOfCentralDirComment: AnsiString;
    FOnProgress: TZipProgressEvent;
    FOnNeedPwd: TZipNeedPasswordEvent;
    FTotalSizeCount, FTotalProcessedCount: Int64;
    FPasswordList: TStringList;
    FOnLoadExData: TZipLoadExDataEvent;
    FException: TZipExtractExceptionEvent;
    FDuplicate: TZipDuplicateEvent;
    function GetItem(Index: Integer): TFWZipReaderItem;
  protected
    property ZIPStream: TStream read FZIPStream;
  protected
    function Zip64Present: Boolean;
    function SizeOfCentralDirectory: Int64;
    function TotalEntryesCount: Integer;
    procedure LoadStringValue(var Value: AnsiString; nSize: Cardinal);
    procedure LoadEndOfCentralDirectory;
    procedure LoadZIP64Locator;
    procedure LoadZip64EOFCentralDirectoryRecord;
    procedure LoadCentralDirectoryFileHeader;
  protected
    procedure DoProgress(Sender: TObject;
      const FileName: string; Extracted, TotalSize: Int64);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function GetElementIndex(const FileName: string): Integer;
    procedure LoadFromFile(const Value: string);
    procedure LoadFromStream(Value: TStream);
    procedure ExtractAll(Path: string);
    function Count: Integer;
    property Item[Index: Integer]: TFWZipReaderItem read GetItem; default;
    property Comment: AnsiString read FEndOfCentralDirComment;
    property PasswordList: TStringList read FPasswordList;
    property OnProgress: TZipProgressEvent read FOnProgress write FOnProgress;
    property OnPassword: TZipNeedPasswordEvent
      read FOnNeedPwd write FOnNeedPwd;
    property OnLoadExData: TZipLoadExDataEvent
      read FOnLoadExData write FOnLoadExData;
    property OnException: TZipExtractExceptionEvent
      read FException write FException;
    property OnDuplicate: TZipDuplicateEvent read FDuplicate write FDuplicate;
  end;

  EWrongPasswordException = class(Exception);

implementation

{ TFWZipReaderItem }

//
//  Процедура вызывает внешнее событие OnProcess
// =============================================================================
procedure TFWZipReaderItem.DecompressorOnProcess(Sender: TObject);
begin
  if Assigned(FOnProgress) then
    if Sender = nil then
      FOnProgress(Self, FileName, FTotalExtracted, UncompressedSize)
    else
    begin
      FTotalExtracted := FExtractStream.Size - FExtractStreamStartSize;
      if FTotalExtracted > 0 then
        FOnProgress(Self, FileName, FTotalExtracted, UncompressedSize);
    end;
end;

//
//  Функция распаковывает текущий элемент архва в указанный файл
// =============================================================================
function TFWZipReaderItem.Extract(Path: string; const Password: string): TExtractResult;
var
  UnpackedFile: TFileStream;
  FullPath: string;
  hFile: THandle;
  FileDate: Integer;
  DuplicateAction: TDuplicateAction;
begin
  Result := erDone;

  // Правка пустого и относительного пути
  Path := PathCanonicalize(Path);
  if Path = '' then
    Path := GetCurrentDir;

  FullPath := StringReplace(
    IncludeTrailingPathDelimiter(Path) + FFileHeader.FileName,
    '/', '\', [rfReplaceAll]);

  if Length(FullPath) > MAX_PATH then
    raise Exception.CreateFmt(
      'Элемент архива "%s" не может быть распакован.' + sLineBreak +
      'Общая длина пути и имени файла не должна превышать 260 символов',
      [FFileHeader.FileName]);
  if IsFolder then
  begin
    ForceDirectories(FullPath);
    Exit;
  end;
  ForceDirectories(ExtractFilePath(FullPath));
  try

    // проверка на существование файла
    if FileExists(FullPath) then
    begin
      if Assigned(FDuplicate) then
      begin
        // если файл уже существует, узнаем - как жить дальше с этим ;)
        DuplicateAction := daSkip;
        FDuplicate(Self, FullPath, DuplicateAction);

        case DuplicateAction of

          // пропустить файл
          daSkip:
          begin
            Result := erSkiped;
            Exit;
          end;

          // перезаписать
          daOverwrite:
            SetFileAttributes(PChar(FullPath), FILE_ATTRIBUTE_NORMAL);

          // распаковать с другим именем
          daUseNewFilePath:
            // если программист указал новый пусть к файлу,
            // то о существовании директории он должен позаботиться сам
            if not DirectoryExists(ExtractFilePath(FullPath)) then
            begin
              Result := erSkiped;
              Exit;
            end;

          // прервать распаковку
          daAbort:
            Abort;

        end;
      end
      else
      begin
        Result := erSkiped;
        Exit;
      end
    end;

    UnpackedFile := TFileStream.Create(FullPath, fmCreate);
    try
      Result := ExtractToStream(UnpackedFile, Password);
    finally
      UnpackedFile.Free;
    end;
    if Result <> erDone then
    begin
      DeleteFile(FullPath);
      Exit;
    end;
    if IsAttributesPresent(FFileHeader.Attributes) then
    begin
      hFile := FileOpen(FullPath, fmOpenWrite);
      try
        SetFileTime(hFile,
          @FFileHeader.Attributes.ftCreationTime,
          @FFileHeader.Attributes.ftLastAccessTime,
          @FFileHeader.Attributes.ftLastWriteTime);
      finally
        FileClose(hFile);
      end;
      SetFileAttributes(PChar(FullPath),
        FFileHeader.Attributes.dwFileAttributes);
    end
    else
    begin
      FileDate :=
        FFileHeader.Header.LastModFileTimeTime +
        FFileHeader.Header.LastModFileTimeDate shl 16;
      FileSetDate(FullPath, FileDate);
    end;
  except
    DeleteFile(FullPath);
    raise;
  end;
end;

//
//  Функция распаковывает текущий элемент архва в стрим
// =============================================================================
function TFWZipReaderItem.ExtractToStream(Value: TStream;
  const Password: string; CheckCRC32: Boolean): TExtractResult;

  function CopyWithProgress(Src, Dst: TStream; Count: Int64;
    Decryptor: TFWZipDecryptor): Cardinal;
  var
    Buff: Pointer;
    Size: Integer;
  begin
    Result := $FFFFFFFF;
    GetMem(Buff, MAXWORD);
    try
      FTotalExtracted := 0;
      Size := MAXWORD;
      while Size = MAXWORD do
      begin
        if Count - FTotalExtracted < MAXWORD then
          Size := Count - FTotalExtracted;
        Src.ReadBuffer(Buff^, Size);
        if Decryptor <> nil then
          Decryptor.DecryptBuffer(Buff, Size);
        Result := CRC32Calc(Result, Buff, Size);
        Dst.WriteBuffer(Buff^, Size);
        Inc(FTotalExtracted, Size);
        DecompressorOnProcess(nil);
      end;
    finally
      FreeMem(Buff);
    end;
    Result := Result xor $FFFFFFFF;
  end;

const
  CompressionMetods: array [0..12] of string = (
    'Store',
    'Shrunk',
    'Reduced1',
    'Reduced2',
    'Reduced3',
    'Reduced4',
    'Imploded',
    'Tokenizing compression algorithm',
    'Deflate',
    'Deflate64',
    'PKWARE Data Compression Library Imploding',
    'PKWARE',
    'BZIP2'
  );
var
  Decompressor: TDecompressionStream;
  ZipItemStream: TFWZipItemStream;
  Decryptor: TFWZipDecryptor;
  RealCompressedSize: Int64;
  CurrItemCRC32: Cardinal;
  CRC32Stream: TFWZipCRC32Stream;
begin
  Result := erError;
  CurrItemCRC32 := 0;
  Decryptor := nil;
  try
    if IsFolder then Exit;

    // Данные для распаковки находятся сразу за LocalFileHeader.
    // Для получения оффсета на начало данных необходимо распарсить
    // данную структуру включая блоки с дополнительной информацией.
    if FFileHeader.DataOffset = 0 then
      LoadLocalFileHeader;

    FOwner.FZIPStream.Position := FFileHeader.DataOffset;
    RealCompressedSize := FFileHeader.CompressedSize;

    // Если файл зашифрован, необходимо инициализировать ключ для распаковки
    if FFileHeader.Header.GeneralPurposeBitFlag and PBF_CRYPTED <> 0 then
    begin

      if FFileHeader.Header.GeneralPurposeBitFlag and
        PBF_STRONG_CRYPT <> 0 then
        raise Exception.Create(
          'Ошибка извлечения данных. Не поддерживаемый режим шифрования');

      if Password = '' then
      begin
        // пароль не может быть пустым
        Result := erNeedPassword;
        Exit;
      end;
      Decryptor := TFWZipDecryptor.Create(AnsiString(Password));
      if not Decryptor.LoadEncryptionHeader(FOwner.FZIPStream,
        FFileHeader.Header.GeneralPurposeBitFlag and PBF_DESCRIPTOR <> 0,
        FFileHeader.Header.Crc32,
        FFileHeader.Header.LastModFileTimeTime +
        FFileHeader.Header.LastModFileTimeDate shl 16) then
      begin
        // ошика инициализации ключа
        Result := erNeedPassword;
        Exit;
      end
      else
        // если ключ инициализирован успешно - вычитаем из сжатого размера
        // размер заголовка инициализации ключа
        Dec(RealCompressedSize, EncryptedHeaderSize);
    end;

    case FFileHeader.Header.CompressionMethod of
      Z_NO_COMPRESSION:
      begin
        CurrItemCRC32 :=
          CopyWithProgress(FOwner.FZIPStream, Value,
            UncompressedSize, Decryptor);
        // Rouse_ 11.03.2011
        // А выставить результат то и забыли.
        // Cпасибо Ромкину за обнаружение косяка
        Result := erDone;
      end;
      Z_DEFLATED:
      begin
        // TFWZipItemStream выступает как посредник между FOwner.FZIPStream
        // и TDecompressionStream. Его задача добавить в передаваемый
        // буффер данных отсутствующий ZLib заголовок и расшифровать
        // данные при необходимости
        ZipItemStream := TFWZipItemStream.Create(FOwner.FZIPStream,
          nil, Decryptor,
          FFileHeader.Header.GeneralPurposeBitFlag and 6,
          RealCompressedSize);
        try
          Decompressor := TDecompressionStream.Create(ZipItemStream);
          try
            Decompressor.OnProgress := DecompressorOnProcess;
            FExtractStreamStartSize := Value.Size;
            FExtractStream := Value;
            // TFWZipCRC32Stream выступает как посредник между
            // TDecompressionStream и результирующим стримом,
            // в который происходит распаковка данных.
            // Его задача отследить все распакованные блоки данных
            // и рассчитать их контрольную сумму
            CRC32Stream := TFWZipCRC32Stream.Create(Value);
            try
              try
                CRC32Stream.CopyFrom(Decompressor, UncompressedSize);
              except
                // Rouse_ 04.04.2010
                // Ранее это исключенияе было EDecompressionError
                // Поэтому привяжемся к базовому исключению EZLibError
                // on E: EZDecompressionError do
                on E: EZLibError do
                begin
                  if FFileHeader.Header.GeneralPurposeBitFlag and
                    PBF_CRYPTED <> 0 then
                  begin
                    // Ошибка может подняться из-за того что инициализация
                    // криптозаголовка прошла успешно, но пароль был указан не верный
                    // Такое может произойти, т.к. количество коллизий
                    // при проверке заголовка очень велико
                    Result := erError;
                    Exit;
                  end
                  else
                    // Rouse_ 09.03.2011
                    // забыл поднять исключение :)
                    raise E;
                end;
              end;
              CurrItemCRC32 := CRC32Stream.CRC32;
            finally
              CRC32Stream.Free;
            end;
            DecompressorOnProcess(Decompressor);
            Result := erDone;
          finally
            Decompressor.Free;
          end;
        finally
          ZipItemStream.Free;
        end;
      end;
      1..7, 9..12:
        raise Exception.CreateFmt(
          'Не поддерживаемый алгоритм декомпрессии "%s"',
          [CompressionMetods[CompressionMethod]]);
    else
      raise Exception.CreateFmt(
        'Не поддерживаемый алгоритм декомпрессии (%d)',
        [FFileHeader.Header.CompressionMethod]);
    end;
    if CurrItemCRC32 <> Crc32 then
      if CheckCRC32 then
        raise Exception.Create(
          'Ошибка извлечения данных. Неверная контрольная сумма.')
      else
        Result := erWrongCRC32;
  finally
    Decryptor.Free;
  end;
end;

//
// =============================================================================
function TFWZipReaderItem.GetString(const Index: Integer): string;
begin
  case Index of
    0: Result := FFileHeader.FileComment;
    1: Result := FFileHeader.FileName;
  end;
end;

//
//  Конструктор элемента архива.
//  Инициализация класса происходит на основе данных из архива
// =============================================================================
constructor TFWZipReaderItem.InitFromStream(Owner: TFWZipReader;
  Index: Integer; Value: TStream);
begin
  inherited Create;

  FOwner := Owner;
  FItemIndex := Index;
  ZeroMemory(@FFileHeader, SizeOf(TCentralDirectoryFileHeaderEx));
  Owner.ZIPStream.ReadBuffer(FFileHeader.Header,
    SizeOf(TCentralDirectoryFileHeader));

  if FFileHeader.Header.CentralFileHeaderSignature <>
    CENTRAL_FILE_HEADER_SIGNATURE then
    raise Exception.Create(
      'Ошибка чтения структуры TCentralDirectoryFileHeader');

  FIsFolder := FFileHeader.Header.ExternalFileAttributes and faDirectory <> 0;

  LoadStringValue(FFileHeader.FileName, FFileHeader.Header.FilenameLength);

  // Следующие 4 параметра могут быть выставлены в -1 из-за переполнения
  // и их реальные значения будут содержаться в блоке расширенных данных.
  // Запоминаем их текущие значения.
  // В случае если какой-либо из параметров выставлен в -1,
  // его значение поменяется при вызове процедуры LoadExData.
  FFileHeader.UncompressedSize := FFileHeader.Header.UncompressedSize;
  FFileHeader.CompressedSize := FFileHeader.Header.CompressedSize;
  FFileHeader.RelativeOffsetOfLocalHeader :=
    FFileHeader.Header.RelativeOffsetOfLocalHeader;
  FFileHeader.DiskNumberStart := FFileHeader.Header.DiskNumberStart;

  LoadExData;

  LoadStringValue(FFileHeader.FileComment,
    FFileHeader.Header.FileCommentLength);

  // часть информации дублируется в расширенном заголовке
  // необходимо ее заполнить
  FFileHeader.Attributes.dwFileAttributes :=
    FFileHeader.Header.ExternalFileAttributes;
  FFileHeader.Attributes.nFileSizeHigh :=
    Cardinal(FFileHeader.UncompressedSize shr 32);
  FFileHeader.Attributes.nFileSizeLow :=
    FFileHeader.UncompressedSize and MAXDWORD;
end;

//
//  Процедура зачитывает дополнительные данные о элементе
// =============================================================================
procedure TFWZipReaderItem.LoadExData;
var
  Buff, EOFBuff: Pointer;
  BuffCount: Integer;
  HeaderID, BlockSize: Word;

  function GetOffset(Value: Integer): Pointer;
  begin
    Result := Pointer(Integer(EOFBuff) - Value);
  end;

var
  ExDataStream: TMemoryStream;
begin
  if FFileHeader.Header.ExtraFieldLength = 0 then Exit;
  GetMem(Buff, FFileHeader.Header.ExtraFieldLength);
  try
    BuffCount := FFileHeader.Header.ExtraFieldLength;
    FOwner.ZIPStream.ReadBuffer(Buff^, BuffCount);
    EOFBuff := Pointer(Integer(Buff) + BuffCount);
    while BuffCount > 0 do
    begin
      HeaderID := PWord(GetOffset(BuffCount))^;
      Dec(BuffCount, 2);
      BlockSize := PWord(GetOffset(BuffCount))^;
      Dec(BuffCount, 2);
      case HeaderID of
        SUPPORTED_EXDATA_ZIP64:
        begin

          {
         -ZIP64 Extended Information Extra Field (0x0001):
          ===============================================

          The following is the layout of the ZIP64 extended
          information "extra" block. If one of the size or
          offset fields in the Local or Central directory
          record is too small to hold the required data,
          a ZIP64 extended information record is created.
          The order of the fields in the ZIP64 extended
          information record is fixed, but the fields will
          only appear if the corresponding Local or Central
          directory record field is set to 0xFFFF or 0xFFFFFFFF.

          Note: all fields stored in Intel low-byte/high-byte order.

          Value      Size       Description
          -----      ----       -----------
  (ZIP64) 0x0001     2 bytes    Tag for this "extra" block type
          Size       2 bytes    Size of this "extra" block
          Original
          Size       8 bytes    Original uncompressed file size
          Compressed
          Size       8 bytes    Size of compressed data
          Relative Header
          Offset     8 bytes    Offset of local header record
          Disk Start
          Number     4 bytes    Number of the disk on which
                                this file starts

          This entry in the Local header must include BOTH original
          and compressed file sizes.
          }

          if FFileHeader.UncompressedSize = MAXDWORD then
          begin
            if BuffCount < 8 then Break;
            FFileHeader.UncompressedSize := PInt64(GetOffset(BuffCount))^;
            Dec(BuffCount, 8);
            Dec(BlockSize, 8);
          end;
          if FFileHeader.CompressedSize = MAXDWORD then
          begin
            if BuffCount < 8 then Break;
            FFileHeader.CompressedSize := PInt64(GetOffset(BuffCount))^;
            Dec(BuffCount, 8);
            Dec(BlockSize, 8);
          end;
          if FFileHeader.RelativeOffsetOfLocalHeader = MAXDWORD then
          begin
            if BuffCount < 8 then Break;
            FFileHeader.RelativeOffsetOfLocalHeader := PInt64(GetOffset(BuffCount))^;
            Dec(BuffCount, 8);
            Dec(BlockSize, 8);
          end;
          if FFileHeader.DiskNumberStart = MAXWORD then
          begin
            if BuffCount < 4 then Break;
            FFileHeader.DiskNumberStart := PCardinal(GetOffset(BuffCount))^;
            Dec(BuffCount, 4);
            Dec(BlockSize, 4);
          end;
          Dec(BuffCount, BlockSize);
        end;

        SUPPORTED_EXDATA_NTFSTIME:
        begin

          {
         -PKWARE Win95/WinNT Extra Field (0x000a):
          =======================================

          The following description covers PKWARE's "NTFS" attributes
          "extra" block, introduced with the release of PKZIP 2.50 for
          Windows. (Last Revision 20001118)

          (Note: At this time the Mtime, Atime and Ctime values may
          be used on any WIN32 system.)
         [Info-ZIP note: In the current implementations, this field has
          a fixed total data size of 32 bytes and is only stored as local
          extra field.]

          Value         Size        Description
          -----         ----        -----------
  (NTFS)  0x000a        Short       Tag for this "extra" block type
          TSize         Short       Total Data Size for this block
          Reserved      Long        for future use
          Tag1          Short       NTFS attribute tag value #1
          Size1         Short       Size of attribute #1, in bytes
          (var.)        SubSize1    Attribute #1 data
          .
          .
          .
          TagN          Short       NTFS attribute tag value #N
          SizeN         Short       Size of attribute #N, in bytes
          (var.)        SubSizeN    Attribute #N data

          For NTFS, values for Tag1 through TagN are as follows:
          (currently only one set of attributes is defined for NTFS)

          Tag        Size       Description
          -----      ----       -----------
          0x0001     2 bytes    Tag for attribute #1
          Size1      2 bytes    Size of attribute #1, in bytes (24)
          Mtime      8 bytes    64-bit NTFS file last modification time
          Atime      8 bytes    64-bit NTFS file last access time
          Ctime      8 bytes    64-bit NTFS file creation time

          The total length for this block is 28 bytes, resulting in a
          fixed size value of 32 for the TSize field of the NTFS block.

          The NTFS filetimes are 64-bit unsigned integers, stored in Intel
          (least significant byte first) byte order. They determine the
          number of 1.0E-07 seconds (1/10th microseconds!) past WinNT "epoch",
          which is "01-Jan-1601 00:00:00 UTC".
          }

          // проверяем размерность поля с учетом примечания:
          // this field has a fixed total data size of 32 bytes

          // если размер буффера меньше 32 байт - то выходим из процедуры
          if BuffCount < 32 then Break;

          // если же он не равер 32 байтам,
          // то просто пропускаем его и ереходим к слежующей записи
          if BlockSize <> 32 then
          begin
            Dec(BuffCount, BlockSize);
            Continue;
          end;

          // пропускаем поле Reserved
          Dec(BuffCount, 4);

          // Проверяем поле Tag
          if PWord(GetOffset(BuffCount))^ <> 1 then
          begin
            Dec(BuffCount, BlockSize);
            Continue;
          end;
          Dec(BuffCount, 2);

          // Проверяем размер блока данных
          if PWord(GetOffset(BuffCount))^ <> SizeOf(TNTFSFileTime) then
          begin
            Dec(BuffCount, BlockSize);
            Continue;
          end;
          Dec(BuffCount, 2);

          // Читаем сами данные
          FFileHeader.Attributes.ftLastWriteTime := PFileTime(GetOffset(BuffCount))^;
          Dec(BuffCount, SizeOf(TFileTime));
          FFileHeader.Attributes.ftLastAccessTime := PFileTime(GetOffset(BuffCount))^;
          Dec(BuffCount, SizeOf(TFileTime));
          FFileHeader.Attributes.ftCreationTime := PFileTime(GetOffset(BuffCount))^;
          Dec(BuffCount, SizeOf(TFileTime));
       end;
      else
        if Assigned(FOwner.OnLoadExData) then
        begin
          ExDataStream := TMemoryStream.Create;
          try
            ExDataStream.WriteBuffer(GetOffset(BuffCount)^, BlockSize);
            ExDataStream.Position := 0;
            FOwner.OnLoadExData(Self, FItemIndex, HeaderID, ExDataStream);
          finally
            ExDataStream.Free;
          end;
        end;
        Dec(BuffCount, BlockSize);
      end;
    end;
  finally
    FreeMem(Buff);
  end;
end;

//
//  Процедура зачитывает и проверяет валидность структуры LocalFileHeader
//  Задача процедуры получить правильное значение оффсета на начало
//  запакованного блока данных.
// =============================================================================
procedure TFWZipReaderItem.LoadLocalFileHeader;
var
  LocalFileHeader: TLocalFileHeader;
begin
  FOwner.ZIPStream.Position := FFileHeader.RelativeOffsetOfLocalHeader;
  FOwner.ZIPStream.ReadBuffer(LocalFileHeader, SizeOf(TLocalFileHeader));

  if LocalFileHeader.LocalFileHeaderSignature <>
    LOCAL_FILE_HEADER_SIGNATURE then
    raise Exception.Create('Ошибка чтения TLocalFileHeader');

  FFileHeader.DataOffset := FOwner.ZIPStream.Position +
    LocalFileHeader.FilenameLength + LocalFileHeader.ExtraFieldLength;
end;

//
//  Процедура зачитывает строковое значение и переводит его в Ansi формат
// =============================================================================
procedure TFWZipReaderItem.LoadStringValue(var Value: string;
  nSize: Cardinal);
var
  aString: AnsiString;
begin
  if Integer(nSize) > 0 then
  begin
    SetLength(aString, nSize);
    FOwner.ZIPStream.ReadBuffer(aString[1], nSize);
    OemToAnsi(@aString[1], @aString[1]);
    Value := string(aString);
  end;
end;

{ TFWZipReader }

//
//  Процедура очищает данные о открытом ранее архиве
// =============================================================================
procedure TFWZipReader.Clear;
begin
  FLocalFiles.Clear;
  FreeAndNil(FFileStream);
end;

//
//  Функция возвращает количество элементов открытого архива
// =============================================================================
function TFWZipReader.Count: Integer;
begin
  Result := FLocalFiles.Count;
end;

// =============================================================================
constructor TFWZipReader.Create;
begin
  inherited;
  FLocalFiles := TObjectList.Create;
  FPasswordList := TStringList.Create;
  FPasswordList.Duplicates := dupIgnore;
  FPasswordList.Sorted := True;
end;

// =============================================================================
destructor TFWZipReader.Destroy;
begin
  FPasswordList.Free;
  FLocalFiles.Free;
  FFileStream.Free;
  inherited;
end;

//
//  Процедура вызывает обработчик OnProgress
// =============================================================================
procedure TFWZipReader.DoProgress(Sender: TObject; const FileName: string;
  Extracted, TotalSize: Int64);
var
  Percent, TotalPercent: Byte;
  Cancel: Boolean;
begin
  if Assigned(FOnProgress) then
  begin
    if TotalSize = 0 then
      Percent := 100
    else
      Percent := Round(Extracted / (TotalSize / 100));
    if FTotalSizeCount = 0 then
      TotalPercent := 100
    else
      TotalPercent :=
        Round((FTotalProcessedCount + Extracted) / (FTotalSizeCount / 100));
    Cancel := False;
    FOnProgress(Self, FileName, Percent, TotalPercent, Cancel);
    if Cancel then Abort;    
  end;
end;

//
//  Процедура производит автоматическую распаковку архива в указанную папку
// =============================================================================
procedure TFWZipReader.ExtractAll(Path: string);
var
  I, A: Integer;
  OldExtractEvent: TZipExtractItemEvent;
  OldDuplicateEvent: TZipDuplicateEvent;
  CurrentItem: TFWZipReaderItem;
  ExtractResult: TExtractResult;
  CancelExtract, Handled: Boolean;
  Password: string;
  FreeAvailable, TotalSpace: TLargeInteger;
begin
  FTotalSizeCount := 0;
  FTotalProcessedCount := 0;
  for I := 0 to Count - 1 do
    Inc(FTotalSizeCount, Item[I].UncompressedSize);

  // Правка пустого и относительного пути
  Path := PathCanonicalize(Path);
  if Path = '' then
    Path := GetCurrentDir;

  // Проверка хватит ли места на диске?
  if GetDiskFreeSpaceEx(PChar(Path), FreeAvailable, TotalSpace, nil) then
    if FreeAvailable <= FTotalSizeCount then
      raise Exception.Create('Недостаточно места на диске.');

  for I := 0 to Count - 1 do
  begin
    CurrentItem := Item[I];
    OldExtractEvent := CurrentItem.OnProgress;
    try
      CurrentItem.OnProgress := DoProgress;
      OldDuplicateEvent := CurrentItem.OnDuplicate;
      try
        CurrentItem.OnDuplicate := OnDuplicate;
        // Пробуем извлечь файл
        try
          ExtractResult := CurrentItem.Extract(Path, '');
          if ExtractResult = erNeedPassword then
          begin
            // Если произошла обшибка из-за того что файл зашифрован,
            // пробуем расшифровать его используя список известных паролей
            for A := 0 to FPasswordList.Count - 1 do
            begin
              ExtractResult := CurrentItem.Extract(Path, FPasswordList[A]);
              if ExtractResult in [erDone, erSkiped] then Break;
            end;
            // если не получилось, запрашиваем пароль у пользователя
            if ExtractResult = erNeedPassword then
              if Assigned(FOnNeedPwd) then
              begin
                CancelExtract := False;
                while ExtractResult = erNeedPassword do
                begin
                  Password := '';
                  FOnNeedPwd(Self, CurrentItem.FileName,
                    Password, CancelExtract);
                  if CancelExtract then Exit;
                  if Password <> '' then
                  begin
                    FPasswordList.Add(Password);
                    ExtractResult := CurrentItem.Extract(Path, Password);
                  end;
                end;
              end
              else
                raise EWrongPasswordException.Create(
                  'Ошибка извлечения данных. Неверный пароль.');
          end;
        except

          // Пользователь отменил распаковку архива
          on E: EAbort do
            Exit;

          // Ну не прерывать же распаковку из-за исключения на одном файле?
          // Пусть решение о прерывании распаковки принимают снаружи
          on E: Exception do
          begin
            Handled := False;
            if Assigned(FException) then
              FException(Self, E, I, Handled);
            if not Handled then
              raise E;
          end;
        end;
        Inc(FTotalProcessedCount, CurrentItem.UncompressedSize);
      finally
        CurrentItem.OnDuplicate := OldDuplicateEvent;
      end;
    finally
      CurrentItem.OnProgress := OldExtractEvent;
    end;
  end;
end;

//
//  Функция возвращает индекс элемента по его имени
// =============================================================================
function TFWZipReader.GetElementIndex(const FileName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if AnsiCompareText(Item[I].FileName, FileName) = 0 then
    begin
      Result := I;
      Break;
    end;
end;

//
//  Функция возвращает элемент архива по его индексу
// =============================================================================
function TFWZipReader.GetItem(Index: Integer): TFWZipReaderItem;
begin
  Result := TFWZipReaderItem(FLocalFiles[Index]);
end;

//
//  Процедура зачитывает центральную директорию архива
// =============================================================================
procedure TFWZipReader.LoadCentralDirectoryFileHeader;
var
  EndOfLoadCentralDirectory: Int64;
begin
  EndOfLoadCentralDirectory := FZIPStream.Position + SizeOfCentralDirectory;
  while FZIPStream.Position < EndOfLoadCentralDirectory do
    FLocalFiles.Add(TFWZipReaderItem.InitFromStream(Self, Count, FZIPStream));
  if Count <> TotalEntryesCount then
    raise Exception.Create(
      'Ошибка чтения центральной директории. ' +
      'Количетсво элементов не соответствует заявленному.');
end;

//
//  Процедура проеряет валидность структуры EndOfCentralDirectory
//  Задача процедуры получить оффсет на начало CentralDirectory
// =============================================================================
procedure TFWZipReader.LoadEndOfCentralDirectory;
var
  Zip64LocatorOffset: Int64;
begin
  // Согласно спецификации в случае наличия 64-битных структур
  // TZip64EOFCentralDirectoryLocator идет сразу перед EndOfCentralDirectory.
  // Запоминаем оффсет на предполагаемую позицию данной структуры.
  Zip64LocatorOffset := FZIPStream.Position -
    SizeOf(TZip64EOFCentralDirectoryLocator);

  FZIPStream.ReadBuffer(FEndOfCentralDir, SizeOf(TEndOfCentralDir));

  if FEndOfCentralDir.NumberOfThisDisk <> 0 then
    raise Exception.Create('Многотомные архивы не поддерживаются.');

  if FEndOfCentralDir.EndOfCentralDirSignature <>
    END_OF_CENTRAL_DIR_SIGNATURE then
    raise Exception.Create('Ошибка чтения структуры TEndOfCentralDir');

  LoadStringValue(FEndOfCentralDirComment,
    FEndOfCentralDir.ZipfileCommentLength);

  {
      6)  If one of the fields in the end of central directory
          record is too small to hold required data, the field
          should be set to -1 (0xFFFF or 0xFFFFFFFF) and the
          Zip64 format record should be created.
  }

  if (FEndOfCentralDir.NumberOfThisDisk = MAXWORD) or
    (FEndOfCentralDir.NumberOfTheDiskWithTheStart = MAXWORD) or
    (FEndOfCentralDir.TotalNumberOfEntriesOnThisDisk = MAXWORD) or
    (FEndOfCentralDir.TotalNumberOfEntries = MAXWORD) or
    (FEndOfCentralDir.SizeOfTheCentralDirectory = MAXDWORD) or
    (FEndOfCentralDir.OffsetOfStartOfCentralDirectory = MAXDWORD) then
  begin
    // Одна из позиций не содержит валидных данных
    // Согласно спецификации их необходимо получить через Zip64Locator
    FZIPStream.Position := Zip64LocatorOffset;
    LoadZIP64Locator;
  end
  else
    FZIPStream.Position := FEndOfCentralDir.OffsetOfStartOfCentralDirectory;
end;

//
//  Процедура открывает архив по указанному пути
// =============================================================================
procedure TFWZipReader.LoadFromFile(const Value: string);
begin
  FFileStream.Free;
  FFileStream := TFileStream.Create(Value, fmOpenRead);
  LoadFromStream(FFileStream);
end;

//
//  Процерура открывает архив из переданного стрима
// =============================================================================
procedure TFWZipReader.LoadFromStream(Value: TStream);
var
  Buff: Pointer;
  I, BuffSize: Integer;
  Offset, EndOfCentralDirectoryOffset: Int64;
  Cursor: PByte;
begin
  FLocalFiles.Clear;
  FZIPStream := Value;

  // Ищем сигнатуру EndOfCentralDir
  BuffSize := $FFFF;
  EndOfCentralDirectoryOffset := 0;
  Offset := Value.Size;
  GetMem(Buff, BuffSize);
  try
    while Offset > 0 do
    begin
      Dec(Offset, BuffSize);
      if Offset < 0 then
      begin
        Inc(BuffSize, Offset);
        Offset := 0;
      end;
      Value.Position := Offset;
      Value.ReadBuffer(Buff^, BuffSize);
      Cursor := Buff;
      for I := 0 to BuffSize - 1 do
      begin
        if PCardinal(Cursor)^ = END_OF_CENTRAL_DIR_SIGNATURE then
        begin
          EndOfCentralDirectoryOffset := Offset + I;
          Break;
        end
        else
          Inc(Cursor);
      end;
      if EndOfCentralDirectoryOffset > 0 then
        Break;
    end;
  finally
    FreeMem(Buff);
  end;
  if EndOfCentralDirectoryOffset = 0 then
    raise Exception.Create('Не найдена сигнатура END_OF_CENTRAL_DIR_SIGNATURE.');

  // Зачитываем саму структуру EndOfCentralDirectory
  // При необходимости будут зачитаны данные из 64 битных структур
  Value.Position := EndOfCentralDirectoryOffset;
  LoadEndOfCentralDirectory;

  // Теперь указатель стрима выставлен на начало структуры CentralDirectory
  // Зачитываем ее саму
  LoadCentralDirectoryFileHeader;
end;

//
//  Процедура зачитывает строковое значение и переводит его в Ansi формат
// =============================================================================
procedure TFWZipReader.LoadStringValue(var Value: AnsiString; nSize: Cardinal);
begin
  if Integer(nSize) > 0 then
  begin
    SetLength(Value, nSize);
    FZIPStream.ReadBuffer(Value[1], nSize);
    OemToAnsi(@Value[1], @Value[1]);
  end;
end;

//
//  Процедура проверяет валидность структуры Zip64EOFCentralDirectoryRecord
//  Задача процедуру получить оффсет на CentralDirectory
// =============================================================================
procedure TFWZipReader.LoadZip64EOFCentralDirectoryRecord;
begin
  FZIPStream.ReadBuffer(FZip64EOFCentralDirectoryRecord,
    SizeOf(TZip64EOFCentralDirectoryRecord));

  if not Zip64Present then
    raise Exception.Create(
      'Ошибка чтения структуры FZip64EOFCentralDirectoryRecord');

  { TODO : Зачитывать ExData или нет? }

  FZIPStream.Position := FZip64EOFCentralDirectoryRecord.Offset;
end;

//
//  Процедура проверяет валидность структуры ZIP64Locator
//  Задача процедуру получить оффсет на Zip64EOFCentralDirectoryRecord
// =============================================================================
procedure TFWZipReader.LoadZIP64Locator;
begin
  FZIPStream.ReadBuffer(FZip64EOFCentralDirectoryLocator,
    SizeOf(TZip64EOFCentralDirectoryLocator));

  if FZip64EOFCentralDirectoryLocator.Signature <>
    ZIP64_END_OF_CENTRAL_DIR_LOCATOR_SIGNATURE then
    raise Exception.Create(
      'Ошибка чтения структуры TZip64EOFCentralDirectoryLocator');

  // Данная структура хранит оффсет на TZip64EOFCentralDirectoryRecord
  // В котором и храниться расширенная информация
  FZIPStream.Position := FZip64EOFCentralDirectoryLocator.RelativeOffset;
  LoadZip64EOFCentralDirectoryRecord;
end;

//
//  Функция возвращает размер центральной директории
// =============================================================================
function TFWZipReader.SizeOfCentralDirectory: Int64;
begin
  if Zip64Present then
    Result := FZip64EOFCentralDirectoryRecord.Size
  else
    Result := FEndOfCentralDir.SizeOfTheCentralDirectory;
end;

//
//  Функция возвращает количество элементов архива
// =============================================================================
function TFWZipReader.TotalEntryesCount: Integer;
begin
  if Zip64Present then
    Result := FZip64EOFCentralDirectoryRecord.TotalNumber2
  else
    Result := FEndOfCentralDir.TotalNumberOfEntries;
end;

//
//  Вспомогательная функция,
//  указывает из какого блока данных брать валидное значение
// =============================================================================
function TFWZipReader.Zip64Present: Boolean;
begin
  Result := FZip64EOFCentralDirectoryRecord.Zip64EndOfCentralDirSignature =
    ZIP64_END_OF_CENTRAL_DIR_SIGNATURE
end;

end.
