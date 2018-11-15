; ---------------------------------------------------------------------------------------
;
; Procedures to read date from JPG and RAW files and Routine to manipulate Date in JPG 
;
; Author:  Heribert Füchtenhans
; Version: 1.0
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
  Declare.i GetJPGEXIFDate(Filenamepath.s)
  ; return 0 when error, otherwise the DateTime read from the file
  ; Further information on JPG files: https://de.wikipedia.org/wiki/JPEG_File_Interchange_Format and https://de.wikipedia.org/wiki/Tagged_Image_File_Format
  
  Declare.i GetRAWEXIFDate(Filenamepath.s, CameraModel.s)
  ; return 0 when error, otherwise the DateTime read from the file
  ; Further information on JPG files: https://de.wikipedia.org/wiki/JPEG_File_Interchange_Format and https://de.wikipedia.org/wiki/Tagged_Image_File_Format
  
  Declare   SetJPGEXIFDate(Filenamepath.s, DateTime.i)
 ; Return: 0 bei Fehler, sonst 1
  
  Declare.s GetLastImageErrorMessage()
EndDeclareModule



Module HF_Image
  
  EnableExplicit
  
  Define LastImageErrorMessage.s=""
  
  
  ;---------- internal routines
  
  ; Returns Bytes read or Zero
  Procedure.i Read81920BytesFromFile(Filenamepath.s, *imageAdresse, Offset.i)
    Protected FileNo.i, BytesRead.i=0
    
    If Offset >= FileSize(Filenamepath) : ProcedureReturn 0 : EndIf
    FileNo = ReadFile(#PB_Any, Filenamepath)
    If Not FileNo : ProcedureReturn 0 : EndIf
    FileSeek(FileNo, Offset)
    BytesRead = ReadData(FileNo, *imageAdresse, 81920)
    CloseFile(FileNo)
    ProcedureReturn BytesRead
  EndProcedure
  
  
  Procedure.w xchEndianW(e.w)
    ProcedureReturn (e & $FF) << 8 + (e >> 8) & $FF
  EndProcedure
  
  
  Procedure xchEndianL(e.l)
    ProcedureReturn (e & $FF) << 24 + (e & $FF00) << 8 + (e >> 8) & $FF00 + (e >> 24) & $FF
  EndProcedure
  
  
  ; returns last error message text
  Procedure.s GetLastImageErrorMessage()
    Shared LastImageErrorMessage.s
    
    ProcedureReturn LastImageErrorMessage
  EndProcedure
  
  
  Procedure.i GetJPGEXIFDate(Filenamepath.s)
    Shared LastImageErrorMessage.s
    Protected FileNo.i, i.i, Datum.i
    Protected OffsetField.l
    Protected Header.b, wordOrder.l, tifFormat.l, ifd1.l, nFields.l, currentTag.c
    Protected fieldLength.l, fieldValue.l
    Static *imageAdress = #Null
    
    LastImageErrorMessage = ""
    ; reserve memory on first usage
    If *imageAdress = #Null
      *imageAdress = AllocateMemory(81920)
    EndIf                           
    
    If Read81920BytesFromFile(Filenamepath, *imageAdress, 0) = 0
      LastImageErrorMessage = "Kann Datei nicht öffnen"  ; "Can't open file"
      ProcedureReturn 0
    EndIf
    
    ; SOIAmarker check
    If PeekW(*imageAdress) & $FFFF <> $D8FF
      LastImageErrorMessage = "Datei ist keine JPG Datei"   ; "File is Not a JPG file"
      ProcedureReturn 0
    EndIf
    ; get header length
    OffsetField.l = *imageAdress + 3
    Header = 30
    If PeekB(*imageAdress + 3) & $FF = $E1 : Header = 12 : EndIf 
    OffsetField = *imageAdress + Header
    ; get WordOrder, may be II ($4949) or MM ($4D4D)
    wordOrder = PeekW(OffsetField) & $FFFF
    If wordOrder <> $4949 And wordOrder <> $4D4D
      LastImageErrorMessage = "Word Order ist nicht II oder MM"   ; "Word order is Not II Or MM"
      ProcedureReturn 0
    EndIf
    OffsetField + 2
    ; get TIFF format, must be $2A
    tifFormat = PeekW(OffsetField) : If wordOrder <> $4949 : tifFormat = xchEndianW(tifFormat) : EndIf
    If tifFormat <> $2A
      LastImageErrorMessage = "Das TIFF format ist nicht $2A"           ; "The TIFF format is Not $2A"
      ProcedureReturn 0
    EndIf
    OffsetField + 2
    ; get the IDF Tag
    ifd1 = PeekL(OffsetField) : If wordOrder <> $4949 : ifd1 = xchEndianL(ifd1) : EndIf
    While ifd1 <> 0
      OffsetField = *imageAdress + ifd1 + Header
      ifd1 = 0
      ; get the amount of fields in this IDF
      nFields = PeekW(OffsetField) : If wordOrder <> $4949 : nFields = xchEndianW(nFields) : EndIf
      OffsetField + 2
      For i = 1 To nFields
        currentTag = PeekW(OffsetField) & $FFFF : If wordOrder <> $4949 : currentTag = xchEndianW(currentTag) : EndIf
        OffsetField + 2
        Select currentTag 
          Case $9003  ;  DateTime tag
            OffsetField + 2 ; Bytes 2-3 for fieldtype. Should alway be ASCII
            OffsetField + 4 ; Bytes 4-7 countain the field length
            ; Bytes 8-11 contain a pointer To ASCII Date/Time 
            fieldValue = PeekL(OffsetField) : If wordOrder <> $4949 : fieldValue = xchEndianL(fieldValue) : EndIf
            OffsetField = *imageAdress + fieldValue + Header  ; calculate Adresse of date Field
            Datum = ParseDate("%yyyy:%mm:%dd %hh:%ii:%ss", PeekS(OffsetField, 25, #PB_Ascii))
            ProcedureReturn Datum
          Case $8769
            OffsetField + 2 ; Bytes 2-3 for fieldtype. Should alway be Long ($4)
            OffsetField + 4 ; Bytes 4-7 countain the field length. Should allways be 1
            ifd1 = PeekL(OffsetField) : If wordOrder <> $4949 : ifd1 = xchEndianL(ifd1) : EndIf
        EndSelect 
        OffsetField +10 
      Next
    Wend
    LastImageErrorMessage = "Es wurde kein Erstelldatum in der Datei gefunden."   ; "No creation date was found in the file"
    ProcedureReturn 0
  EndProcedure
  
  
  ; For Nikon format see: http://lclevy.free.fr/nef/
  ; CameraModel can be (tested with pictures from those cameras):
  ;   Nikon
  ;   Olympus
  Procedure.i GetRAWEXIFDate(Filenamepath.s, CameraModel.s)
    Shared LastImageErrorMessage.s
    Protected FileNo.i, i.i, Datum.i
    Protected OffsetField.l
    Protected wordOrder.l, tifFormat.l, ifd1.l, nFields.l, currentTag.c
    Protected fieldLength.l, fieldValue.l, LowCameraModel.s
    Static *imageAdress = #Null
    
    LastImageErrorMessage = ""
    LowCameraModel = LCase(CameraModel)
    ; Allocate memory on first usage
    If *imageAdress = #Null
      *imageAdress = AllocateMemory(81920)
    EndIf                           
    
    If Read81920BytesFromFile(Filenamepath, *imageAdress, 0) = 0 : ProcedureReturn 0 : EndIf
    
    OffsetField = *imageAdress
    ; get WordOrder, may be II ($4949) or MM ($4D4D)
    wordOrder = PeekW(OffsetField) & $FFFF
    If wordOrder <> $4949 And wordOrder <> $4D4D
      LastImageErrorMessage = "Word Order ist nicht II oder MM"   ; "Word order is Not II Or MM"
      ProcedureReturn 0
    EndIf
    OffsetField + 2
    ; get TIFF format, must be $2A
    If LowCameraModel = "olympus"
      ; OffsetField + 2
    Else
      tifFormat = PeekW(OffsetField) : If wordOrder <> $4949 : tifFormat = xchEndianW(tifFormat) : EndIf
      If tifFormat <> $2A
        LastImageErrorMessage = "Das TIFF Format ist nicht $2A"           ; "The TIFF format is Not $2A"
        ProcedureReturn 0
      EndIf
    EndIf
    OffsetField + 2
    ; get IDF tag
    ifd1 = PeekL(OffsetField) : If wordOrder <> $4949 : ifd1 = xchEndianL(ifd1) : EndIf
    While ifd1 <> 0
      If ifd1 >= MemorySize(*imageAdress)
        If Read81920BytesFromFile(Filenamepath, *imageAdress, ifd1) = 0 : ProcedureReturn 0 : EndIf
        OffsetField = *imageAdress
      Else
        OffsetField = *imageAdress + ifd1
      EndIf
      ifd1 = 0
      ; get the amount of fields in this IDF
      nFields = PeekW(OffsetField) : If wordOrder <> $4949 : nFields = xchEndianW(nFields) : EndIf
      OffsetField + 2
      For i = 1 To nFields
        currentTag = PeekW(OffsetField) & $FFFF : If wordOrder <> $4949 : currentTag = xchEndianW(currentTag) : EndIf
        OffsetField + 2
        Select currentTag 
          Case $9003  ;  Datums Tags
            OffsetField + 2 ; Bytes 2-3 for fieldtype. Should alway be ASCII
            OffsetField + 4 ; Bytes 4-7 countain the field length
            ; Bytes 8-11 contain a pointer To ASCII Date/Time 
            fieldValue = PeekL(OffsetField) : If wordOrder <> $4949 : fieldValue = xchEndianL(fieldValue) : EndIf
            OffsetField = *imageAdress + fieldValue  ; calculate Adresse of date Field
            Datum = ParseDate("%yyyy:%mm:%dd %hh:%ii:%ss", PeekS(OffsetField, 255, #PB_Ascii))
            ProcedureReturn Datum
          Case $8769
            OffsetField + 2 ; Bytes 2-3 for fieldtype. Should alway be Long ($4)
            OffsetField + 4 ; Bytes 4-7 countain the field length. Should allways be 1
            ifd1 = PeekL(OffsetField) : If wordOrder <> $4949 : ifd1 = xchEndianL(ifd1) : EndIf
        EndSelect 
        OffsetField +10 
      Next
    Wend
    LastImageErrorMessage = "Es wurde kein Erstelldatum in der Datei gefunden."   ; "No creation date was found in the file"
    ProcedureReturn 0
  EndProcedure

  
  Procedure.i SetJPGEXIFDate(Filenamepath.s, Datum.i)
    Protected FileNo.i, DateString.s, i.i
    Protected OffsetField.l
    Protected Header.b, wordOrder.l, tifFormat.l, ifd1.l, nFields.l, currentTag.c
    Protected fieldLength.l, fieldValue.l
    Static *imageAdress = #Null
    
    ; Allocate memory on first usage
    If *imageAdress = #Null
      *imageAdress = AllocateMemory(81920)
    EndIf                           

    DateString = FormatDate("%yyyy:%mm:%dd %hh:%ii:%ss", Datum)
    
    ; Die ersten 81920 Bytes der Datei einlesen
    FileNo = ReadFile(#PB_Any, Filenamepath)
    If Not FileNo : ProcedureReturn 0 : EndIf
    ReadData(FileNo, *imageAdress, 81920)
    CloseFile(FileNo)
    
    OffsetField.l = *imageAdress +3
    Header = 30
    If PeekB(OffsetField) & $FF = $E1 : Header = 12 : EndIf 
    OffsetField = *imageAdress + Header
    wordOrder = PeekW(OffsetField)
    OffsetField + 2
    If wordOrder <> $4949 And wordOrder <> $4D4D
      ProcedureReturn 0
    EndIf
    tifFormat = PeekW(OffsetField) : If wordOrder <> $4949 : tifFormat = xchEndianW(tifFormat) : EndIf
    If tifFormat <> $2A
      ProcedureReturn 0
    EndIf
    OffsetField + 2
    ifd1 = PeekL(OffsetField) : If wordOrder <> $4949 : ifd1 = xchEndianL(ifd1) : EndIf
    While ifd1 <> 0
      OffsetField = *imageAdress + ifd1 + Header
      ifd1 = 0
      nFields = PeekW(OffsetField) : If wordOrder <> $4949 : nFields = xchEndianW(nFields) : EndIf
      OffsetField + 2
      For i = 1 To nFields
        currentTag = PeekW(OffsetField) : If wordOrder <> $4949 : currentTag = xchEndianW(currentTag) : EndIf
        Debug Str(i) + "  CurrentTag: 0x" + Hex(currentTag) + " Offset: " + Str(OffsetField) + " Type: " + Str(xchEndianW(PeekW(OffsetField+2))) + 
              " Length: " + Str(xchEndianL(PeekL(OffsetField+4))) +  " Offset: 0x" + Hex(xchEndianL(PeekL(OffsetField+8)+12))
        OffsetField + 2
        Select currentTag 
          Case $9003    ; Datums Tags
            OffsetField + 2 ; Bytes 2-3 for fieldtype. Should alway be ASCII
            OffsetField + 4 ; Bytes 4-7 countain the field length
            ; Bytes 8-11 contain a pointer To ASCII Date/Time 
            fieldValue = PeekL(OffsetField) : If wordOrder <> $4949 : fieldValue = xchEndianL(fieldValue) : EndIf
            OffsetField = *imageAdress + fieldValue + Header  ; calculate Adresse of date Field
            FileNo = OpenFile(#PB_Any, Filenamepath, #PB_Ascii)
            If Not FileNo
              ProcedureReturn 0
            EndIf
            FileSeek(FileNo, OffsetField - *imageAdress, #PB_Absolute)
            WriteString(FileNo, DateString, #PB_Ascii)
            WriteByte(FileNo, 0)
            CloseFile(FileNo)
            ProcedureReturn 1
          Case $8769
            OffsetField + 2 ; Bytes 2-3 for fieldtype. Should alway be Long ($4)
            OffsetField + 4 ; Bytes 4-7 countain the field length. Should allways be 1
            ifd1 = PeekL(OffsetField) : If wordOrder <> $4949 : ifd1 = xchEndianL(ifd1) : EndIf
        EndSelect 
        OffsetField +10 
      Next
    Wend
    ProcedureReturn 0
  EndProcedure

EndModule

; IDE Options = PureBasic 5.70 LTS beta 1 (Windows - x64)
; CursorPosition = 289
; FirstLine = 278
; Folding = --
; EnableXP