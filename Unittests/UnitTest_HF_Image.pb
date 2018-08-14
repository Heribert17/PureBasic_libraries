; ---------------------------------------------------------------------------------------
;
; Test procedures for HF_Image
;
; Author:  Heribert Füchtenhans
; Version: 1.0
; OS:      Windows, Linux, Mac
;
; Requirements: HF_Image.pbi
;               Needs pictures in .\Image directory
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


IncludeFile "..\HF_Image.pbi"

Define Count.i=0, Datum.i, CurDir.s


Macro Assert(Expression, Meldung)
  Count + 1
  If Not (Expression)
    PrintN("Assert (Line " + #PB_Compiler_Line + "): " + Meldung)
    PrintN("Continue with return ...")
    Input()
    End
  EndIf
EndMacro

; Hilfsroutinen
Procedure before()
EndProcedure

Procedure after()
EndProcedure



OpenConsole()
PrintN("Start Tests JPG")
CurDir = GetCurrentDirectory()


before()
Datum = HF_Image::GetJPGEXIFDate(CurDir + "\Test-Pictures\JPG-Olympus Kamera\P6160003.JPG")
Assert(FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Datum) = "16.06.2018 11:50:46", "Datum des Fotos stimmt nicht überein. Ist = " + 
                                                                               FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Datum) + " " +
                                                                               HF_Image::GetLastImageErrorMessage())
after()

before()
Datum = HF_Image::GetJPGEXIFDate(CurDir + "\Test-Pictures\JPG-Olympus Kamera\P6160006.JPG")
Assert(FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Datum) = "16.06.2018 11:54:20", "Datum des Fotos stimmt nicht überein. Ist = " + 
                                                                               FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Datum) + " " +
                                                                               HF_Image::GetLastImageErrorMessage())
after()

before()
Datum = HF_Image::GetJPGEXIFDate(CurDir + "\Test-Pictures\JPG-Smartphone\20180523_160544.jpg")
Assert(FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Datum) = "23.05.2018 16:05:44", "Datum des Fotos stimmt nicht überein. Ist = " + 
                                                                               FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Datum) + " " +
                                                                               HF_Image::GetLastImageErrorMessage())
after()

; PrintN("Start Tests Nikon")
; 
; before()
; Datum = HF_Image::GetRAWEXIFDate(CurDir + "\Test-Pictures\RAW-Nikon-F8000\DSCN0782.NRW", "Nikon")
; Assert(FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Datum) = "11.06.2018 18:21:48", "Datum des Fotos stimmt nicht überein. Ist = " + 
;                                                                                FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Datum) + " " +
;                                                                                HF_Image::GetLastImageErrorMessage())
after()
PrintN("Starte Test Olympus")

before()
Datum = HF_Image::GetRAWEXIFDate(CurDir + "\Test-Pictures\RAW-Olympus\P5260001.ORF", "Olympus")
Assert(FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Datum) = "26.05.2018 08:28:19", "Datum des Fotos stimmt nicht überein. Ist = " + 
                                                                               FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", Datum) + " " +
                                                                               HF_Image::GetLastImageErrorMessage())
after()

PrintN("End " + Str(Count) + " tests, continue with return ...")
Input()
CloseConsole()

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 92
; FirstLine = 64
; Folding = -
; EnableXP