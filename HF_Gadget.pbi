;   Description: Gadget functions
;            OS: Windows only
;        Author: Heribert Füchtenhans
;       Version: 1.0
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


DeclareModule HF_Gadget
; Selects Text inside an EditorGadget 
; Line numbers range from 0 to CountGadgetItems(#Gadget)-1 
; Char numbers range from 1 to the length of a line 
; Set Line numbers to -1 to indicate the last line, and Char numbers to -1 to indicate the end of a line 
; selecting from 0,1 to -1, -1 selects all. 

  Declare Editor_BackColor(Gadget, Color.l)
  ; Set background color of the Selection
  
  Declare Editor_Select(Gadget, LineStart.l, CharStart.l, LineEnd.l, CharEnd.l)
  ; select strings from an editor gadget
  
  Declare Editor_Color(Gadget, Color.l)
  ; Set the Text color for the Selection in RGB format 
  
  Declare Editor_FontSize(Gadget, Fontsize.l)
  ; Set Font Size for the Selection in pt 
  
  Declare Editor_Font(Gadget, FontName.s)
  ; Set Font for the Selection 
  ; You must specify a font name, the font doesn't need to be loaded 
  
  Declare Editor_Format(Gadget, Flags.l)
  ; Set Format of the Selection. This can be a combination of the following values: 
  ; #CFM_BOLD 
  ; #CFM_ITALIC 
  ; #CFM_UNDERLINE 
  ; #CFM_STRIKEOUT 
  
EndDeclareModule



Module HF_Gadget
  
  EnableExplicit
  
  
  ;---------- Gadget Funktionen
  

  Structure CHARFORMAT2_ 
    cbSize.l 
    dwMask.l  
    dwEffects.l  
    yHeight.l  
    yOffset.l  
    crTextColor.l  
    bCharSet.b  
    bPitchAndFamily.b  
    szFaceName.b[#LF_FACESIZE]  
    _wPad2.w  
    wWeight.w  
    sSpacing.w  
    crBackColor.l  
    lcid.l  
    dwReserved.l  
    sStyle.w  
    wKerning.w  
    bUnderlineType.b  
    bAnimation.b  
    bRevAuthor.b  
    bReserved1.b 
  EndStructure 
  
  
  
  Procedure Editor_BackColor(Gadget, Color.l) 
    Protected format.CHARFORMAT2_ 
    
    format\cbSize = SizeOf(CHARFORMAT2_) 
    format\dwMask = $4000000  ; = #CFM_BACKCOLOR 
    format\crBackColor = Color 
    SendMessage_(GadgetID(Gadget), #EM_SETCHARFORMAT, #SCF_SELECTION, @format) 
  EndProcedure
  
  
  Procedure Editor_Select(Gadget, LineStart.l, CharStart.l, LineEnd.l, CharEnd.l)
    Protected sel.CHARRANGE
    
    sel\cpMin = SendMessage_(GadgetID(Gadget), #EM_LINEINDEX, LineStart, 0) + CharStart - 1 
    If LineEnd = -1 
      LineEnd = SendMessage_(GadgetID(Gadget), #EM_GETLINECOUNT, 0, 0)-1 
    EndIf 
    sel\cpMax = SendMessage_(GadgetID(Gadget), #EM_LINEINDEX, LineEnd, 0) 
    If CharEnd = -1 
      sel\cpMax + SendMessage_(GadgetID(Gadget), #EM_LINELENGTH, sel\cpMax, 0) 
    Else 
      sel\cpMax + CharEnd - 1 
    EndIf 
    SendMessage_(GadgetID(Gadget), #EM_EXSETSEL, 0, @sel) 
  EndProcedure 
  
  
  ; Set the Text color for the Selection in RGB format 
  Procedure Editor_Color(Gadget, Color.l)
    Protected format.CHARFORMAT 
    
    format\cbSize = SizeOf(CHARFORMAT) 
    format\dwMask = #CFM_COLOR 
    format\crTextColor = Color 
    SendMessage_(GadgetID(Gadget), #EM_SETCHARFORMAT, #SCF_SELECTION, @format) 
  EndProcedure 
  
  
  ; Set Font Size for the Selection in pt 
  Procedure Editor_FontSize(Gadget, Fontsize.l)
    Protected format.CHARFORMAT 
    
    format\cbSize = SizeOf(CHARFORMAT) 
    format\dwMask = #CFM_SIZE 
    format\yHeight = FontSize*20 
    SendMessage_(GadgetID(Gadget), #EM_SETCHARFORMAT, #SCF_SELECTION, @format) 
  EndProcedure 
  
  
  ; Set Font for the Selection 
  ; You must specify a font name, the font doesn't need to be loaded 
  Procedure Editor_Font(Gadget, FontName.s)
    Protected format.CHARFORMAT
    
    format\cbSize = SizeOf(CHARFORMAT) 
    format\dwMask = #CFM_FACE 
    PokeS(@format\szFaceName, FontName) 
    SendMessage_(GadgetID(Gadget), #EM_SETCHARFORMAT, #SCF_SELECTION, @format) 
  EndProcedure 
  
  
  ; Set Format of the Selection. This can be a combination of the following values: 
  ; #CFM_BOLD 
  ; #CFM_ITALIC 
  ; #CFM_UNDERLINE 
  ; #CFM_STRIKEOUT 
  Procedure Editor_Format(Gadget, Flags.l)
    Protected format.CHARFORMAT 
    
    format\cbSize = SizeOf(CHARFORMAT) 
    format\dwMask = #CFM_ITALIC|#CFM_BOLD|#CFM_STRIKEOUT|#CFM_UNDERLINE 
    format\dwEffects = Flags 
    SendMessage_(GadgetID(Gadget), #EM_SETCHARFORMAT, #SCF_SELECTION, @format) 
  EndProcedure 

EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 169
; FirstLine = 131
; Folding = --
; EnableXP