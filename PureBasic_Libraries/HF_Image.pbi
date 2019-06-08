; ---------------------------------------------------------------------------------------
;
; Procedures to read data from JPG and RAW files and Routine to manipulate Date in JPG 
; We use the well known exiftool from Phil Harvey (Thanks to him for this tool)
; The exiftool must be installed in a search path.
;
; Author:  Heribert Füchtenhans
; Version: 2.0
; OS:      Windows, Linux, Mac
;
; Requirements:
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


DeclareModule HF_Image
  Declare.b GetEXIFDateAllFiles(DirPath.s, List CreateDateList.s())
  ; Return #True when OK, else #False
  ; returns in CreateDateList a list with all Image files and their CreationDate in the form
  ; "Filename\tFiledate" where Filedate is a PureBasic Date as string
  
  Declare.i GetEXIFDate(Filenamepath.s)
  ; return 0 when error, otherwise the DateTime read from the file
  ; Further information on JPG files: https://de.wikipedia.org/wiki/JPEG_File_Interchange_Format and https://de.wikipedia.org/wiki/Tagged_Image_File_Format
  
  Declare.b SetEXIFDate(Filenamepath.s, DateTime.i)
  ; Return: #False on error, otherwise #True
  
  Declare.s GetLastImageErrorMessage()
EndDeclareModule



Module HF_Image
  
  EnableExplicit
  
  Define LastImageErrorMessage.s=""
  
  
  ;---------- internal routines
  
  Procedure.b ReadWriteExifData(Filename.s, List Output.s(), Option.s="")
    Shared  LastImageErrorMessage.s
    Protected result.i, Error.s="", PathVar.s, Index.i, Path.s
    Static ExifToolsPrg.s=""
    
    ClearList(Output())
    ; Find location of exiftool.exe
    If ExifToolsPrg = ""
      PathVar = GetEnvironmentVariable("PATH")
      PathVar = ".\;" + PathVar + ";"
      For Index = 1 To CountString(PathVar, ";")
        Path = StringField(PathVar, Index, ";")
        If Right(Path, 1) <> "\" : Path + "\" : EndIf
        If FileSize(Path + "exiftool.exe") > 0
          ExifToolsPrg = Path + "exiftool.exe"
          Break
        EndIf
      Next Index
    EndIf
    ; Start exiftools when found
    If ExifToolsPrg <> ""
      If Right(Filename, 1) = "\" Or Right(Filename, 1) = "/" : Filename = Mid(Filename, 1, Len(Filename)-1) : EndIf
      result = RunProgram(~"\"" + ExifToolsPrg  + ~"\"", ~"\"" + Filename + ~"\" -fast -charset FileName=Latin " + Option, "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Error | #PB_Program_Hide)
      If result
        While ProgramRunning(result)
          If AvailableProgramOutput(result)
            AddElement(Output()) : Output() = ReadProgramString(result)
          Else
            Delay(50)
          EndIf
          Error + ReadProgramError(result)
          If Error <> ""
            LastImageErrorMessage = Error
            ProcedureReturn #False
          EndIf
        Wend 
        CloseProgram(result) ; Close the connection to the program
      Else
        Error = "Couldn't start " + ExifToolsPrg
      EndIf
    Else
      Error = "Exiftools.exe not found on search path or in local directory."
    EndIf
    If Error <> ""
      LastImageErrorMessage = Error
      ProcedureReturn #False
    EndIf
    ProcedureReturn #True
  EndProcedure
  
  
  ;---------- External routines
  
  ; returns last error message text
  Procedure.s GetLastImageErrorMessage()
    Shared LastImageErrorMessage.s
    
    ProcedureReturn LastImageErrorMessage
  EndProcedure
  
  
  Procedure.b GetEXIFDateAllFiles(DirPath.s, List CreateDateList.s())
    Protected NewList Output.s(), filename.s, temp.s, Time.i
    
    ClearList(CreateDateList())
    ; Start exif to get the Creation Date
    If ReadWriteExifData(DirPath, Output(), "-Time:ALL")
      Time = -1
      filename = ""
      ForEach Output()
        If Left(Output(), 2) = "=="
          If filename <> ""     ; No CreateDate entry for this filename found, add emtry entry
            AddElement(CreateDateList()) : CreateDateList() = filename + ~"\t-1"
          EndIf
          filename = Mid(Output(), 10)
          filename = ReplaceString(filename, "/", "\")
        ElseIf filename <> "" And (Left(Output(), 6) = "Create" Or Left(Output(), 18) = "Date/Time Original")
          Temp = Trim(StringField(Output(), 2, "  :"))
          ; Time format is 2018:08:19 13:41:32
          Time = ParseDate("%yyyy:%mm:%dd %hh:%ii:%ss", Temp)
          AddElement(CreateDateList()) : CreateDateList() = filename + ~"\t" + Str(Time)
          filename = ""
        EndIf
      Next
      If filename <> ""     ; No CreateDate entry for this filename found, add emtry entry
        AddElement(CreateDateList()) : CreateDateList() = filename + ~"\t-1"
      EndIf
    Else
      ProcedureReturn #False
    EndIf
    ProcedureReturn #True
  EndProcedure
  
  
  Procedure.i GetEXIFDate(Filenamepath.s)
    Protected NewList Output.s(), Time.i, Temp.s
    
    ; Start exif to get the Creation Date
    If ReadWriteExifData(Filenamepath, Output(), "-CreateDate")
      FirstElement(Output())
      Temp = Trim(StringField(Output(), 2, "  :"))
      ; Time format is 2018:08:19 13:41:32
      Time = ParseDate("%yyyy:%mm:%dd %hh:%ii:%ss", Temp)
      ProcedureReturn Time
    EndIf
    ProcedureReturn 0
  EndProcedure
  
  
  Procedure.b SetEXIFDate(Filenamepath.s, DateTime.i)
    Protected NewList Output.s(), TimeString.s
    
    TimeString = FormatDate("%yyyy:%mm:%dd %hh:%ii:%ss", DateTime)
    ; Start exif to set the Creation Date
    If ReadWriteExifData(Filenamepath, Output(), ~"-CreateDate=\"" + TimeString + ~"\"")
      ; remove _original file
      DeleteFile(Filenamepath + "_original")
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

EndModule

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 86
; FirstLine = 66
; Folding = --
; EnableXP
; CompileSourceDirectory