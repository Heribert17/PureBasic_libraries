;   Description: Some String Functions
;            OS: Windows, Linux, Mac
;        Author: Heribert Füchtenhans
;       Version: 3.0
; -----------------------------------------------------------------------------

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



DeclareModule HF_String
  ; String functions
  
  Declare.s getRegExLicenseText()
  ; get the License Text to display if you use Regex functions in PureBasic (fnmatch uses regex)
  
  Declare.b fnmatch(text.s, pattern.s, ignoreCase.b=#True)
  ; Test if a filename or other string matches a pattern that contains * and/or ?
  
  Declare   splitString(List StringParts.s(), ToSplit.s, Delimiter.s, MaxSplits.i=-1, WithSpaceTrim.b=#True)
  ; Splits a string using Delimter into parts an stores them in StringParts()
  
EndDeclareModule



Module HF_String
  
  EnableExplicit

  ;---------- String Routinen.
  ; Attention, if you use fnmatch you have to display the License unter getRegExLicense somewhre in your help system
  ; see regex function in PureBasic help
  
  Procedure.b fnmatch(text.s, pattern.s, ignoreCase.b=#True)
    Protected *text.Character
    Protected *pattern.Character
    Protected *match.Character
    Protected *current.Character=#Null
    
    If ignoreCase
      text = LCase(text)
      pattern = LCase(pattern)
    EndIf
    *text = @text
    *pattern = @pattern
    While *text\c <> #Null
      Select *pattern\c
        Case '*'
          *pattern + SizeOf(Character)
          If *pattern\c = #Null 
            ProcedureReturn #True
          EndIf
          *match = *pattern
          *current = *text + SizeOf(Character)
        Case '?', *text\c
          *text + SizeOf(Character)
          *pattern + SizeOf(Character)
        Default
          If *current = #Null
            ProcedureReturn #False
          Else
            *pattern = *match
            *text = *current
            *current + SizeOf(Character)
          EndIf
      EndSelect
    Wend
    While *pattern\c = '*'
      *pattern + SizeOf(Character)
    Wend
    If *pattern\c = #Null
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  
  Procedure splitString(List StringParts.s(), ToSplit.s, Delimiter.s, MaxSplits.i=-1, WithSpaceTrim.b=#True)
    Protected count.i, StartPos.i, Pos.i, Part.s, Ende.b=#False
    
    ClearList(StringParts())
    count = 0
    StartPos = 1
    If MaxSplits < 1 : MaxSplits = 2147483646 : EndIf
    While Not Ende
      count + 1
      Pos = FindString(ToSplit, Delimiter, StartPos)
      If Pos = 0 Or count >= MaxSplits
        ; Add the remainig string and end the loop
        Part = Mid(ToSplit, StartPos)
        Ende = #True
      Else
        ; atatch the part and caclulacte the next start position
        Part = Mid(ToSplit, StartPos, Pos-StartPos)
        StartPos = Pos + Len(Delimiter)
      EndIf
      If WithSpaceTrim : Part = Trim(Part) : EndIf
      AddElement(StringParts()) : StringParts() = Part
    Wend
  EndProcedure
  
  
  Procedure.s getRegExLicenseText()
    Protected LineEnd.s
    
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_MacOS
        ; some Mac OS X specific code
        LineEnd = #CR$
      CompilerCase #PB_OS_Linux
        ; some Linux specific code
        LineEnd = #LF$
      CompilerDefault
        ; Windows
        LineEnd = LineEnd
    CompilerEndSelect

    ProcedureReturn "This program uses regex functions from PCRE witch requires to include this license text:" + LineEnd +
      "" + LineEnd +
      "PCRE LICENCE" + LineEnd +
      "------------" + LineEnd +
      "" + LineEnd +
      "PCRE is a library of functions To support regular expressions whose syntax" + LineEnd +
      "And semantics are As close As possible To those of the Perl 5 language." + LineEnd +
      "" + LineEnd +
      "Release 7 of PCRE is distributed under the terms of the 'BSD' licence, As" + LineEnd +
      "specified below. The documentation For PCRE, supplied in the 'doc'" + LineEnd +
      "directory, is distributed under the same terms As the software itself." + LineEnd +
      "" + LineEnd +
      "The basic library functions are written in C And are freestanding. Also" + LineEnd +
      "included in the distribution is a set of C++ wrapper functions." + LineEnd +
      "" + LineEnd +
      "" + LineEnd +
      "THE BASIC LIBRARY FUNCTIONS" + LineEnd +
      "---------------------------" + LineEnd +
      "" + LineEnd +
      "Written by:       Philip Hazel" + LineEnd +
      "Email local part: ph10" + LineEnd +
      "Email domain:     cam.ac.uk" + LineEnd +
      "" + LineEnd +
      "University of Cambridge Computing Service," + LineEnd +
      "Cambridge, England." + LineEnd +
      "" + LineEnd +
      "Copyright (c + LineEnd + 1997-2007 University of Cambridge" + LineEnd +
      "All rights reserved." + LineEnd +
      "" + LineEnd +
      "" + LineEnd +
      "THE C++ WRAPPER FUNCTIONS" + LineEnd +
      "-------------------------" + LineEnd +
      "" + LineEnd +
      "Contributed by:   Google Inc." + LineEnd +
      "" + LineEnd +
      "Copyright (c + LineEnd + 2007, Google Inc." + LineEnd +
      "All rights reserved." + LineEnd +
      "" + LineEnd +
      "" + LineEnd +
      "THE BSD' LICENCE" + LineEnd +
      "-----------------" + LineEnd +
      "" + LineEnd +
      "Redistribution And use in source And binary forms, With Or without" + LineEnd +
      "modification, are permitted provided that the following conditions are met:" + LineEnd +
      "" + LineEnd +
      "    * Redistributions of source code must retain the above copyright notice," + LineEnd +
      "      this List of conditions And the following disclaimer." + LineEnd +
      "" + LineEnd +
      "    * Redistributions in binary form must reproduce the above copyright" + LineEnd +
      "      notice, this List of conditions And the following disclaimer in the" + LineEnd +
      "      documentation And/Or other materials provided With the distribution." + LineEnd +
      "" + LineEnd +
      "    * Neither the name of the University of Cambridge nor the name of Google" + LineEnd +
      "      Inc. nor the names of their contributors may be used To endorse Or" + LineEnd +
      "      promote products derived from this software without specific prior" + LineEnd +
      "      written permission." + LineEnd +
      "" + LineEnd +
      "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS And CONTRIBUTORS 'As IS'" + LineEnd +
      "And ANY EXPRESS Or IMPLIED WARRANTIES, INCLUDING, BUT Not LIMITED To, THE" + LineEnd +
      "IMPLIED WARRANTIES OF MERCHANTABILITY And FITNESS For A PARTICULAR PURPOSE" + LineEnd +
      "ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER Or CONTRIBUTORS BE" + LineEnd +
      "LIABLE For ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, Or" + LineEnd +
      "CONSEQUENTIAL DAMAGES (INCLUDING, BUT Not LIMITED To, PROCUREMENT OF" + LineEnd +
      "SUBSTITUTE GOODS Or SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS" + LineEnd +
      "INTERRUPTION + LineEnd + HOWEVER CAUSED And ON ANY THEORY OF LIABILITY, WHETHER IN" + LineEnd +
      "CONTRACT, STRICT LIABILITY, Or TORT (INCLUDING NEGLIGENCE Or OTHERWISE + LineEnd +" + LineEnd +
      "ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN If ADVISED OF THE" + LineEnd +
      "POSSIBILITY OF SUCH DAMAGE." + LineEnd +
      "" + LineEnd +
      "End"
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 8
; Folding = -
; EnableXP