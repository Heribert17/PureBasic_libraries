; ---------------------------------------------------------------------------------------
;
; MS-SQL ODBC-DSN on the fly with TCP/IP-connection
;
; Author:  Heribert Füchtenhans
; Version: 1.0
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
;
; Based on the following Library:
; German forum: http://www.purebasic.fr/german/archive/viewtopic.php?t=1513&highlight=
; Author: bobobo (updated for PB3.92+ by Lars, updated for PB 4.00 by Andre)
; Date: 26. June 2003
;
; An example by Siegfried Rings (CodeGuru) 
; extended by bobobo 
;
; ---------------------------------------------------------------------------------------

DeclareModule HF_ODBC
  Declare.b CreateConnection(Driver.s, strAttributes.s)
  ; Create an ODBC Connection, return #False on error
  
  Declare.b DeleteConnection(Driver.s, DSN.s) 
  ; Deletes a connection, return #False on error
  
  Declare.s GetLastErrormessage()
  ; return the last ODBC errormessage when ohen of the function abvoe return #False
  
EndDeclareModule



Module HF_ODBC
  
  EnableExplicit


  #ODBC_ADD_DSN = 1         ; Add Data source 
  #ODBC_ADD_SYS_DSN = 4     ; Add SYSTEM Data source 
  #ODBC_CONFIG_DSN = 2      ; Configure (edit) Data source 
  #ODBC_REMOVE_DSN = 3      ; Remove Data source 
  #ODBC_REMOVE_SYS_DSN = 6  ; Remove SYSTEM Data source 
  
  Prototype.i ProtoSQLConfigDataSource(hwndParent.i, fRequest.w, lpszDriver.p-ascii, *lpszAttributes)
  Prototype.i ProtoSQLInstallerError(iError.w, *pfErrorCode, *lpszErrorMsg, cbErrorMsgMax.i, *pcbErrorMsg)
  
  Define Errormessage.s
  
  
  ;--- Internal procedures ----------------------------------------------------
  
  Procedure getODBCErrorMessage(LibHandle.i)
    Shared Errormessage.s
    Protected pfErrorCode.l, *lpszErrorMsg, ODBCError.ProtoSQLInstallerError
    
    ODBCError = GetFunction(LibHandle, "SQLInstallerError")
    *lpszErrorMsg = AllocateMemory(2050)
    ODBCError(1, @pfErrorCode, *lpszErrorMsg, 2050, 0)
    ErrorMessage = PeekS(*lpszErrorMsg, -1, #PB_Ascii)
    FreeMemory(*lpszErrorMsg)
  EndProcedure
  
  
  ;--- Module procedures ----------------------------------------------------

  Procedure.b CreateConnection(Driver.s, Attributes.s)
    Shared ErrorMessage.s
    Protected LibHandle.i, *strAttributes, Result.i, rwert.b=#True, i.i
    Protected ODBCConfig.ProtoSQLConfigDataSource
    
    LibHandle = OpenLibrary(#PB_Any, "ODBCCP32.DLL")
    If LibHandle 
      *strAttributes = AllocateMemory(StringByteLength(Attributes, #PB_Ascii) + 10)
      PokeS(*strAttributes, Attributes, -1, #PB_Ascii)
      For i=0 To StringByteLength(Attributes, #PB_Ascii)
        If PeekB(*strAttributes + i) = Asc(";")
          PokeB(*strAttributes + i, 0)
        EndIf
      Next i
      ODBCConfig = GetFunction(LibHandle, "SQLConfigDataSource")
      Result = ODBCConfig(0, #ODBC_ADD_DSN, Driver, *strAttributes)
      FreeMemory(*strAttributes)
      If Result <> 1
        getODBCErrorMessage(LibHandle)
        rwert = #False
      EndIf
      CloseLibrary(LibHandle)
    Else
      ErrorMessage = "Library ODBCCP32.DLL not found."
      rwert = #False
    EndIf
    ProcedureReturn rwert
  EndProcedure 
  
  
  Procedure.b DeleteConnection(Driver.s, DSN.s)
    Shared ErrorMessage.s
    Protected LibHandle.i, Result.i, Attributes.s, *strAttributes, rwert=#True, i.i
    Protected ODBCConfig.ProtoSQLConfigDataSource
    
    LibHandle = OpenLibrary(#PB_Any, "ODBCCP32.DLL")
    If LibHandle 
      Attributes = "DSN=" + DSN 
      *strAttributes = AllocateMemory(StringByteLength(Attributes, #PB_Ascii) + 10)
      PokeS(*strAttributes, Attributes, -1, #PB_Ascii)
      For i=0 To StringByteLength(Attributes, #PB_Ascii)
        If PeekB(*strAttributes + i) = Asc(";")
          PokeB(*strAttributes + i, 0)
        EndIf
      Next i
      ODBCConfig = GetFunction(LibHandle, "SQLConfigDataSource")
      Result = ODBCConfig(0, #ODBC_REMOVE_DSN, Driver, *strAttributes)
      FreeMemory(*strAttributes)
      If Result <> 1
        getODBCErrorMessage(LibHandle)
        rwert = #False
      EndIf
      CloseLibrary(LibHandle) 
    Else
      ErrorMessage = "Library ODBCCP32.DLL not found."
      rwert = #False
    EndIf
    ProcedureReturn rwert  
  EndProcedure 
  
  
  Procedure.s GetLastErrormessage()
    Shared ErrorMessage.s
    
    ProcedureReturn ErrorMessage
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.70 LTS beta 3 (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 5
; Folding = --
; EnableXP
; Compiler = PureBasic 5.70 LTS beta 3 (Windows - x64)