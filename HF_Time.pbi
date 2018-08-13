;   Description: Some spezial time functions
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


DeclareModule HF_Time
  Declare.i IsDayLightSavingTime()
  ; Windows only
  ; return 1: if not; 2 if we are in daylight saving time; -1 if system can't detect it
  
  Declare.i GetFileDateTZ(Filename.s, Datetype.i, UseUTC.b=#False)
  ; Windows only
  ; return the correct filetime even with daylight saving time
  ; Datetype, see PureBasic filetime constants, eg: #PB_Date_Created
  ; based on: http://www.purebasic.fr/english/viewtopic.php?f=5&t=57171
  ; returns: 0 when an error occured, otherwise the time
  
  Declare.i GetUTCTimeDiff()
  ; Windows only
  ; return the time difference in seconds between local and UTC time

  Declare.i GetUTCTime(time.i)
  ; Windows only
  ; return: time changed from local to UTC time
EndDeclareModule



Module HF_Time
  
  EnableExplicit

  ;---------- Special time functions
  ;
  ;  TZInfo.TIME_ZONE_INFORMATION
  ; Bias 
  ; (LONG) Current Bias relative To UCT 
  ; ! Bias is the number of minutes added To the local time To get GMT. 
  ; ! Therefore, If Bias is 360, this indicates that we are 6 hours 
  ; ! (360 minutes) _behind_ GMT (- 0600 GMT).  
  ; StandardName 
  ; (WCHAR 32]) Name of standard time zone in Unicode 
  ; StandardDate 
  ; (SYSTEMTIME) Date And time when standard time begins in UTC 
  ; StandardBias 
  ; (LONG) Offset from UCT of standard time 
  ; DaylightName 
  ; (WCHAR 32])Name of daylight saving time zone 
  ; DaylightDate 
  ; (SYSTEMTIME) Date And time when daylight saving time begins in UTC 
  ; DaylightBias 
  ; (LONG) Offset from UCT of daylight time 
  
  Procedure.i IsDayLightSavingTime()
    ; https://msdn.microsoft.com/de-de/library/windows/desktop/ms724421(v=vs.85).aspx
    Protected lpTimeZoneInformation.TIME_ZONE_INFORMATION

    Select GetTimeZoneInformation_(@lpTimeZoneInformation)
      Case 1 : ProcedureReturn 1    ; #False
      Case 2 : ProcedureReturn 2    ; #True
      Case 0 : ProcedureReturn -1
    EndSelect
  EndProcedure
  
  
  Procedure.i GetFileDateTZ(Filename.s, Datetype.i, UseUTC.b=#False)
    Protected FileHdl.i
    Protected Create.FILETIME, Access.FILETIME, Write.FILETIME
    Protected SystemTime.SYSTEMTIME, LocalTime.SYSTEMTIME

    FileHdl = ReadFile(#PB_Any, Filename)
    If FileHdl
      If Not GetFileTime_(FileID(FileHdl), @Create, @Access, @Write)
        Debug "GetFileDateTZ - GetFileTime Error!!"
        ProcedureReturn 0
      EndIf
      CloseFile(FileHdl)
      Select Datetype
        Case #PB_Date_Created
          If Not FileTimeToSystemTime_(@Create, @SystemTime)
            Debug "GetFileDateTZ - FileTimeToSystemTime Error!!"
        EndIf
        Case #PB_Date_Accessed
          If Not FileTimeToSystemTime_(@Access, @SystemTime)
            Debug "GetFileDateTZ - FileTimeToSystemTime Error!!"
        EndIf
        Case #PB_Date_Modified
          If Not FileTimeToSystemTime_(@Write, @SystemTime)
            Debug "GetFileDateTZ - FileTimeToSystemTime Error!!"
          EndIf
        Default
          Debug "GetFileDateTZ - Invalid Datetype >"+Str(Datetype)+"<"
          ProcedureReturn 0
      EndSelect

      If UseUTC
        LocalTime=SystemTime
      Else
        If Not SystemTimeToTzSpecificLocalTime_(#Null, @SystemTime, @LocalTime)
          Debug "GetFileDateTZ - SystemTimeToTzSpecificLocalTime Error!!"
          ProcedureReturn 0
        EndIf
      EndIf
      ProcedureReturn Date(LocalTime\wYear, LocalTime\wMonth, LocalTime\wDay, LocalTime\wHour, LocalTime\wMinute, LocalTime\wSecond)
    Else
      Debug "GetFileDateTZ - ReadFile Error!!"
      ProcedureReturn 0
    EndIf
  EndProcedure  
  
  
  
  
  Prototype Proto_TzSpecificLocalTimeToSystemTime(*p, *Localtime.SYSTEMTIME, *SystemTime.SYSTEMTIME)

  Procedure.i GetUTCTime(time.i)
    Protected LocalSystemTime.SYSTEMTIME, UTCSystemTime.SYSTEMTIME
    Protected UTCFileTime.FILETIME
    Protected qDate.q, dll_kernel32.i
    Static kernel.i = -1, TzSpecificLocalTimeToSystemTime.Proto_TzSpecificLocalTimeToSystemTime
    
    If kernel < 0
      kernel = OpenLibrary(#PB_Any, "Kernel32.dll")
      TzSpecificLocalTimeToSystemTime.Proto_TzSpecificLocalTimeToSystemTime = GetFunction(kernel, "TzSpecificLocalTimeToSystemTime")
    EndIf

    LocalSystemTime\wYear = Year(time)
    LocalSystemTime\wMonth = Month(time)
    LocalSystemTime\wDay = Day(time)
    LocalSystemTime\wHour = Hour(time)
    LocalSystemTime\wMinute = Minute(time)
    LocalSystemTime\wSecond = Second(time)
    LocalSystemTime\wMilliseconds = 0
    TzSpecificLocalTimeToSystemTime(#Null, LocalSystemTime, UTCSystemTime)
    SystemTimeToFileTime_(UTCSystemTime, UTCFileTime)
    
    qDate = (PeekQ(@UTCFileTime) - 116444736000000000) / 10000000
    ProcedureReturn qDate
  EndProcedure
  
  
  Procedure.i GetUTCTimeDiff()
    Protected UTCSystemTime.SYSTEMTIME
    Protected UTCFileTime.FILETIME
    Protected qDate.q, Diff.q
    
    GetSystemTime_(UTCSystemTime)
    SystemTimeToFileTime_(UTCSystemTime, UTCFileTime)
    
    qDate = (PeekQ(@UTCFileTime) - 116444736000000000) / 10000000
    Diff = qDate - Date()
    ProcedureReturn Diff
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 177
; FirstLine = 136
; Folding = --
; EnableXP