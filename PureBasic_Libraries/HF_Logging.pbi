; ---------------------------------------------------------------------------------------
;
; Logging Funktionen for PureBasic
;
; Author:  Heribert Füchtenhans
; Version: 2020.02.04
; OS:      Windows, Linux, Mac
;
; Requirements:
; Changes:
;   Field separator changed from " | " to chr(9) [Tab]. This makes it easier to import
;   Log file into Excel.
;   Version 3.3
;     ClearSavedLogger implemented
;   Version 2020.02.04
;     Also delete files wenn max logging files is reduced
;
; ---------------------------------------------------------------------------------------
;
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
; ---------------------------------------------------------------------------------------


DeclareModule HF_Logging
  
  ; Logging
  Enumeration
    #DEBUG
    #INFO
    #WARNING
    #ERROR
  EndEnumeration
  
  ; Windows Eventlog
;   Enumeration
;     #EVENTLOG_SUCCESS = 0
;     #EVENTLOG_ERROR_TYPE = 1
;     #EVENTLOG_INFORMATION_TYPE = 4
;     #EVENTLOG_WARNING_TYPE = 2
;   EndEnumeration
    #EVENTLOG_SUCCESS = "SUCCESS"
    #EVENTLOG_ERROR_TYPE = "ERROR"
    #EVENTLOG_INFORMATION_TYPE = "INFORMATION"
    #EVENTLOG_WARNING_TYPE = "WARNING"
    

  Declare   OpenLogger(Filename.s, ToConsole.b=#True, ToMemory.b=#False, Loglevel.b=#INFO, MaxFilesize.i=10, MaxFilecount.i=10)
  ; Initialise the logger
  ; ToConsole: if #True output is sent to file and to console
  ; ToMemory:  if #True output is saved in memeory an can be retrieved with GetSavedLogger
  ; LogLevel: one of the loglevels in Enumeration.
  ; MaxFilesize: maximum size of a LogFile in MB
  ; MaxFilecount: Number of Logfiles to keep. Files are renamned with .1, .2, etc
  
  Declare   CloseLogger()
  ; Close the Logger and free used resources
  
  Declare   WriteLogger(Text.s, LogLevel.b=#INFO, LineLeadIn.b=#True)
  ; Write Text to logfile
  ; Loglevel: if the loglevel here is below the loglevel defined in OpenLogger, the output is discarded. For example if OpenLogger is called
  ;           with #INFO and WriteLogger ist called with #DEBUG the output is not stored
  ; LineLeadIn: if #False the starting information of a line (Logleve, Date/Time) is supressed
  
  Declare   SetLevelLogger(Loglevel.i=#INFO)
  ; Changes the LogLevel set bey OpenLogger to a new level
  
  Declare   GetSavedLogger(List Textlines.s())
  ; Stores in Textlines() all catched log entries or an empty list if ToMemory wasn't set in OpenLogger
  
  Declare   ClearSavedLogger()
  ; Clears all saved Logging entries
  
  Declare.i GetLoggerErrorCount()
  ; return the amount of Errormessages written with LogLevel #ERROR
  
  Declare   ResetLoggerErrorCount()
  ; Resets the LoggererrorCount and clears all cached log entries 
  
  Declare.b WriteWindowsEventlog(Event_App.s, EventMessage.s, EventId.i, EventTyp.s, Verbose.b=#False)
    
EndDeclareModule



Module HF_Logging
  
  EnableExplicit
  
  Enumeration
    #DEBUG
    #INFO
    #WARNING
    #ERROR
  EndEnumeration
  
  
  Global LoggerFilename.s = "logger.log", LoggerFilehandle.i=0, LoggerToConsole.b = #True, LoggerToMemory.b = #False
  Global LoggerLogLevel = #INFO, LoggerMaxFilesize.i=10485760, LoggerMaxFilecount.i=10, LoggerErrorCount.i=0
  Global NewList LoggingMessages.s()
  
  
  
  ;---------- Internal procedures
  
  Procedure RenameLoggerfile()
    Shared LoggerFilename.s, LoggerFilehandle.i, LoggerMaxFilesize.i, LoggerMaxFilecount.i
    Protected i.i, Length.i, Filename.s, NewFilename.s, ErrorByRename.b=#False

    ; Get filesize of Logfile and switch logfile if neccessary
    If LoggerFilehandle
      length = Lof(LoggerFilehandle)
    Else
      Length = FileSize(LoggerFilename)
    EndIf
    If Length > LoggerMaxFilesize
      ; Delete all files with numbers greater then LoggerMaxFilecount. If LoggerMaxFileCount had been
      ; reduced, we have to delete more then only the last file. So we stop deleting on the first file
      ; not found
      i = LoggerMaxFilecount
      While #True
        Filename = LoggerFilename + "." + Str(i)
        If FileSize(Filename) < 0
          Break
        EndIf
        DeleteFile(Filename)
        i + 1
      Wend
      ; Rename all remaining files
      For i = LoggerMaxFilecount-1 To 0 Step -1
        Filename = LoggerFilename + "." + Str(i)
        If FileSize(Filename) >= 0
          NewFilename = LoggerFilename + "." + Str(i+1)
          If RenameFile(Filename, NewFilename) = 0
            WriteLogger("Fehler beim umbennen von " + Filename + " in " + NewFilename, #ERROR)
            ErrorByRename = #True
            Break
          EndIf
        EndIf
      Next
      If Not ErrorByRename
        If LoggerFilehandle : CloseFile(LoggerFilehandle) : EndIf
        If RenameFile(LoggerFilename, LoggerFilename + ".0") <> 0
          LoggerFilehandle = CreateFile(#PB_Any, LoggerFilename, #PB_File_SharedRead | #PB_File_SharedWrite | #PB_File_NoBuffering)
        Else
          LoggerFilehandle = OpenFile(#PB_Any, LoggerFilename, #PB_File_Append | #PB_File_SharedRead | #PB_File_SharedWrite | #PB_File_NoBuffering)
        EndIf
        If Not LoggerFilehandle
          PrintN("Loggerdatei '" + LoggerFilename + "' konnte nicht geöffnet werden.")
        EndIf
      EndIf
    EndIf
  EndProcedure
  
  
  ;---------- Logging functions

  
  ; initialise Logger
  Procedure OpenLogger(Filename.s, ToConsole.b=#True, ToMemory.b=#False, Loglevel.b=#INFO, MaxFilesize.i=10, MaxFilecount.i=10)
    Shared LoggingMessages.s(), LoggerFilehandle.i
    Shared LoggerFilename.s, LoggerFilehandle.i, LoggerToConsole.b, LoggerToMemory.b
    Shared LoggerLogLevel.i, LoggerMaxFilesize.i, LoggerMaxFilecount.i, LoggerErrorCount.i
    
    LoggerMaxFilesize = MaxFilesize * 1024 * 1024
    LoggerMaxFilecount = MaxFilecount
    LoggerFilename = Filename
    LoggerToConsole = ToConsole
    LoggerLogLevel = Loglevel
    If ToConsole : OpenConsole() : EndIf
    LoggerToMemory = ToMemory
    ClearList(LoggingMessages())
    LoggerErrorCount = 0
    LoggerFilehandle = OpenFile(#PB_Any, LoggerFilename, #PB_File_Append | #PB_File_SharedRead | #PB_File_SharedWrite | #PB_File_NoBuffering)
    If Not LoggerFilehandle
      PrintN("Logfile '" + LoggerFilename + "' can't be opend.")
    EndIf
  EndProcedure
  
  
  Procedure WriteLogger(Text.s, LogLevel.b=#INFO, LineLeadIn.b=#True)
    Shared LoggingMessages.s(), LoggerFilehandle.i
    Shared LoggerToConsole.b, LoggerToMemory.b
    Shared LoggerLogLevel.i, LoggerErrorCount.i
    Protected WriteText.b=#False, i.i, OutText.s, StrLoglevel.s = "DEBUG"
    Protected TextLine.s, LeadIn.s
    
    If Loglevel = #Debug And LoggerLogLevel = #DEBUG
      WriteText = #True
      StrLoglevel = "DEBUG"
    ElseIf LogLevel = #INFO And (LoggerLogLevel = #INFO Or LoggerLogLevel = #DEBUG)
      WriteText = #True
      StrLoglevel = "INFO"
    ElseIf LogLevel = #WARNING And LoggerLogLevel <> #ERROR
      WriteText = #True
      StrLoglevel = "WARN"
    ElseIf LogLevel = #Error
      WriteText = #True
      StrLoglevel = "ERROR"
      LoggerErrorCount + 1
    EndIf
    If WriteText
      ; Get filesize of Logfile and switch logfile if neccessary
      RenameLoggerfile()
      LeadIn = ""
      If LineLeadIn
        LeadIn = StrLoglevel + Chr(9)+ FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss", Date()) + Chr(9)
      EndIf
      ; normalise line endings for splitting
      Text = ReplaceString(Text, Chr(13), "")
      For i = 1 To  CountString(Text, Chr(10)) + 1
        TextLine = StringField(Text, i, Chr(10))
        OutText = LeadIn + TextLine
        If LoggerFilehandle : WriteStringN(LoggerFilehandle, OutText) : EndIf
        If LoggerToConsole : PrintN(OutText) : EndIf
        If LoggerToMemory : AddElement(LoggingMessages()) : LoggingMessages() = OutText : EndIf
      Next
    EndIf
  EndProcedure
  
  
  Procedure CloseLogger()
    Shared LoggingMessages.s(), LoggerFilehandle.i
    
    CloseFile(LoggerFilehandle)
    ClearList(LoggingMessages())
  EndProcedure
  
  
  Procedure SetLevelLogger(Loglevel=#INFO)
    Shared LoggerLogLevel.i
    
    LoggerLogLevel = Loglevel
  EndProcedure
  
  
  Procedure GetSavedLogger(List TextLines.s())
    Shared LoggingMessages.s()
    
    CopyList(LoggingMessages(), TextLines())
  EndProcedure
  
  
  Procedure ClearSavedLogger()
    Shared LoggingMessages.s()
    
    ClearList(LoggingMessages())
  EndProcedure
  
  
  Procedure.i GetLoggerErrorCount()
    Shared LoggerErrorCount.i  
    
    ProcedureReturn LoggerErrorCount
  EndProcedure
  
  
  Procedure ResetLoggerErrorCount()
    Shared LoggerErrorCount.i, LoggingMessages() 
    
    LoggerErrorCount = 0
    ClearList(LoggingMessages())
  EndProcedure
  
  
  Procedure.b WriteWindowsEventlog(Event_App.s, EventMessage.s, EventId.i, EventTyp.s, Verbose.b=#False)
    ; Write EventMessage with EventType and EventID to Windows Eventldog
    ; The EventId must be in the range 1 to 999
    Protected command.s, prgid.i, Result.i=#False, Options.i
    
    ; prevent EventId from beeing greater as 999 and EventMessage from beeing greater then 32.000 chars
    EventId = EventId % 1000
    EventMessage = Left(EventMessage, 32000)
    command = "/t " + EventTyp + " /id " + Str(EventId) + ~" /l APPLICATION /so \"" + Event_App + ~"\" /d \"" + EventMessage + ~"\""
    ; if Verbose=#False hide programm output
    Options = #PB_Program_Open | #PB_Program_Wait
    If Not Verbose
      Options = Options | #PB_Program_Hide
    Else
      PrintN("")
      PrintN("EventCreate Parameter: " + command)
    EndIf
    prgid = RunProgram("eventcreate.exe", command, ".", Options)
    If prgid
      If ProgramExitCode(prgid) = 0
        result = #True
      EndIf
    CloseProgram(prgid) ; Close the connection to the program
    EndIf
    ProcedureReturn Result
  EndProcedure
    
EndModule

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 15
; Folding = ---
; EnableXP
; CompileSourceDirectory