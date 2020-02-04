; ---------------------------------------------------------------------------------------
;
; Test procedures for HF_Logging
;
; Author:  Heribert Füchtenhans
; Version: 1.0
; OS:      Windows, Linux, Mac
;
; Requirements: HF_Logging.pbi
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

IncludeFile "..\HF_Logging.pbi"

Define Count.i = 0, i.l, Line.s

Macro Assert(Expression, Meldung)
  Count + 1
  If Not (Expression)
    PrintN("Assert (Line " + #PB_Compiler_Line + "): " + Meldung)
    PrintN("Continue with return ...")
    Input()
    End
  EndIf
EndMacro


Procedure before()
  Protected i.i
  
  CreateDirectory(".\Test")
  For I = 0 To 100
    DeleteFile(".\Test\Test.log." + Str(i))
  Next
  DeleteFile(".\Test\Test.log")
  HF_Logging::OpenLogger(".\Test\Test.log", #False, #True, HF_Logging::#INFO, 1, 4)
EndProcedure


Procedure after()
  HF_Logging::CloseLogger()
  DeleteDirectory(".\Test", "", #PB_FileSystem_Recursive)
EndProcedure



; Hier sind die Test
OpenConsole()
PrintN("Starte Tests")

; Logeintrag schreiben
before()
HF_Logging::WriteLogger("Test")
Assert(FileSize(".\Test\Test.log") >= 0, "The log file wasn't created: " +Str(FileSize(".\Test\Test.log")))
after()

; Dateienwechsel
before()
For i = 0 To 30000
  HF_Logging::WriteLogger(Str(i) + " Test13413746732657367836478637846173647849832746987324636473647632746327647326473647746179463798267")
Next
Assert(FileSize(".\Test\Test.log") >= 0, "he log file wasn't created.")
Assert(FileSize(".\Test\Test.log.2") >= 0, "Logfile *.2 should be there but isn't.")
Assert(FileSize(".\Test\Test.log.3") = -1, "Logfile *.3 should be there but isn't.")
after()

; Write multiline entry
before()
HF_Logging::WriteLogger(~"Test0\nTest1\nTest2")
ReadFile(0, ".\Test\Test.log", #PB_File_SharedRead | #PB_File_SharedWrite)
i = 0
While Eof(0) = 0
  Line = ReadString(0)
  Assert(StringField(Line, 3, Chr(9))  = ("Test" + Str(i)), "The multiline text hasn't been written correctly.")
  Assert(i < 3, "There are more then 3 lines in the log file")
  i + 1
Wend
CloseFile(0)
after()

before()
HF_Logging::WriteLogger(~"Test0\nTest1\nTest2")
NewList Logeintraege.s()
HF_Logging::GetSavedLogger(Logeintraege())
i = 0
ForEach Logeintraege()
  Line = Logeintraege()
  Assert(StringField(Line, 3, Chr(9))  = ("Test" + Str(i)), "The multiline text hasn't been stored correctly.")
  Assert(i < 3, "There are more then 3 lines stored in memory")
  i + 1
Next
after()


before()
Assert(HF_Logging::WriteWindowsEventlog("Unittest_HF_Logging", ~"Fehlermeldung\n2. Zeile\n3. Zeile", 23456, HF_Logging::#EVENTLOG_ERROR_TYPE), "Error storing windows eventlog message")
after()


before()
Line = ""
For i = 1 To 304
  Line + Str(i) + ~" 1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890\r\n"
Next i
PrintN(Str(Len(line)))
Assert(HF_Logging::WriteWindowsEventlog("Unittest_HF_Logging", Line, 23456, HF_Logging::#EVENTLOG_ERROR_TYPE, #True), "Error storing windows eventlog message")
after()

PrintN("End " + Str(Count) + " tests, continue with return ...")
Input()
CloseConsole()

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 126
; FirstLine = 90
; Folding = -
; EnableXP
; CompileSourceDirectory