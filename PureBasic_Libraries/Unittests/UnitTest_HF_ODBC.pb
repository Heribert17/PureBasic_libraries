; -----------------------------------------------------------------------------------------
;
; Unittest functins to test the ODBC connection
;
; Autor: Heribert Füchtenhans
;
; Attention:
;  If you start the application ind purebasic Debugger it will create 32 ODBC connections
;
; -----------------------------------------------------------------------------------------

EnableExplicit

IncludeFile "..\HF_ODBC.pbi"



Define Count.i=0, Zeit.i

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



; Hier sind die Test
OpenConsole()
PrintN("Start Tests")

; ODBC anlegen
before()
; If Not HF_ODBC::CreateConnection(HF_ODBC::#SQL_SERVER, "DSN=Personnel Data") ;UID=Smith;PWD=Sesame;DATABASE=Personnel")
If Not HF_ODBC::CreateConnection("SQL Server", "DSN=Personnel Data") ;Server=DB-OEDIV-4B;Database=EASY;Uid=Test;Pwd=OEDIV###;")
  PrintN("Fehler beim anlegen der ODBC Verbindung.")
  PrintN(HF_ODBC::GetLastErrormessage())
EndIf
PrintN("Nachsehen ob ODBC 64 'TestODBC' angelegt wurde.")
Input()
after()

; ODBC entfernen
before()
If Not HF_ODBC::DeleteConnection("SQL Server", "Personnel Data")
  PrintN("Fehler beim entfernen der ODBC Verbindung.")
  PrintN(HF_ODBC::GetLastErrormessage())
EndIf
PrintN("Nachsehen ob ODBC 64 'TestODBC' entfernt wurde.")
Input()
after()

PrintN("Ende mit " + Str(Count) + " Tests, weiter mit Return ...")
Input()
CloseConsole()

; IDE Options = PureBasic 5.70 LTS beta 3 (Windows - x64)
; CursorPosition = 13
; Folding = -
; EnableXP