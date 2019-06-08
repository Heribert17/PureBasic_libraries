; ---------------------------------------------------------------------------------------
;
; Test procedures for HF_Filesystem
;
; Author:  Heribert Füchtenhans
; Version: 1.0
; OS:      Windows
;
; Requirements: HF_Filesystem.pbi
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


IncludeFile "..\HF_Filesystem.pbi"

Define Count = 0, Filename.s


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


Procedure before()
EndProcedure

Procedure after()
  DeleteDirectory(".\Test", "", #PB_FileSystem_Recursive)
EndProcedure



OpenConsole()
PrintN("Start Tests")

before()
Assert(HF_Filesystem::CreateDirectories(".\Test\test\test") = #True, "Error creating directorys")
Assert(FileSize(".\Test\test\test") = -2, "The directory .\Test\test\test wasn't created.")
after()

before()
Assert(HF_Filesystem::CreateDirectories("c::.\Test\test\test") = #True, "Error creating directorys c::.\Test\test\test")
Assert(FileSize(".\Test\test\test") = -1, "The directory c::.\Test\test\test was created.")
after()

before()
Define Dirname.s = ".\Test\testdjfhdjfhfhdjkhbcdhdsjkghfvbjdshgfjcdhndghdnjchfgdjngcdjhgnjdhgnjfdshngjschngdfngfjdfhgjfdhgjdfshgjhfdsjghdfjhgjdfschgjfdhgjfdhgjhfdsjghdfsjghjfdshgjfdhjghfdjhgjfdshgjhfdnjcghdsfjhgjfdhgjhdfjgchfdjhgjfdhgjsfdh\test"
Assert(HF_Filesystem::CreateDirectories(Dirname) = #True, "Error creating a directory with a very long name")
Assert(FileSize(Dirname) = -1, "The directory with the very long name has been created.")
after()

before()
Dirname.s = "C:"
Assert(HF_Filesystem::CreateDirectories(Dirname) = #False, "Error creating C:")
after()

before()
Dirname.s = "\\oediv.local\oed-intern\users\Fuechtenhansh\temp\test"
DeleteDirectory(Dirname, "", #PB_FileSystem_Recursive)
Assert(HF_Filesystem::CreateDirectories(Dirname + "\sub1\sub2") = #True, "Error creating " + Dirname)
after()
  
before()
Assert(HF_Filesystem::JoinPath(".\Test", "Test") = ".\Test\Test", "Directoryname wrong created 1")
Assert(HF_Filesystem::JoinPath(".\Test", "\Test") = ".\Test\Test", "Directoryname wrong created 2")
Assert(HF_Filesystem::JoinPath(".\Test", "\Test\test1") = ".\Test\Test\test1", "Directoryname wrong created 3")
after()

before()
Assert(HF_Filesystem::JoinPath("C:", "Test") = "C:Test", "Directoryname wrong created 4")
Assert(HF_Filesystem::JoinPath("C:\", "Test") = "C:\Test", "Directoryname wrong created 5")
Assert(HF_Filesystem::JoinPath("C:\", "\Test") = "C:\Test", "Directoryname wrong created 6")
Assert(HF_Filesystem::JoinPath("C:", "\Test") = "C:\Test", "Directoryname wrong created 7")
after()
  
before()
Assert(HF_Filesystem::JoinPath("", "Test") = "Test", "Directoryname wrong created 8")
Assert(HF_Filesystem::JoinPath("C:\", "") = "C:\", "Directoryname wrong created 9")
Assert(HF_Filesystem::JoinPath("C:", "") = "C:", "Directoryname wrong created 10")
Assert(HF_Filesystem::JoinPath("", "C:\Test") = "C:\Test", "Directoryname wrong created 11")
after()
  
before()
Assert(HF_Filesystem::JoinPath("\\abc\c\", "Test") = "\\abc\c\Test", "Directoryname wrong created 12")
Assert(HF_Filesystem::JoinPath("\\abc\c", "Test") = "\\abc\c\Test", "Directoryname wrong created 13")
Assert(HF_Filesystem::JoinPath("\\abc\c$\", "Test") = "\\abc\c$\Test", "Directoryname wrong created 14")
Assert(HF_Filesystem::JoinPath("\\abc\c$", "Test") = "\\abc\c$\Test", "Directoryname wrong created 15")
after()


  
before()
Filename = HF_Filesystem::GetFullFilename("UnitTest_HF_Filesystem.pb")
Assert(Mid(Filename, 2, 1) = ":" And Right(Filename, 25) = "UnitTest_HF_Filesystem.pb",  "GetFullPathname doesn't return the correct name")
after()


PrintN("Ended with " + Str(Count) + " Tests, continue with Return ...")
Input()
CloseConsole()

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 33
; FirstLine = 24
; Folding = -
; EnableXP