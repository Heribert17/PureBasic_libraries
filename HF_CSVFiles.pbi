; ---------------------------------------------------------------------------------------
;
; Modul to read CSV files
;
; Author:  Heribert Füchtenhans
; Version: 1.0
; OS:      Windows, Linux, Mac
;
; Requirements: HF_String.pbi
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


XIncludeFile "HF_String.pbi"



DeclareModule HF_CSVFiles
  ; Modul to read CSV files
  
  Declare.i ReadCSV(File.i, Filename.s, Flags.i, HeaderFields.s="", Separator.s="")
  ; Open csv file for reading
  ; Flags, see ReadFile function
  ; HeaderFields: String with semicolon (';') seaparted list with the Names of all Columns in the CSV File, or "" when the CSV's first line is the Headerline
  ; Separator: Field sparator, for example , or ; or chr(9) [Tab]. If empty the routine tries to guess it from the first line of the file.
  
  Declare.s GetSeparator(file.i)
  ; returns the actual separator or "" if file isn't opend
  
  Declare   GetHeaderlineFields(file.i, List fields.s())
  ; Returns in fields all column names either from ReadCSV or out of the CSV file
  
  Declare ReadLine(file.i, Map fields.s())
  ; Read on line of the CSV file
  ; fields is set to the values read from file, where the key of the map is the column name from Headerfields.
  ; If the line contains less values then headerlinefields, the remaining map entries for that fields are filled with an empty string
  ; The end of the file can be detected with the normal Eof() function
  
  Declare   CloseCSV(File.i)
  ; Closes the CSV file and frees used memory
  
EndDeclareModule




Module HF_CSVFiles
  
  EnableExplicit
  
  Structure structCSVFiles
    List Headerfields.s()
    Separator.s
  EndStructure
  
  Define NewMap CSVFiles.structCSVFiles()
  
  ;---------- Modul local routines ----------------------------------------------------------------
  
  ; Tries to determine the field separator
  Procedure.s guessSeparator(Line.s)
    Protected sep.s, commaCount.i=0, semicolonCount.i=0, tabCount.i=0
    
    commaCount = CountString(Line, ",")
    semicolonCount = CountString(Line, ";")
    tabCount = CountString(Line, Chr(9))
    If commaCount >= semicolonCount And commaCount >= tabCount
      sep = ","
    ElseIf semicolonCount >= commaCount And semicolonCount >= tabCount
      sep = ";"
    Else
      sep = Chr(9)
    EndIf
    ProcedureReturn sep
  EndProcedure
  
  
  Procedure splitCSVLine(List fields.s(), line.s, Separator.s)
    Protected part.s, field.s="", i.i
    
    ClearList(fields())
    For i=1 To CountString(Line, Separator) + 1
      part = StringField(Line, i, Separator)
      If field <> "" : field + Separator : EndIf
      field + part
      ; if field starts with " add parts until part with " at the end is found
      If Left(LTrim(field), 1) = ~"\""
        If Right(RTrim(ReplaceString(part, ~"\"\"", "")), 1) = ~"\""
          ; remove leading and tailing " from field
          field = Trim(field)
          field = Mid(field, 2, Len(field) - 2)
        Else
          ; get next token from line because no ending " is found
          Continue
        EndIf
      EndIf
      AddElement(fields()) : fields() = Trim(ReplaceString(field, ~"\"\"", ~"\""))
      field = ""
    Next i
    ; may be we got the last field without ending ", then we still have something in field
    If field <> ""
      ; remove leading " from field
      field = Trim(field)
      field = Mid(field, 2, Len(field) - 1)
      AddElement(fields()) : fields() = Trim(ReplaceString(field, ~"\"\"", ~"\""))
    EndIf
  EndProcedure
  
  
  
  
  ;---------- Public routines ---------------------------------------------------------------------

  Procedure.i ReadCSV(File.i, Filename.s, Flags.i, HeaderFields.s="", Separator.s="")
    Shared CSVFiles.structCSVFiles()
    Protected i.i, Line.s, Filepos.i
    
    ; Open file for reading
    i = ReadFile(File, Filename, Flags)
    If Not i
      ProcedureReturn 0
    ElseIf File = #PB_Any
      File = i
    EndIf
    ; get the headerfields from Parameter or from file
    If HeaderFields <> ""
      HF_String::splitString(CSVFiles(Str(File))\Headerfields(), HeaderFields, ";")
    Else
      ; Get Headerline from File
      Line = ReadString(File)
      ; If Separator is empty try to guess from line
      If Separator = ""
        Separator = guessSeparator(Line)
      EndIf
      splitCSVLine(CSVFiles(Str(File))\Headerfields(), Line, Separator)
    EndIf
    ; Try to get the separator if not given or already guessed
    If Separator = ""
      Filepos = Loc(File)
      line = ReadString(File)
      FileSeek(File, Filepos, #PB_Absolute)
      Separator = guessSeparator(Line)
    EndIf
    CSVFiles(Str(File))\Separator = Separator
    ProcedureReturn File
  EndProcedure
  
  
  Procedure.s GetSeparator(file.i)
    Shared CSVFiles.structCSVFiles()
    
    If FindMapElement(CSVFiles(), Str(file))
      ProcedureReturn CSVFiles()\Separator
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  
  
  Procedure GetHeaderlineFields(file.i, List fields.s())
    Shared CSVFiles.structCSVFiles()
    
    If FindMapElement(CSVFiles(), Str(file))
      CopyList(CSVFiles()\Headerfields(), fields())
    EndIf
  EndProcedure
  
  
  Procedure ReadLine(file.i, Map fields.s())
    Shared CSVFiles.structCSVFiles()
    Protected line.s, value.s, NewList linefields.s()
    
    ClearMap(fields())
    If FindMapElement(CSVFiles(), Str(file))
      ; read line and split it into elements
      line = ReadString(file)
      splitCSVLine(linefields(), Line, CSVFiles()\Separator)
      ; create map with Headerfields as key and read column as value. If line doesn't have a value (missing at end of line) set value to ""
      ResetList(linefields())
      ForEach CSVFiles()\Headerfields()
        If NextElement(linefields())
          value = linefields()
        Else
          value = ""
        EndIf
        fields(CSVFiles()\Headerfields()) = value
      Next
    EndIf
  EndProcedure
  
  
  ; Close the csv file
  Procedure CloseCSV(File.i)
    Shared CSVFiles.structCSVFiles()
    
    If FindMapElement(CSVFiles(), Str(file))
      CloseFile(File)
      DeleteMapElement(CSVFiles())
    EndIf
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 33
; FirstLine = 22
; Folding = --
; EnableXP