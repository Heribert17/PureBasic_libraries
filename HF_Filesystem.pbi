;   Description: Modul with procedure für directory and file manipulation
;            OS: Windows
;        Author: Heribert Füchtenhans
;       Version: 3.0
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2018 Heribert Füchtenhans
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.


DeclareModule HF_Filesystem
  Declare.b CreateDirectories(Dir.s)
  ; Create directory including none existing subdirectories
  
  Declare.i SetFolderCreationDate(folder.s, date.l) 
  ; Windows only; Sets the creation time of a folder to date
  
  Declare.i SetFolderLastWriteDate(folder.s, date.l)
  ; Windows only; Sets the last write time to date
  
  Declare   GetDirectoryFilenamesRecursiv(List Filenames.s(), Directory.s, Pattern.s)
  ; Creates in Filenames a list containing all files Directory an all subdirectores that match Pattern
  ; The entries in Filenames include the directory names.
  
  Declare.s GetNewestFilename(Searchpattern.s)
  ; returns the newest filename of all files that match Searchpattern (with * and/or ?) in a directory.
  ; Used to find the newest log file when they are named like for eg TomCat_2018_06_01_10_00_00.txt
  ; return the filename or "" if nothing found
  ; eg: GetNewestFilename("c\temp\abc*.dat")
  
  Declare.s JoinPath(Path.s, Entry.s)
  ; Joins path and Entry to build a valid file- ord directory name
  
  Declare.s GetFullFilename(Filename.s)
  ; Windows only; returns the full qualified name of Filename
  
  Declare.s GetFilenameWithoutDrive(Filename.s)
  ; retunrns the filename without the drive or UNC part
  
  Declare.b DeleteOldFiles(DirToSearch.s, FilelastWriteTimeLessThen.i, DeleteEmptyDirs.b=#False)
  ; Deletes recursive all files that are older then FilelastWriteTimeLessThen. If given also deletes empty directories found
  
  Declare.b CompressDirectoryToZip(DirToCompress.s, ZipFilename.s)
  ; Compresses a whole directory to a zip file
  
  Declare.s MapDrive(Sharename.s, User.s, Password.s)
  ; Windows only. Maps a share on another Windows System (or a samba share) using the given Username and Password
  ; return an errormessage or "" on success
  
  Declare   UnmapDrive(Sharename.s)
  ; Windows only. Unmaps a mapped Share
  
  Declare   FileMonitorAddFile(Filename.s, CallbackRoutine)
  ; Windows only; Tells the windows system to inform me, when a file changes. The CallbackRoutine must match the Prototype below and is
  ; called asynchronous when Windows detects a change. The callback ist called with on of these actions:
  ; "ADDED", "MODIFIED", "REMOVED", "RENAMED_NEWNAME", "RENAMED_OLDNAME".
  ; In the case of MODIFIED and RENAMED_NEWNAME the appended text is returned.
  ; based on a solution from merendo (https://www.purebasic.fr/english/viewtopic.php?p=378528)

  Prototype FileMonitorCallBack(Action.s, Filename.s, Text.s)
  ; Prototype for the CallbackRoutine in FileMonitorAddFile
  
EndDeclareModule



Module HF_Filesystem
  
  EnableExplicit

  ;---------- internal procedures
  
  Procedure getDirEntriesInternal(List Filenames.s(), Directory.s, Pattern.s)
    Protected Dir.i
    
    ; get all directory content
    dir = ExamineDirectory(#PB_Any, Directory, Pattern)
    If dir
      While NextDirectoryEntry(dir)
        If DirectoryEntryType(dir) = #PB_DirectoryEntry_File
          AddElement(Filenames()) : Filenames() = JoinPath(Directory, DirectoryEntryName(dir))
        EndIf
      Wend
      FinishDirectory(dir)
    EndIf
    ; now recursivly walk through the directories
    dir = ExamineDirectory(#PB_Any, Directory, "")
    If dir
      While NextDirectoryEntry(dir)
        If DirectoryEntryType(dir) = #PB_DirectoryEntry_Directory And DirectoryEntryName(dir) <> "." And DirectoryEntryName(dir) <> ".."
          getDirEntriesInternal(Filenames(), JoinPath(Directory, DirectoryEntryName(dir)), Pattern)
        EndIf
      Wend
      FinishDirectory(dir)
    EndIf
  EndProcedure
  
  
  Procedure.b CompressDirectoryToZipWalkRecursive(StartQuellverzeichnis.s, Quellverzeichnis.s, PackerID.i)
    Protected rwert.b=#True, Id.i, Fullfilename.s, Archivname.s
    
    Id = ExamineDirectory(#PB_Any, Quellverzeichnis, "*")
    If Id <> 0
      While NextDirectoryEntry(Id)
        Fullfilename = JoinPath(Quellverzeichnis, DirectoryEntryName(Id))
        If DirectoryEntryType(Id) = #PB_DirectoryEntry_File
          Archivname = Mid(Fullfilename, Len(StartQuellverzeichnis)+1)
          If Left(Archivname, 1) = "\" : Archivname = Mid(Archivname, 2) : EndIf
          If AddPackFile(PackerID, Fullfilename, Archivname) = 0
            rwert = #False
          EndIf
        ElseIf DirectoryEntryName(Id) <> "." And DirectoryEntryName(Id) <> ".."
          If Not CompressDirectoryToZipWalkRecursive(StartQuellverzeichnis, Fullfilename, PackerID) : rwert = #False : EndIf
        EndIf
      Wend
      FinishDirectory(Id)
    Else
      rwert = #False
    EndIf
    ProcedureReturn rwert
  EndProcedure

 
  
  
  ;---------- public procedures
  
  ; This function creates several (sub-) directories with only one call...
  Procedure.b CreateDirectories(Dir.s)
    If Len(Dir) = 0 
       ProcedureReturn #False 
    Else 
      If (Right(Dir, 1) = "\") 
        Dir.s = Left(Dir, Len(Dir) - 1) 
      EndIf 
      If (Len(Dir) < 3) Or FileSize(Dir) = -2 Or GetPathPart(Dir) = Dir
        ProcedureReturn #False 
      EndIf 
      CreateDirectories(GetPathPart(Dir))
      CreateDirectory(Dir)
      ProcedureReturn #True 
    EndIf 
  EndProcedure 
  
  
  ; Set creation date/time of a folder
  ; Return 0 if error
  Procedure.i SetFolderCreationDate(folder.s, date.l) 
    #FILE_SHARE_DELETE = 4
    Protected ft.filetime 
    Protected st.SYSTEMTIME 
    Protected tz.TIME_ZONE_INFORMATION 
    Protected result.l=1
    Protected DesiredAccess.i, ShareMode.i, Disposition.i, Flags.i, FolderHandle.i
    
    GetTimeZoneInformation_(@tz) 
    date = AddDate(date, #PB_Date_Minute, tz\Bias) 
    If tz\DaylightDate 
      date = AddDate(date, #PB_Date_Minute, tz\DaylightBias) 
    EndIf 
    With st 
      \wYear   = Year(date) 
      \wMonth  = Month(date) 
      \wDay    = Day(date) 
      \wHour   = Hour(date) 
      \wMinute = Minute(date) 
      \wSecond = Second(date) 
    EndWith 
    SystemTimeToFileTime_(@st, @ft) 
    DesiredAccess = #GENERIC_READ|#GENERIC_WRITE 
    ShareMode     = #FILE_SHARE_READ|#FILE_SHARE_DELETE 
    Disposition   = #OPEN_EXISTING 
    Flags         = #FILE_FLAG_BACKUP_SEMANTICS 
    FolderHandle  = CreateFile_(folder, DesiredAccess, ShareMode, 0, Disposition, Flags, 0) 
    If FolderHandle 
      result = SetFileTime_(FolderHandle, @ft, #Null, #Null) 
      CloseHandle_(FolderHandle) 
    Else 
      result = 0 
    EndIf 
    ProcedureReturn result 
  EndProcedure 
  
  
  ; Set the last write time of a directory
  ; Return 0 bei einem Fehler
  Procedure.i SetFolderLastWriteDate(folder.s, date.l) 
    #FILE_SHARE_DELETE = 4 
    
    Protected ft.filetime 
    Protected st.SYSTEMTIME 
    Protected tz.TIME_ZONE_INFORMATION 
    Protected result.l 
    Protected DesiredAccess.i, ShareMode.i, Disposition.i, Flags.i, FolderHandle.i
    
    GetTimeZoneInformation_(@tz) 
    date = AddDate(date, #PB_Date_Minute, tz\Bias) 
    If tz\DaylightDate 
      date = AddDate(date, #PB_Date_Minute, tz\DaylightBias) 
    EndIf 
    With st 
      \wYear   = Year(date) 
      \wMonth  = Month(date) 
      \wDay    = Day(date) 
      \wHour   = Hour(date) 
      \wMinute = Minute(date) 
      \wSecond = Second(date) 
    EndWith 
    SystemTimeToFileTime_(@st, @ft) 
    DesiredAccess = #GENERIC_READ|#GENERIC_WRITE 
    ShareMode     = #FILE_SHARE_READ|#FILE_SHARE_DELETE 
    Disposition   = #OPEN_EXISTING 
    Flags         = #FILE_FLAG_BACKUP_SEMANTICS 
    FolderHandle  = CreateFile_(folder, DesiredAccess, ShareMode, 0, Disposition, Flags, 0) 
    If FolderHandle 
      result = SetFileTime_(FolderHandle, #Null, #Null, @ft) 
      CloseHandle_(FolderHandle) 
    Else 
      result = 0 
    EndIf 
    ProcedureReturn result 
  EndProcedure 
  
  
  Procedure GetDirectoryFilenamesRecursiv(List Filenames.s(), Directory.s, Pattern.s)
    ClearList(Filenames())
    getDirEntriesInternal(Filenames(), Directory, Pattern)
  EndProcedure
  

  Procedure.s GetNewestFilename(Searchpattern.s)
    Protected FoundFileName.s="", LastWriteTime.i=0, Path.s, DirectoryHandle.i
    
    Path = GetPathPart(Searchpattern)
    DirectoryHandle = ExamineDirectory(#PB_Any, Path, GetFilePart(Searchpattern))
    If DirectoryHandle
      While NextDirectoryEntry(DirectoryHandle)
        If DirectoryEntryDate(DirectoryHandle, #PB_Date_Modified) > LastWriteTime
          LastWriteTime = DirectoryEntryDate(DirectoryHandle, #PB_Date_Modified)
          FoundFileName = DirectoryEntryName(DirectoryHandle)
        EndIf
      Wend
      FinishDirectory(DirectoryHandle)
    EndIf
    If FoundFileName = ""
      ProcedureReturn ""
    Else
      ProcedureReturn HF_Filesystem::JoinPath(Path, FoundFileName)
    EndIf
  EndProcedure
  
  
  ; Joins path and Entry to a new filename
  Procedure.s JoinPath(Path.s, Entry.s)
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      Protected.s SEPARATOR = "\"
    CompilerElse
      Protected.s SEPARATOR = "/"
    CompilerEndIf
    
    If Right(Path, 1) <> SEPARATOR And Path <> "" And Right(Path, 1) <> ":"
      Path + SEPARATOR
    EndIf
    If Left(Entry, 1) = SEPARATOR And Right(Path, 1) = SEPARATOR
      Entry = Mid(Entry, 2)
    EndIf
    ProcedureReturn Path + Entry
  EndProcedure
  
  
  Procedure.s GetFullFilename(Filename.s)
    Protected Buffer.s, FilePart.i
    
    Buffer = Space(32768)
    GetFullPathName_(FileName, Len(Buffer), @Buffer, @FilePart) 
    ProcedureReturn Buffer
  EndProcedure
  
  
  Procedure.s GetFilenameWithoutDrive(Filename.s)
    Protected NewFilename.s, Pos.i, Count.i = 0
    
    If Left(Filename, 2) = "\\"     ; UNC Name
      For Pos = 1 To Len(Filename)
        If Mid(Filename, Pos, 1) = "\" : Count + 1 : EndIf
        If Count = 4 : Break : EndIf
      Next
      NewFilename = Mid(Filename, Pos+1)
    Else
      If Mid(Filename, 2, 1) = ":"
        NewFilename = Mid(Filename, 3)
      Else
        NewFilename = Filename
      EndIf
    EndIf
    ProcedureReturn NewFilename
  EndProcedure
  
  
  Procedure.b DeleteOldFiles(DirToSearch.s, FileLastWriteTimeLessThen.i, DeleteEmptyDirs.b=#False)
    Protected rwert=#True, Id.i, TestId.i, Fullfilename.s, Count.i
    
    Id = ExamineDirectory(#PB_Any, DirToSearch, "*")
    If Id <> 0
      While NextDirectoryEntry(Id)
        Fullfilename = JoinPath(DirToSearch, DirectoryEntryName(Id))
        If DirectoryEntryType(Id) = #PB_DirectoryEntry_File
          If DirectoryEntryDate(Id, #PB_Date_Modified) < FileLastWriteTimeLessThen
            DeleteFile(Fullfilename)
          EndIf
        ElseIf DirectoryEntryName(Id) <> "." And DirectoryEntryName(Id) <> ".."
          If Not DeleteOldFiles(Fullfilename, FilelastWriteTimeLessThen)
            rwert = #False
          Else
            If DeleteEmptyDirs
              ; If directory is empty, delete it
              TestId = ExamineDirectory(#PB_Any, Fullfilename, "*")
              If TestId <> 0
                Count = 0
                While NextDirectoryEntry(TestId)
                  If DirectoryEntryType(TestId) = #PB_DirectoryEntry_Directory And (DirectoryEntryName(TestId) <> "." Or DirectoryEntryName(TestId) <> "..") : Continue : EndIf
                  Count + 1
                Wend
                If Count = 0 : DeleteDirectory(Fullfilename, "") : EndIf
              EndIf
            EndIf
          EndIf
        EndIf
      Wend
      FinishDirectory(Id)
    Else
      rwert = #False
    EndIf
    ProcedureReturn rwert
  EndProcedure
  
  
  ; Komprimieren eines gesamten Verzeichnisses in eine ZIP Datei
  ; returns #True wenn OK, sonst #False
  Procedure.b CompressDirectoryToZip(DirToCompress.s, ZipFilename.s)
    Protected myPacker.i, rwert=#True
    
    UseZipPacker()
    myPacker = CreatePack(#PB_Any, ZipFilename, #PB_PackerPlugin_Zip)
    If myPacker
      rwert = CompressDirectoryToZipWalkRecursive(DirToCompress, DirToCompress, myPacker)
      ClosePack(myPacker)
    Else
      rwert = #False
    EndIf
    ProcedureReturn rwert
  EndProcedure
  
  
  ;---------- Network sharing
  
  #NO_ERROR = 0
  #CONNECT_UPDATE_PROFILE = $1
  ; The following includes all the constants defined for NETRESOURCE,
  ; not just the ones used in this example\
  #RESOURCETYPE_DISK = $1
  #RESOURCETYPE_PRINT = $2
  #RESOURCETYPE_ANY = $0
  #RESOURCE_CONNECTED = $1
  #RESOURCE_REMBERED = $3
  #RESOURCE_GLOBALNET = $2
  #RESOURCEDISPLAYTYPE_DOMAIN = $1
  #RESOURCEDISPLAYTYPE_GENERIC = $0
  #RESOURCEDISPLAYTYPE_SERVER = $2
  #RESOURCEDISPLAYTYPE_SHARE = $3
  #RESOURCEUSAGE_CONNECTABLE = $1
  #RESOURCEUSAGE_CONTAINER = $2
  ; Error Constants:
  #ERROR_ACCESS_DENIED = 5
  #ERROR_ALREADY_ASSIGNED = 85
  #ERROR_BAD_DEV_TYPE = 66
  #ERROR_BAD_DEVICE = 1200
  #ERROR_BAD_NET_NAME = 67
  #ERROR_BAD_PROFILE = 1206
  #ERROR_BAD_PROVIDER = 1204
  #ERROR_BUSY = 170
  #ERROR_CANCELLED = 1223
  #ERROR_CANNOT_OPEN_PROFILE = 1205
  #ERROR_DEVICE_ALREADY_REMBERED = 1202
  #ERROR_EXTENDED_ERROR = 1208
  #ERROR_INVALID_PASSWORD = 86
  #ERROR_NO_NET_OR_BAD_PATH = 1203
  
  Procedure.s MapDrive(Sharename.s, User.s, Password.s)
    Protected res.NETRESOURCE, result.i, Msg.s
    
    res\dwType = #RESOURCETYPE_DISK
    res\lpLocalName = #Null
    res\lpRemoteName = @Sharename
    res\lpProvider = #Null
    ; The following error are ignored by WNetAddConnection2_ 
    res\dwScope = #RESOURCE_GLOBALNET
    res\dwDisplayType = #RESOURCEDISPLAYTYPE_GENERIC
    res\dwUsage = #RESOURCEUSAGE_CONNECTABLE
    res\lpComment = #Null
    
    If WNetAddConnection2_(res, @Password, @User, 4) <> #NO_ERROR ; dwFlag 4 is CONNECT_TEMPORARY
      result = GetLastError_()
      Msg = Str(result) + " - "
      Select result
        Case #ERROR_ACCESS_DENIED
          Msg + "Access to the network resource was denied."
        Case #ERROR_ALREADY_ASSIGNED
          Msg + "The local device specified by lpLocalName is already connected to a network resource."
        Case #ERROR_BAD_DEV_TYPE
          Msg + "The type of local device and the type of network resource do not match."
        Case #ERROR_BAD_DEVICE
          Msg + "The value specified by lpLocalName is invalid."
        Case #ERROR_BAD_NET_NAME
          Msg + "The value specified by lpRemoteName is not acceptable to any network resource provider. The resource name is invalid, or the named resource cannot be located."
        Case #ERROR_BAD_PROFILE
          Msg + "The user profile is in an incorrect format."
        Case #ERROR_BAD_PROVIDER
          Msg + "The value specified by lpProvider does not match any provider."
        Case #ERROR_BUSY
          Msg + "The router or provider is busy, possibly initializing. The caller should retry."
          ;Case #ERROR_CANCELLED
          ;Msg$ + "The attempt To make the connection was cancelled by the user through a dialog box from one of the network resource providers, Or by a called resource."
        Case #ERROR_CANNOT_OPEN_PROFILE
          Msg + "The system is unable to open the user profile to process persistent connections."
        Case #ERROR_DEVICE_ALREADY_REMEMBERED
          Msg + "An entry for the device specified in lpLocalName is already in the user profile."
        Case #ERROR_EXTENDED_ERROR
          Msg + "A network-specific error occured. Call the WNetGetLastError function to get a description of the error."
        Case #ERROR_INVALID_PASSWORD
          Msg + "The specified password is invalid."
        Case #ERROR_NO_NET_OR_BAD_PATH
          Msg + "A network component has not started, or the specified name could not be handled."
        Case #ERROR_NO_NETWORK
          Msg + "There is no network present."
        Default
          Msg + "Not known:"
      EndSelect
      ProcedureReturn Msg
    EndIf
  EndProcedure
  
  
  ; Disconnet share
  Procedure UnmapDrive(Sharename.s)
    WNetCancelConnection2_ (Sharename, #CONNECT_UPDATE_PROFILE, 0) ; Disconnect the drive
  EndProcedure
  
  
  
  ;---------- Filesystem monitoring
  
  #FILE_NOTIFY_CHANGE_FILE_NAME = 1 
  ; Any file name change in the watched directory or subtree causes a change notification wait operation to return. 
  ; Changes include renaming, creating, or deleting a file name. 

  #FILE_NOTIFY_CHANGE_DIR_NAME = 2 
  ; Any directory-name change in the watched directory or subtree causes a change notification wait operation to return. 
  ; Changes include creating or deleting a directory. 
  
  #FILE_NOTIFY_CHANGE_ATTRIBUTES = 4 
  ; Any attribute change in the watched directory or subtree causes a change notification wait operation to return. 
  
  #FILE_NOTIFY_CHANGE_SIZE = 8 
  ; Any file-size change in the watched directory or subtree causes a change notification wait operation to return. The operating 
  ; system detects a change in file size only when the file is written to the disk. For operating systems that use extensive caching, 
  ; detection occurs only when the cache is sufficiently flushed. 
  
  #FILE_NOTIFY_CHANGE_LAST_WRITE = $10 
  ; Any change to the last write-time of files in the watched directory or subtree causes a change notification wait operation to return. The 
  ; operating system detects a change to the last write-time only when the file is written to the disk. For operating systems that use extensive 
  ; caching, detection occurs only when the cache is sufficiently flushed. 
  
  #FILE_NOTIFY_CHANGE_SECURITY = $100 
  ; Any security-descriptor change in the watched directory or subtree causes a change notification wait operation to return. 
  
  #INVALID_HANDLE_VALUE = - 1 
  #MYINFINITE = $FFFFFFFF 
  #STATUS_WAIT_0 = 0 
  #WAIT_OBJECT_0 = #STATUS_WAIT_0 + 0 
  
  
  Structure StruktureFileMonitor
    PathLower.s
    FilenameLower.s
    FilePosition.l
    FullFilename.s
    CallbackRoutine.FileMonitorCallBack
  EndStructure
  Structure StruktureFileMonitorThreads
    WatchPathLower.s
    ThreadNumber.i
  EndStructure
  
  
  Define NewList FileMonitorData.StruktureFileMonitor()
  Define NewList FileMonitorThreads.StruktureFileMonitorThreads()
  Define FileMonitorError.s
  Define FileMonitorMutex.i = CreateMutex()
  
  Import "kernel32.lib"
    ReadDirectoryChangesW(hDirectory.l, *lpBuffer, nbBufferLen.l, bWatchSubTree.b, dwNotifyFilter.l, *lpBytesReturned, *lpOverlapped.OVERLAPPED, 
                          lpCompletitionRoutine)
  EndImport
  
  
  Procedure.s FileMonitorReadFile(*FileMonitorData.StruktureFileMonitor, ChangedFilename.s=#Null$)
    Protected Filename.s, Filehandle.i, FileContent.s, filelength.i, readlength.i
    Static *MemoryID = #NUL
    
    If *MemoryID = #NUL : *MemoryID = AllocateMemory(2049) : EndIf
    If Not *MemoryID : ProcedureReturn "" : EndIf
    FileContent = ""
    ; Datei öffnen und ab letzter Position bis zum Ende lesen
    Filename = *FileMonitorData\FullFilename
    If ChangedFilename <> #Null$ : Filename = ChangedFilename : EndIf
    Filehandle = ReadFile(#PB_Any, Filename, #PB_File_SharedRead | #PB_File_SharedWrite)
    If Filehandle
      filelength = Lof(Filehandle)     ; get the length of opened file
      readlength = filelength
      If filelength >= *FileMonitorData\FilePosition
        FileSeek(Filehandle, *FileMonitorData\FilePosition)
        readlength = filelength - *FileMonitorData\FilePosition
      EndIf
      If readlength > MemorySize(*MemoryID)
        FreeMemory(*MemoryID)
        *MemoryID = AllocateMemory(readlength + 2049)
      EndIf
      ReadData(Filehandle, *MemoryID, readlength)
      CloseFile(Filehandle)
      FileContent = PeekS(*MemoryID, readlength, #PB_Ascii)
      *FileMonitorData\FilePosition = filelength
    EndIf
    ProcedureReturn FileContent
  EndProcedure
  
  
  Procedure FileMonitorThread(*FileMonitorThread.StruktureFileMonitorThreads)
    Shared FileMonitorMutex.i, FileMonitorData.StruktureFileMonitor()
    ; structure for the needed
    Structure STRUKTURE_FILE_NOTIFY_INFORMATION
      NextEntryOffset.l
      Action.l
      FileNameLength.l
      Filename.s{512}
    EndStructure
    Protected *buffer = AllocateMemory(64*SizeOf(STRUKTURE_FILE_NOTIFY_INFORMATION))
    Protected *ovlp.OVERLAPPED = AllocateMemory(SizeOf(OVERLAPPED))
    Protected dwOffset.l=0, bytesRead.l, FileContent.s
    Protected *pInfo.STRUKTURE_FILE_NOTIFY_INFORMATION
    Protected Filename.s, WatchPath.s, Action.s, hDir.i
    ; Notify events
    Enumeration
      #FILE_ACTION_ADDED = 1
      #FILE_ACTION_REMOVED
      #FILE_ACTION_MODIFIED
      #FILE_ACTION_RENAMED_OLD_NAME
      #FILE_ACTION_RENAMED_NEW_NAME
    EndEnumeration
    
    WatchPath = *FileMonitorThread\WatchPathLower
    hDir = CreateFile_(WatchPath, #FILE_LIST_DIRECTORY, #FILE_SHARE_READ | #FILE_SHARE_WRITE | #FILE_SHARE_DELETE, #Null, #OPEN_EXISTING, 
                       #FILE_FLAG_BACKUP_SEMANTICS, #Null)
    While ReadDirectoryChangesW(hDir, *buffer, MemorySize(*buffer), #True, #FILE_NOTIFY_CHANGE_FILE_NAME | #FILE_NOTIFY_CHANGE_SIZE, @bytesRead, #Null, #Null)
      dwOffset = 0
      Repeat
        *pInfo = *buffer + dwOffset
        Filename = ""
        Filename = LCase(PeekS(@*pInfo\Filename, *pInfo\FileNameLength/2, #PB_Unicode))
        Action = "???"
        FileContent = ""
        LockMutex(FileMonitorMutex)
        ; search for Entry with my Path and the filename
        ForEach FileMonitorData()
          If FileMonitorData()\PathLower = WatchPath And FileMonitorData()\FilenameLower = Filename
            FileContent = ""
            Select *pInfo\Action
              Case #FILE_ACTION_ADDED
                Action = "ADDED"
                FileMonitorData()\FilePosition = 0
              Case #FILE_ACTION_MODIFIED
                Action = "MODIFIED"
                FileContent = FileMonitorReadFile(FileMonitorData())
              Case #FILE_ACTION_REMOVED
                Action = "REMOVED"
                FileContent = " "
              Case #FILE_ACTION_RENAMED_NEW_NAME
                Action = "RENAMED_NEWNAME"
                FileContent = FileMonitorReadFile(@FileMonitorData(), HF_Filesystem::JoinPath(GetPathPart(FileMonitorData()\FullFilename), Filename))
                FileMonitorData()\FilePosition = 0
              Case #FILE_ACTION_RENAMED_OLD_NAME
                Action = "RENAMED_OLDNAME"
                FileContent = " "
            EndSelect
            UnlockMutex(FileMonitorMutex)
            If FileContent <> "" : FileMonitorData()\CallbackRoutine(Action, Filename, FileContent) : EndIf
            Break
          EndIf
        Next
        If FileContent = "" : UnlockMutex(FileMonitorMutex) : EndIf
        dwOffset + *pInfo\NextEntryOffset
      Until *pInfo\NextEntryOffset = 0
    Wend
    FreeMemory(*buffer)
    FreeMemory(*ovlp.OVERLAPPED)
  EndProcedure 
  
  
  Procedure FileMonitorAddFile(Filename.s, CallBackRoutine)
    Shared FileMonitorData.StruktureFileMonitor(), FileMonitorThreads.StruktureFileMonitorThreads(), FileMonitorError.s, FileMonitorMutex.i
    Protected FilePathLower.s, *Entry.StruktureFileMonitor, *Entry1.StruktureFileMonitorThreads, Gefunden.b
    
    FilePathLower = LCase(GetPathPart(Filename))
    LockMutex(FileMonitorMutex)
    FileMonitorError = ""
    *Entry = AddElement(FileMonitorData())
    *Entry\CallbackRoutine = CallBackRoutine
    *Entry\FilenameLower = LCase(GetFilePart(Filename))
    *Entry\FilePosition = FileSize(Filename)
    If *Entry\FilePosition < 0 : *Entry\FilePosition = 0 : EndIf
    *Entry\FullFilename = Filename
    *Entry\PathLower = FilePathLower
    ; Look if we already have a thread for this directory
    Gefunden = #False
    ForEach FileMonitorThreads()
      If FileMonitorThreads()\WatchPathLower = FilePathLower
        Gefunden = #True
      EndIf
    Next
    If Not Gefunden
      *Entry1 = AddElement(FileMonitorThreads())
      *Entry1\WatchPathLower = FilePathLower
      *Entry1\ThreadNumber = CreateThread(@FileMonitorThread(), *Entry1)
    EndIf
    UnlockMutex(FileMonitorMutex)
  EndProcedure

EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 310
; FirstLine = 295
; Folding = ----
; EnableXP