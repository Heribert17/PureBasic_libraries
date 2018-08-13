;   Description: Unittest routine for HF_Time
;            OS: Windows
;        Author: Heribert Füchtenhans
;       Version: 1.0
;  Used Modules: HF_Time.pbi
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


EnableExplicit

IncludeFile "..\HF_Time.pbi"

Define Count.i=0, Zeit.i

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
  CreateDirectory(".\Test")
EndProcedure

Procedure after()
  DeleteDirectory(".\Test", "", #PB_FileSystem_Recursive)
EndProcedure



; Start
OpenConsole()
PrintN("Start tests")

; calculate winter time
before()
Zeit = ParseDate("%dd.%mm.%yyyy %hh:%ii:%ss", "01.12.2016 08:00:01")
Assert(FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", HF_Time::GetUTCTime(Zeit)) = "01.12.2016 07:00:01", 
       "wintertime isn't correct: " + FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", HF_Time::GetUTCTime(Zeit)))
after()

; calculate summer time
before()
Zeit = ParseDate("%dd.%mm.%yyyy %hh:%ii:%ss", "01.07.2016 08:00:01")
Assert(FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", HF_Time::GetUTCTime(Zeit)) = "01.07.2016 06:00:01", 
       "summertime isn't correctz: " + FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", HF_Time::GetUTCTime(Zeit)))
after()

before()
Zeit = ParseDate("%dd.%mm.%yyyy %hh:%ii:%ss", "01.01.1971 00:00:01")
Assert(FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", HF_Time::GetUTCTime(Zeit)) = "31.12.1970 23:00:01", 
       "testing time 1 isn't correct: " + FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", HF_Time::GetUTCTime(Zeit)))
after()

before()
Zeit = ParseDate("%dd.%mm.%yyyy %hh:%ii:%ss", "01.07.1971 00:00:01")
Assert(FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", HF_Time::GetUTCTime(Zeit)) = "30.06.1971 22:00:01", 
       "testing time 2 isn't correct: " + FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", HF_Time::GetUTCTime(Zeit)))
after()

PrintN("End " + Str(Count) + " tests, continue with return ...")
Input()
CloseConsole()

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 29
; Folding = -
; EnableXP