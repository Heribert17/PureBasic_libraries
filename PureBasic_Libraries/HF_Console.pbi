; ---------------------------------------------------------------------------------------
;
; Some Console Functions
;
; Author:  Heribert Füchtenhans
; Version: 2020.12.18
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


DeclareModule HF_Console
  ; Console functions
  
  Declare.s InputPassword(Prompt.s, WithNewline.b=#True)
  ; Shows the prompt on the screen and returns the entered password. Char are printed as * on the console
  ; If WithNewLine is true, a newline will be put out after the password was entered.
EndDeclareModule



Module HF_Console
  
  EnableExplicit

  ;---------- Console Routinen.
  
  Procedure.s InputPassword(Prompt.s, WithNewline.b=#True)
    Protected password.s="", KeyPressed.s
    
    Print(Prompt)
    While #True
      KeyPressed = Inkey()
      If KeyPressed = ""
        Delay(20) ; Don't eat all the CPU time, we're on a multitask OS
      ElseIf KeyPressed = Chr(13)
        Break
      ElseIf KeyPressed = ~"\b"
        If Len(password) > 0
          Print(~"\b \b")
          password = Mid(password, 0, Len(password) - 1)
        EndIf
      Else
        password + KeyPressed
        Print("*")
      EndIf
    Wend
    If WithNewline
      PrintN("")
    EndIf
    ProcedureReturn password
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 38
; FirstLine = 34
; Folding = -
; EnableXP
; CompileSourceDirectory