; ---------------------------------------------------------------------------------------
;
; Test procedures for HF_WPDLib
;
; Author:  Heribert Füchtenhans
; Version: 1.0
; OS:      Windows
;
; Requirements: HF_WPDLib.pbi
;
; Messages and Variable names are still in German, also some constants are set to
; my environment. Heribert
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

XIncludeFile "..\HF_WPDLib.pbi"


Procedure SetWaitCursor(Gadget.i)
  Protected NewCursor.i
  
  NewCursor = LoadCursor_(0, #IDC_WAIT)
  SetClassLongPtr_(WindowID(Gadget), #GCL_HCURSOR, NewCursor)
EndProcedure


Procedure SetNormalCursor(Gadget.i)
  Protected NewCursor.i
  
  NewCursor = LoadCursor_(0, #IDC_ARROW)
  SetClassLongPtr_(WindowID(Gadget), #GCL_HCURSOR, NewCursor)
EndProcedure

;---------- Main Procedure

Define Event.i, MainWindow.i, DirText.i, Verzeichnis.s, IDText.i, SourceFile.s, DestFile.s
Define NewList DirectoryList.HF_WPDLib::sDirectoryEntry()

If Not HF_WPDLib::open("WPDLib", 1, 0)
  MessageRequester("WPDLIB", HF_WPDLib::GetErrorMessage())
Else
  MainWindow = OpenWindow(#PB_Any, #PB_Ignore, 0, 800, 400, "WPDLib-Test", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  If MainWindow
    TextGadget(#PB_Any, 10, 10, 140, 20, "Verzeichnis:")
    DirText = TextGadget(#PB_Any, 10, 30, 780, 20, "")
    SetGadgetColor(DirText, #PB_Gadget_BackColor, RGB(255,255,255))
    TextGadget(#PB_Any, 10, 60, 140, 20, "Directory Inhalt")
    IDText = EditorGadget(#PB_Any, 10, 80, 780, 200, #PB_Editor_ReadOnly)
    ButtonGadget(1, 10, 360, 100, 30, "Select Directory")
    ButtonGadget(2, 140, 360, 100, 30, "Create Directory")
    ButtonGadget(3, 250, 360, 100, 30, "Delete Directory")
    ButtonGadget(4, 360, 360, 100, 30, "Copy file to dev.")
    ButtonGadget(5, 470, 360, 100, 30, "Copy file from dev.")
    SetGadgetText(DirText, "--- Nichts ausgewählt ---")
    Repeat
      Event = WaitWindowEvent()
      Select Event
         Case #PB_Event_Gadget
           Select EventGadget()
             Case 1 :
               Verzeichnis = HF_WPDLib::PathRequestor(MainWindow.i, "MTP Verzeichnisauswahl")
               If Verzeichnis
                 SetGadgetText(DirText, Verzeichnis)
                 ClearGadgetItems(IDText)
                 HF_WPDLib::getDirectoryByName(Verzeichnis, DirectoryList())
                 ForEach DirectoryList() : AddGadgetItem(IDText, -1, DirectoryList()\Name) : Next
               Else
                 SetGadgetText(DirText, "--- Nichts ausgewählt ---")
               EndIf
             Case 2:
               Verzeichnis = InputRequester("WPDLib", "Name des neuen Verzeichnisses:", GetGadgetText(DirText))
               If Verzeichnis <> ""
                 HF_WPDLib::CreateDirectoryByName(Verzeichnis)
               EndIf
             Case 3:
               Verzeichnis = InputRequester("WPDLib", "Name des zu löschenden Verzeichnisses:", GetGadgetText(DirText))
               If Verzeichnis <> ""
                 SetWaitCursor(MainWindow)
                 HF_WPDLib::RemoveDirectoryByName(Verzeichnis)
                 SetNormalCursor(MainWindow)
               EndIf
             Case 4:
               If Left(GetGadgetText(DirText), 3) = "---"
                 MessageRequester("WPDLib", "Es wurde kein Zielverzeichnis ausgewählt.", #PB_MessageRequester_Error)
               Else
                 SourceFile = OpenFileRequester("WPDLib", "", "Alle Dateien (*.*)|*.*", 0)
                 If SourceFile <> ""
                   SetWaitCursor(MainWindow)
                   HF_WPDLib::CopyFileToDevice(SourceFile, GetGadgetText(DirText) + "\" + GetFilePart(SourceFile))
                   SetNormalCursor(MainWindow)
                 EndIf
               EndIf
             Case 5:
               SourceFile = InputRequester("WPDLib", "Datei die kopiert werden soll:", "\\Philips GoGear Ariaz\Internel storage\Music\back draft\Pull The Trigger\01 Little Mona.mp3")
               If SourceFile <> ""
                 DestFile = SaveFileRequester("WPDLib Zieldatei", "c:\temp\Test.mp3", "Alle Dateien (*.*)|*.*", 0)
                 If DestFile <> ""
                   SetWaitCursor(MainWindow)
                   HF_WPDLib::CopyFilefromDevice(SourceFile, DestFile)
                   SetNormalCursor(MainWindow)
                 EndIf
               EndIf
           EndSelect
       EndSelect
       If HF_WPDLib::GetErrorMessage() <> ""
         MessageRequester("WPD Fehlermeldung", HF_WPDLib::GetErrorMessage())
         HF_WPDLib::ClearErrorMessage()
       EndIf
    Until Event = #PB_Event_CloseWindow
  EndIf
  HF_WPDLib::close()
EndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 61
; FirstLine = 58
; Folding = -
; EnableXP