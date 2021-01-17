; ---------------------------------------------------------------------------------------
;
; Gadget functions
;
; Author:  Heribert Füchtenhans
; Version: 1.1
; OS:      Windows
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

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  
  
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
    
    ; Sorry works only on the window not on any container in that window
    ; Declare SetWaitCursor(hWnd, WaitCursor.b=#True)
    ; sets the cursor to WaitCursor or back to normal if WaitCursor = #False
    ; hWnd ist the id of the window. You get it with WindowID()
    
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
      Protected sel.CHARRANGE, Gadgeti.i
      
      Gadgeti = GadgetID(Gadget)
      sel\cpMin = SendMessage_(Gadgeti, #EM_LINEINDEX, LineStart, 0) + CharStart - 1 
      If LineEnd = -1 
        LineEnd = SendMessage_(Gadgeti, #EM_GETLINECOUNT, 0, 0)-1 
      EndIf 
      sel\cpMax = SendMessage_(Gadgeti, #EM_LINEINDEX, LineEnd, 0) 
      If CharEnd = -1 
        sel\cpMax + SendMessage_(Gadgeti, #EM_LINELENGTH, sel\cpMax, 0) 
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
    
    ; Set the cursor
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        #CURSOR_ARROW = #IDC_ARROW
        #CURSOR_BUSY = #IDC_WAIT
      CompilerCase #PB_OS_MacOS
        #CURSOR_ARROW = #kThemeArrowCursor
        #CURSOR_BUSY = #kThemeWatchCursor
        ImportC ""
          SetThemeCursor(CursorType.L)
        EndImport
      CompilerCase #PB_OS_Linux
        #CURSOR_ARROW = #GDK_ARROW
        #CURSOR_BUSY = #GDK_WATCH
        Global *Cursor.GdkCursor
        ImportC ""
          gtk_widget_get_window(*widget.GtkWidget)
        EndImport
    CompilerEndSelect
    
    
    Procedure MySetCursor(hWnd.i, CursorId.i)
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
;         SetClassLongPtr_(hWnd, #GCL_HCURSOR, LoadCursor_(0, CursorId))
        SetClassLong_(hWnd, #GCL_HCURSOR, #NUL)
        SetClassLong_(hWnd, #GCL_HCURSOR, LoadCursor_(0, CursorId))
      CompilerElseIf #PB_Compiler_OS = #PB_OS_MacOS
        SetThemeCursor(CursorId)
      CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux
         *Cursor= gdk_cursor_new_(CursorID)
         If *Cursor
            gdk_window_set_cursor_(gtk_widget_get_window(WindowID(Window)), *Cursor)
         EndIf
      CompilerEndIf
    EndProcedure
    
    Procedure SetWaitCursor(hWnd, WaitCursor.b=#True)
      ; sets the cursor to WaitCursor or back to normal if WaitCursor = #False
      ; hWnd ist the id of the window. You get it with WindowID()
      If WaitCursor
        MySetCursor(hWnd, #CURSOR_BUSY)
      Else
        MySetCursor(hwnd, #CURSOR_ARROW)
      EndIf
    EndProcedure
    

  EndModule
CompilerEndIf

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 68
; FirstLine = 42
; Folding = ---
; EnableXP
; CompileSourceDirectory