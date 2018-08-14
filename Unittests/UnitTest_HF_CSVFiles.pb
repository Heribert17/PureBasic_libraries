; ---------------------------------------------------------------------------------------
;
; Test procedures for HF_CSVFiles
;
; Author:  Heribert Füchtenhans
; Version: 1.0
; OS:      Windows, Linux, Mac
;
; Requirements: HF_CSVFiles.pbi
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


EnableExplicit

XIncludeFile "..\HF_CSVFiles.pbi"

#CVSFILENAME = ".\test\Test.cvs"

Define Count = 0
NewList fields.s()
NewMap linefields.s()



;---------- Helping routines ----------------------------------------------------------------------

Macro Assert(Expression, Meldung)
  Count + 1
  If Not (Expression)
    PrintN("Assert (Line " + #PB_Compiler_Line + "): " + Meldung)
    PrintN("Continue with Return ...")
    Input()
    End
  EndIf
EndMacro

Procedure before(Format.i)
  Protected FileID.i
  
  ; Create CSV File
  CreateDirectory(".\Test")
  FileID = CreateFile(#PB_Any, #CVSFILENAME)
  Select Format
    Case 1
      WriteStringN(FileID, ~"Col 1\tCol 2\tCol 3")
      WriteStringN(FileID, ~"one\ttwo\tthree")
    Case 2
      WriteStringN(FileID, ~"one\ttwo\tthree")
      WriteStringN(FileID, ~"eleven\ttwelve\tthirteen")
    Case 3
      WriteStringN(FileID, ~"\"Col 1\",  \"Col 2,t\", \"Col 3,\"   ,   \"Col 4\"\"\"")
      WriteStringN(FileID, ~"one\ttwo\tthree")
    Case 4
      WriteStringN(FileID, ~"\"Col 1\"\".\",  \"Col 2,t\"\"\"\"\", \"Col 3,\"   ,   \"Col 4\"\"\"")
      WriteStringN(FileID, ~"one\ttwo\tthree")
    Case 5
      WriteStringN(FileID, ~"Col 1\tCol 2\tCol 3")
      WriteStringN(FileID, ~"one\ttwo\tthree")
      WriteStringN(FileID, ~"eleven\ttwelve\tthirteen")
    Default
      PrintN("Undefined File Format in procedure before: " + Str(Format))
  EndSelect
  CloseFile(FileID)    
EndProcedure

Procedure after()
  DeleteDirectory(".\Test", "", #PB_FileSystem_Recursive)
EndProcedure


;----------- Testing part -------------------------------------------------------------------------

OpenConsole()
PrintN("Start Tests")

before(1)
Assert(HF_CSVFiles::ReadCSV(10, #CVSFILENAME, 0, "", Chr(9)) = 10, "CSV File can't be opend")
HF_CSVFiles::CloseFile(10)
after()

before(1)
Assert(HF_CSVFiles::ReadCSV(10, #CVSFILENAME, 0, "", Chr(9)) = 10, "CSV File can't be opend")
Assert(HF_CSVFiles::GetSeparator(10) = Chr(9), "Separator ist nicht \t")
HF_CSVFiles::GetHeaderlineFields(10, fields())
SelectElement(fields(), 0) : assert(fields() = "Col 1", "Wrong headerline field returned should be 'Col 1' but is " + fields())
SelectElement(fields(), 1) : assert(fields() = "Col 2", "Wrong headerline field returned should be 'Col 2' but is " + fields())
SelectElement(fields(), 2) : assert(fields() = "Col 3", "Wrong headerline field returned should be 'Col 3' but is " + fields())
HF_CSVFiles::CloseFile(10)
after()

before(2)
Assert(HF_CSVFiles::ReadCSV(10, #CVSFILENAME, 0, "Col 1; Col 2; Col 3", Chr(9)) = 10, "CSV File can't be opend")
Assert(HF_CSVFiles::GetSeparator(10) = Chr(9), "Separator ist nicht \t")
HF_CSVFiles::GetHeaderlineFields(10, fields())
SelectElement(fields(), 0) : assert(fields() = "Col 1", "Wrong headerline field returned should be 'Col 1' but is " + fields())
SelectElement(fields(), 1) : assert(fields() = "Col 2", "Wrong headerline field returned should be 'Col 2' but is " + fields())
SelectElement(fields(), 2) : assert(fields() = "Col 3", "Wrong headerline field returned should be 'Col 3' but is " + fields())
HF_CSVFiles::CloseFile(10)
after()

before(1)
Assert(HF_CSVFiles::ReadCSV(10, #CVSFILENAME, 0, "", "") = 10, "CSV File can't be opend")
Assert(HF_CSVFiles::GetSeparator(10) = Chr(9), "Separator ist nicht \t")
HF_CSVFiles::GetHeaderlineFields(10, fields())
SelectElement(fields(), 0) : assert(fields() = "Col 1", "Wrong headerline field returned should be 'Col 1' but is " + fields())
SelectElement(fields(), 1) : assert(fields() = "Col 2", "Wrong headerline field returned should be 'Col 2' but is " + fields())
SelectElement(fields(), 2) : assert(fields() = "Col 3", "Wrong headerline field returned should be 'Col 3' but is " + fields())
HF_CSVFiles::CloseFile(10)
after()

before(3)
Assert(HF_CSVFiles::ReadCSV(10, #CVSFILENAME, 0, "", "") = 10, "CSV File can't be opend")
Assert(HF_CSVFiles::GetSeparator(10) = ",", "Separator ist nicht ,")
HF_CSVFiles::GetHeaderlineFields(10, fields())
SelectElement(fields(), 0) : assert(fields() = "Col 1", "Wrong headerline field returned should be 'Col 1' but is " + fields())
SelectElement(fields(), 1) : assert(fields() = "Col 2,t", "Wrong headerline field returned should be 'Col 2,t' but is " + fields())
SelectElement(fields(), 2) : assert(fields() = "Col 3,", "Wrong headerline field returned should be 'Col 3,' but is " + fields())
SelectElement(fields(), 3) : assert(fields() = ~"Col 4\"", ~"Wrong headerline field returned should be 'Col 4\"' but is " + fields())
HF_CSVFiles::CloseFile(10)
after()

before(4)
Assert(HF_CSVFiles::ReadCSV(10, #CVSFILENAME, 0, "", "") = 10, "CSV File can't be opend")
Assert(HF_CSVFiles::GetSeparator(10) = ",", "Separator ist nicht ,")
HF_CSVFiles::GetHeaderlineFields(10, fields())
SelectElement(fields(), 0) : assert(fields() = ~"Col 1\".", ~"Wrong headerline field returned should be 'Col 1\".' but is " + fields())
SelectElement(fields(), 1) : assert(fields() = ~"Col 2,t\"\"", ~"Wrong headerline field returned should be 'Col 2,t\"\"' but is " + fields())
SelectElement(fields(), 2) : assert(fields() = "Col 3,", "Wrong headerline field returned should be 'Col 3,' but is " + fields())
SelectElement(fields(), 3) : assert(fields() = ~"Col 4\"", ~"Wrong headerline field returned should be 'Col 4\"' but is " + fields())
HF_CSVFiles::CloseFile(10)
after()


; Test line read

before(5)
Assert(HF_CSVFiles::ReadCSV(10, #CVSFILENAME, 0, "", Chr(9)) = 10, "CSV File can't be opend")
HF_CSVFiles::GetHeaderlineFields(10, fields())
HF_CSVFiles::ReadLine(10, linefields())
assert(linefields("Col 1") = "one", "Wrong value read, should be one but is " + linefields("Col 1"))
assert(linefields("Col 2") = "two", "Wrong value read, should be two but is " + linefields("Col 2"))
assert(linefields("Col 3") = "three", "Wrong value read, should be three but is " + linefields("Col 3"))
HF_CSVFiles::ReadLine(10, linefields())
assert(linefields("Col 1") = "eleven", "Wrong value Read, should be eleven but is " + linefields("Col 1"))
assert(linefields("Col 2") = "twelve", "Wrong value read, should be twelve but is " + linefields("Col 2"))
assert(linefields("Col 3") = "thirteen", "Wrong value read, should be thirteen but is " + linefields("Col 3"))
; Read past end of file
HF_CSVFiles::ReadLine(10, linefields())
assert(linefields("Col 1") = "", "Wrong value Read, should be empty but is " + linefields("Col 1"))
assert(linefields("Col 2") = "", "Wrong value read, should be empty but is " + linefields("Col 2"))
assert(linefields("Col 3") = "", "Wrong value read, should be empty but is " + linefields("Col 3"))
HF_CSVFiles::CloseFile(10)
after()

PrintN("Ended with " + Str(Count) + " Tests, continue with Return ...")
Input()
CloseConsole()

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 34
; FirstLine = 21
; Folding = -
; EnableXP