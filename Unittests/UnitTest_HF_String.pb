;   Description: Simple Routine to test HF_Strings
;            OS: Windows
;        Author: Heribert Füchtenhans
;       Version: 1.0
; -----------------------------------------------------------------------------

; MIT License
; 
; Copyright (c) 2014-2018 Heribert Füchtenhans
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


IncludeFile "..\HF_String.pbi"

Define Count = 0

Macro Assert(Expression, Meldung)
  Count + 1
  If Not (Expression)
    PrintN("Assert (Line " + #PB_Compiler_Line + "): " + Meldung)
    PrintN("Continue with Return ...")
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
PrintN("Start Tests")

before()
Assert(HF_String::fnmatch("test", "Test") = #True, "Test test wrong")
after()

before()
Assert(HF_String::fnmatch("test_123", "test") = #False, "test test wrong")
after()

before()
Assert(HF_String::fnmatch("test_123", "test*") = #True, "test* test wrong")
after()

before()
Assert(HF_String::fnmatch("test_123", "?es*") = #True, "?es* test wrong")
after()

before()
Assert(HF_String::fnmatch("test_123", "*_*") = #True, "*_* test wrong")
after()

before()
Assert(HF_String::fnmatch("test_123.txt", "tes*") = #True, "tes* test wrong")
after()

before()
Assert(HF_String::fnmatch("test_123.txt", "tes*.txx") = #False, "tes*.txx test wrong")
after()

before()
Assert(HF_String::fnmatch("Match this Text!", "Match th?? Text!") = #True, "Match th?? Text! test wrong")
after()

before()
Assert(HF_String::fnmatch("Match that Text!", "Match th?? Text!") = #True, "atch th?? Text! test wrong")
after()

before()
Assert(HF_String::fnmatch("abctest.txt", "*test.txt") = #True, "*test.txt test wrong")
after()

before()
Assert(HF_String::fnmatch("deftest.txt", "de*test.txt") = #True, "de*test.txt test wrong")
after()

before()
Assert(HF_String::fnmatch("ghitest.txt", "ghitest.txt*") = #True, "ghitest.txt* test wrong")
after()

before()
Assert(HF_String::fnmatch("jkltest.txt", "*") = #True, "* test wrong")
after()

before()
Assert(HF_String::fnmatch("mnotest.txt", "??*") = #True, "??* test wrong")
after()

before()
Assert(HF_String::fnmatch("Example\File.txt", "*\*.txt") = #True, "*\*.txt test wrong")
after()

before()
Assert(HF_String::fnmatch("Exampaple\File.txt", "*ple\*.txt") = #True, "*ple\*.txt test wrong")
after()

before()
Assert(HF_String::fnmatch("Image_001.jpg", "*???.jpg") = #True, "*???.jpg test wrong")
after()

before()
Assert(HF_String::fnmatch("Image_001.jpg", "*???01.jpg") = #True, "*???01.jpg test wrong")
after()

before()
Assert(HF_String::fnmatch("Test1.txt", "te*.txt") = #True, "te*.txt test wrong")
after()

before()
Assert(HF_String::fnmatch("No Match!", "No Match?.") = #False, "No Match?. test wrong")
after()

before()
Assert(HF_String::fnmatch("pqrTest.txt", "?qrtast.txt") = #False, "?qrtast.txt test wrong")
after()

before()
Assert(HF_String::fnmatch("stutest.txt", "?tutest.txf?") = #False, "?tutest.txf? test wrong")
after()

before()
Assert(HF_String::fnmatch("Image_001.jpg", "*???02.jpg") = #False, "*???02.jpg test wrong")
after()

before()
Assert(HF_String::fnmatch("Exampaple\File.txt", "*plf\*.txt") = #False, "*plf\*.txt test wrong")
after()

before()
Assert(HF_String::fnmatch("Test1.txt", "te*.txt", #False) = #False, "te*.txt test wrong")
after()

before()
Assert(HF_String::fnmatch("Example\File.txt.", "*\*.txt") = #False, "te*.txt test wrong")
after()




before()
NewList output.s()
HF_String::splitString(output(), "ABC*DEFG*JKL", "*")
ResetList(output())
NextElement(output())
Assert(output() = "ABC", "splitString ABC is wrong")
NextElement(output())
Assert(output() = "DEFG", "splitString DEFG is wrong")
NextElement(output())
Assert(output() = "JKL", "splitString JKL is wrong")
after()

before()
NewList output.s()
HF_String::splitString(output(), "ABC*DEFG * JKL", "*")
ResetList(output())
NextElement(output())
Assert(output() = "ABC", "splitString ABC is wrong")
NextElement(output())
Assert(output() = "DEFG", "splitString DEFG is wrong")
NextElement(output())
Assert(output() = "JKL", "splitString JKL is wrong")
after()

before()
NewList output.s()
HF_String::splitString(output(), "ABC*DEFG * JKL", "*", -1, #False)
ResetList(output())
NextElement(output())
Assert(output() = "ABC", "splitString ABC is wrong")
NextElement(output())
Assert(output() = "DEFG ", "splitString 'DEFG ' is wrong")
NextElement(output())
Assert(output() = " JKL", "splitString ' JKL' is wrong")
after()

before()
NewList output.s()
HF_String::splitString(output(), "123*45678**9", "*")
ResetList(output())
NextElement(output())
Assert(output() = "123", "splitString 123 is wrong")
NextElement(output())
Assert(output() = "45678", "splitString DEFG is wrong")
NextElement(output())
Assert(output() = "", "splitString '' is wrong")
NextElement(output())
Assert(output() = "9", "splitString 9 is wrong")
after()

PrintN("Ended with " + Str(Count) + " Tests, continue with Return ...")
Input()
CloseConsole()

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 155
; FirstLine = 152
; Folding = -
; EnableXP