;   Description: Logging Funktionen for PureBasic
;            OS: Windows, Linux, Mac
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


DeclareModule HF_Logging
  
  Declare   PrintNC(Text.s)
  ; Print directly to the console (with newline). Use when you have to pipe the output
  
  Declare   PrintC(Text.s)
  ; Print directly to the console (without newline). Use when you have to pipe the output

  ; Logging
  Enumeration
    #DEBUG
    #INFO
    #WARNING
    #ERROR
  EndEnumeration
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
  
  Declare.i GetLoggerErrorCount()
  ; return the amount of Errormessages written with LogLevel #ERROR
  
  Declare   ResetLoggerErrorCount()
  ; Resets the LoggererrorCount and clears all cached log entries 
  
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
  Global LoggerLogLevel = #INFO, LoggerMaxFilesize.l = 10485760, LoggerMaxFilecount.l = 10, LoggerErrorCount.i=0
  Global NewList LoggingMessages.s()
  
  
  ;---------- output functions
  
  Procedure PrintNC(Text.s)
    Protected *MemoryID, MemorySize.i
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_MacOS
        #NewLine = #CR$
      CompilerCase #PB_OS_Linux
        #NewLine = #LF$
      CompilerDefault
        #NewLine = #CRLF$
    CompilerEndSelect

    *MemoryID = AllocateMemory(MemoryStringLength(@Text, #PB_Unicode) + 10)
    MemorySize = PokeS(*MemoryID, Text + #NewLine, -1, #PB_Ascii)
    WriteConsoleData(*MemoryID, MemorySize)
    FreeMemory(*MemoryID)
  EndProcedure
    
  
  Procedure PrintC(Text.s)
    Protected *MemoryID, MemorySize.i
    
    *MemoryID = AllocateMemory(MemoryStringLength(@Text, #PB_Unicode) + 10)
    MemorySize = PokeS(*MemoryID, Text, -1, #PB_Ascii)
    WriteConsoleData(*MemoryID, MemorySize)
    FreeMemory(*MemoryID)
  EndProcedure
  
  
  
  ;---------- Logging functions

  
  ; initialise Logger
  Procedure OpenLogger(Filename.s, ToConsole.b=#True, ToMemory.b=#False, Loglevel.b=#INFO, MaxFilesize.i=10, MaxFilecount.i=10)
    Shared LoggingMessages.s(), LoggerFilehandle.i
    Shared LoggerFilename.s, LoggerFilehandle.i, LoggerToConsole.b, LoggerToMemory.b
    Shared LoggerLogLevel.i, LoggerMaxFilesize.l, LoggerMaxFilecount.l, LoggerErrorCount.i
    
    LoggerMaxFilesize = MaxFilesize * 1024 * 1024
    LoggerMaxFilecount = MaxFilecount
    LoggerFilename = Filename
    LoggerToConsole = ToConsole
    LoggerLogLevel = Loglevel
    If ToConsole : OpenConsole() : EndIf
    LoggerToMemory = ToMemory
    ClearList(LoggingMessages())
    LoggerErrorCount = 0
    LoggerFilehandle = OpenFile(#PB_Any, LoggerFilename, #PB_File_Append | #PB_File_SharedRead | #PB_File_NoBuffering)
    If Not LoggerFilehandle
      PrintNC("Logfile '" + LoggerFilename + "' can't be opend.")
    EndIf
  EndProcedure
  
  
  Procedure WriteLogger(Text.s, LogLevel.b=#INFO, LineLeadIn.b=#True)
    Shared LoggingMessages.s(), LoggerFilehandle.i
    Shared LoggerFilename.s, LoggerToConsole.b, LoggerToMemory.b
    Shared LoggerLogLevel.i, LoggerMaxFilesize.l, LoggerMaxFilecount.l, LoggerErrorCount.i
    Protected WriteText.b=#False, Filename.s, i.i, OutText.s, StrLoglevel.s = "DEBUG"
    Protected TextLine.s, LeadIn.s
    
    If Loglevel = #Debug And LoggerLogLevel = #DEBUG
      WriteText = #True
      StrLoglevel = "DEBUG"
    ElseIf LogLevel = #INFO And (LoggerLogLevel = #INFO Or LoggerLogLevel = #DEBUG)
      WriteText = #True
      StrLoglevel = "INFO"
    ElseIf LogLevel = #WARNING And LoggerLogLevel <> #ERROR
      WriteText = #True
      StrLoglevel = "WARNING"
    ElseIf LogLevel = #Error
      WriteText = #True
      StrLoglevel = "ERROR"
      LoggerErrorCount + 1
    EndIf
    If WriteText
      ; Get filesize of Logfile and switch logfile if neccessary
      If Not LoggerFilehandle Or Lof(LoggerFilehandle) > LoggerMaxFilesize
        If LoggerFilehandle : CloseFile(LoggerFilehandle) : EndIf
        Filename = LoggerFilename + "." + Str(LoggerMaxFilecount)
        DeleteFile(Filename)
        For i = LoggerMaxFilecount-1 To 0 Step -1
          Filename = LoggerFilename + "." + Str(i)
          RenameFile(Filename, LoggerFilename + "." + Str(i+1))
        Next
        RenameFile(LoggerFilename, LoggerFilename + ".0")
        LoggerFilehandle = CreateFile(#PB_Any, LoggerFilename, #PB_File_SharedRead | #PB_File_SharedWrite | #PB_File_NoBuffering)
        If Not LoggerFilehandle
          PrintNC("Loggerdatei '" + LoggerFilename + "' konnte nicht geöffnet werden.")
        EndIf
      EndIf
      ; Calculate time. On Linux or Mac I don't know how to get the time with milliseconds
      LeadIn = ""
      If LineLeadIn
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          Protected Info.SYSTEMTIME
          GetLocalTime_(Info)
          LeadIn = LSet(StrLoglevel, 7) + " | "+ Str(Info\wYear) + "-" + RSet(Str(Info\wMonth), 2, "0") + "-" + RSet(Str(Info\wDay), 2, "0") + " " + 
                   RSet(Str(Info\wHour), 2, "0") + ":" + RSet(Str(Info\wMinute), 2, "0") + ":" + RSet(Str(Info\wSecond), 2, "0") + "," +
                   RSet(Str(Info\wMilliseconds), 3, "0") + " | "
        CompilerElse
          LeadIn = LSet(StrLoglevel, 7) + " | "+ FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss, Date()) + " | "
        CompilerEndIf
      EndIf
      ; normalise line endings for splitting
      Text = ReplaceString(Text, Chr(13), "")
      For i = 1 To  CountString(Text, Chr(10)) + 1
        TextLine = StringField(Text, i, Chr(10))
        OutText = LeadIn + TextLine
        If LoggerFilehandle : WriteStringN(LoggerFilehandle, OutText) : EndIf
        If LoggerToConsole : PrintNC(OutText) : EndIf
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
  
  
  Procedure.i GetLoggerErrorCount()
    Shared LoggerErrorCount.i  
    
    ProcedureReturn LoggerErrorCount
  EndProcedure
  
  
  Procedure ResetLoggerErrorCount()
    Shared LoggerErrorCount.i, LoggingMessages() 
    
    LoggerErrorCount = 0
    ClearList(LoggingMessages())
  EndProcedure

EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 250
; FirstLine = 208
; Folding = ---
; EnableXP