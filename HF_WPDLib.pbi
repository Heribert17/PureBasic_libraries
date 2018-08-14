; ---------------------------------------------------------------------------------------
;
; A module to access mobile Devices from Windows via USB connection.
; Implements access to the Windows WPD API
;
; Author:  Heribert Füchtenhans
; Version: 1.0
; OS:      Windows
;
; Requirements: Windows 10
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



DeclareModule HF_WPDLib
  
  Enumeration ContentTypes
    #WPD_Undefined
    #WPD_Device
    #WPD_Storage
    #WPD_Directory
    #WPD_File
  EndEnumeration
  
  Structure sDeviceEntry
    FriendlyName.s
    Manufacturer.s
    ID.s
  EndStructure
  
  Structure sDirectoryEntry
    Name.s
    Typ.i
    FileSize.q
    LastWriteTime.i
    ID.s
    StorageCapacity.q
    StorageFreeSpace.q
  EndStructure

  
  Declare.s GetErrorMessage()
  ; Return last error message
  
  Declare   ClearErrorMessage()
  ; Sets the last error message to ""
  
  Declare.b open(Client_Name.s, Client_Major_Ver.i, Client_Minor_Ver.i)
  ; Opens the portable Devices Interface
  ; return #True on ok else #False
  ; Client_Name: Name of the programm with call the WPD Moule
  ; Client_Major_Ver, Client_Minor_ver: Version number of the program
  ;   I don't know for what they are needed :-(
  
  Declare   getDevices(List DeviceList.sDeviceEntry())
  ; Get a List of all attached devices
  
  Declare   close()
  ; Close devices and free all memory
  
  Declare.s PathRequestor(callingWindow.i, Titel.s="MTP Verzeichnisauswahl")
  ; Gadget to search through the MTP devices
  
  Declare.b GetDirectoryByName(DirectoryName.s, List DirectoryList.sDirectoryEntry())
  ; Searches through all directories and returns in DirectoryList the content of DirectoryName
  ; return #True when found else #False
  
  Declare.s GetCurrentDirectoryByName()
  ; Get Current Directory on MTP device
  
  Declare.i SetCurrentDirectoryByName(Directory.s)
  ; Set Current Directory on MTP device to the given directory
  
  Declare.i CreateDirectoryByName(DirectoryName.s)
  ; Creates a new directory
  
  Declare.i RemoveDirectoryByName(DirectoryName.s)    
  ; Removes a directory including content
  
  Declare.i RemoveFileByName(DirectoryName.s)  
  ; Removes a File
  
  Declare.i CopyFileToDevice(SourceFilename.s, DestinationFilename.s)
  ; Copies a file to an WPD device
  
  Declare.i CopyFileFromDevice(SourceFilename.s, DestinationFilename.s)    
  ; Copies a file from an WPD device
  
  Declare.b GetDirectoryByID(DeviceID.s, DirectoryID.s, List DirectoryList.sDirectoryEntry())
  ; Get content of a Storage or Directory as List defined by the ID of the parent directory
  ; Use "" as ID for the root of the device.
  ; Use the DeviceID returned in DeviceList from by getDevies
  ; Return #False in case of an error
  
EndDeclareModule



Module HF_WPDLib
  
  EnableExplicit


  ;---------- Interface Definitions
  
  Interface IPortableDeviceManager Extends IUnknown
    ; '{A1567595-4C2F-4574-A6FA-ECEF917B9A40}'
    
    GetDevices(pPnPDeviceIDs, pcPnPDeviceIDs)
    RefreshDeviceList()
    GetDeviceFriendlyName(pszPnPDeviceID, pDeviceFriendlyName, pcchDeviceFriendlyName)
    GetDeviceDescription(pszPnPDeviceID, pDeviceDescription, pcchDeviceDescription)
    GetDeviceManufacturer(pszPnPDeviceID, pDeviceManufacturer, pcchDeviceManufacturer)
    GetDeviceProperty(pszPnPDeviceID, pszDevicePropertyName, pData, pcbData, pdwType)
    GetPrivateDevices(pPnPDeviceIDs, pcPnPDeviceIDs)
  EndInterface
  
  Interface  IPortableDevice Extends IUnknown
    ;{625e2df8-6392-4cf0-9ad1-3cfa5f17775c}
    
    Open(pszPnPDeviceID, pClientInfo)
    SendCommand(dwFlags.l, pParameters, ppResults)
    Content(ppContent)
    Capabilities(ppCapabilities) 
    Cancel()
    Close()
    Advise(dwFlags.l, pCallback, pParameters, ppszCookie)
    Unadvise(pszCookie)
    GetPnPDeviceID(ppszPnPDeviceID)
  EndInterface
  
  Interface IPortableDeviceValues Extends IUnknown
    ;"6848f6f2-3155-4f86-b6f5-263eeeab3143"
    
    GetCount(pcelt)
    GetAt(index.l, pKey, pValue)
    SetValue(key, pValue)
    GetValue(key, pValue)
    SetStringValue(key, LPCWSTRValue)
    GetStringValue(key, pLPWSTRValue)
    SetUnsignedIntegerValue(key, LongValue.l)
    GetUnsignedIntegerValue(key, pLongValue)
    SetSignedIntegerValue(key, LongValue.l)
    GetSignedIntegerValue(key, pLongValue)
    SetUnsignedLargeIntegerValue(key, QuadValue.q)
    GetUnsignedLargeIntegerValue(key, pQuadValue)
    SetSignedLargeIntegerValue(key, QuadValue.q)
    GetSignedLargeIntegerValue(key, pQuadValue)
    SetFloatValue(key, FLOATValue.f)
    GetFloatValue(key, pFLOATpValue)
    SetErrorValue(key, HRESULTLongValue.l)
    GetErrorValue(key, pHRESULTLongValue)
    SetKeyValue(key, REFPROPERTYKEYValue)
    GetKeyValue(key, pPROPERTYKEYValue)
    SetBoolValue(key, BOOLLongValue)
    GetBoolValue(key, pBOOLLongValue)
    SetIUnknownValue(key, pIUnknownValue)
    GetIUnknownValue(key, ppIUnknownValue)
    SetGuidValue(key, REFGUIDValue)
    GetGuidValue(key, pGUIDValue)
    SetBufferValue(key, pValue, cbValue.l)
    GetBufferValue(key, ppValue, pcbValue)
    SetIPortableDeviceValuesValue(key, pValue)
    GetIPortableDeviceValuesValue(key, ppValue)
    SetIPortableDevicePropVariantCollectionValue(key, pValue)
    GetIPortableDevicePropVariantCollectionValue(key, ppValue)
    SetIPortableDeviceKeyCollectionValue(key, pValue)
    GetIPortableDeviceKeyCollectionValue(key, ppValue)
    SetIPortableDeviceValuesCollectionValue(key, pValue)
    GetIPortableDeviceValuesCollectionValue(key, ppValue)
    RemoveValue(key)
    CopyValuesFromPropertyStore(pStore)
    CopyValuesToPropertyStore(pStore)
    Clear()
  EndInterface
  
  Interface  IPortableDevicePropVariantCollection Extends IUnknown
    ;"89b2e422-4f1b-4316-bcef-a44afea83eb3"
    
    GetCount(pcElems)
    GetAt(dwIndex.l, ppValue)
    Add(pValue)
    GetType(ppvt)
    ChangeType(vt.l)
    Clear()
    RemoveAt(dwIndex)
  EndInterface
    
  Interface  IPortableDeviceContent Extends IUnknown
    ;6a96ed84-7c73-4480-9938-bf5af477d426
    
    EnumObjects(dwFlags.l, pszParentObjectID, pFilter, ppEnum)
    Properties(ppProperties)
    Transfer(ppResources)
    CreateObjectWithPropertiesOnly(pValues, ppszObjectID)
    CreateObjectWithPropertiesAndData(pValues, ppData, pdwOptimalWriteBufferSize, ppszCookie)
    Delete(dwOptions.l, pObjectIDs, ppResults)
    GetObjectIDsFromPersistentUniqueIDs(pPersistentUniqueIDs, ppObjectIDs)
    Cancel()
    Move(pObjectIDs, pszDestinationFolderObjectID, ppResults)
    Copy(pObjectIDs, pszDestinationFolderObjectID, ppResults)
  EndInterface
  
  Interface IEnumPortableDeviceObjectIDs Extends IUnknown
    ;10ece955-cf41-4728-bfa0-41eedf1bbf19
    
    Next(cObjects.l, pObjIDs, pcFetched)
    Skip(cObjects.l)
    Reset()
    Clone(ppEnum)
    Cancel()
  EndInterface
  
  Interface IPortableDeviceProperties Extends IUnknown
    ;"7f6d695c-03df-4439-a809-59266beee3a6"
    
    GetSupportedProperties(pszObjectID, ppKeys)
    GetPropertyAttributes(pszObjectID, Key, ppAttributes)
    GetValues(pszObjectID, pKeys, ppValues)
    SetValues(pszObjectID, pValues, ppResults)
    Delete(pszObjectID, pKeys)
    Cancel()
  EndInterface
  
  Interface IPortableDeviceKeyCollection Extends IUnknown
    ;"dada2357-e0ad-492e-98db-dd61c53ba353"
    
    GetCount(pcElems)
    GetAt(dwIndex.l, pKey)
    Add(Key)
    Clear()
    RemoveAt(dwIndex.l)
  EndInterface
  
  Interface IPortableDeviceResources Extends IUnknown
    ;"fd8878ac-d841-4d17-891c-e6829cdb6934"
    
    GetSupportedResources(pszObjectID.s, ppKeys)
    GetResourceAttributes(pszObjectID.s, Key, ppResourceAttributes)
    GetStream(pszObjectID.s, Key, dwMode, pdwOptimalBufferSize, ppStream)
    Delete(pszObjectID, pKeys)
    Cancel()
    CreateResource(pResourceAttributes, ppData, pdwOptimalWriteBufferSize, ppszCookie)
  EndInterface
  
  
  ;---------- Defintions for PROVARIANT Structure
  
  Structure PROPVARIANT_CLIPDATA
    cbSize.l
    ulClipFmt.l
    *pClipData.BYTE
  EndStructure
  
  Structure PROPVARIANT_BSTRBLOB
    cbSize.l
    *pData.BYTE
  EndStructure
  
  Structure PROPVARIANT_BLOB
    cbSize.l
    *pBlobData.BYTE
  EndStructure
  
  Structure PROPVARIANT_VERSIONEDSTREAM
    guidVersion.GUID
    *pStream.IStream
  EndStructure
  
  Structure PROPVARIANT_CAC
    cElems.l
    *pElems.BYTE
  EndStructure
  
  Structure PROPVARIANT_CAUB
    cElems.l
    *pElems.BYTE
  EndStructure
  
  Structure PROPVARIANT_CAI
    cElems.l
    *pElems.WORD
  EndStructure
  
  Structure PROPVARIANT_CAUI
    cElems.l
    *pElems.WORD
  EndStructure
  
  Structure PROPVARIANT_CAL
    cElems.l
    *pElems.LONG
  EndStructure
  
  Structure PROPVARIANT_CAUL
    cElems.l
    *pElems.LONG
  EndStructure
  
  Structure PROPVARIANT_CAFLT
    cElems.l
    *pElems.FLOAT
  EndStructure
  
  Structure PROPVARIANT_CADBL
    cElems.l
    *pElems.DOUBLE
  EndStructure
  
  Structure PROPVARIANT_CACY
    cElems.l
    *pElems.QUAD
  EndStructure
  
  Structure PROPVARIANT_CADATE
    cElems.l
    *pElems.DOUBLE
  EndStructure
  
  Structure PROPVARIANT_CABSTR
    cElems.l
    *pElems.INTEGER
  EndStructure
  
  Structure PROPVARIANT_CABSTRBLOB
    cElems.l
    *pElems.PROPVARIANT_BSTRBLOB
  EndStructure
  
  Structure PROPVARIANT_CABOOL
    cElems.l
    *pElems.WORD
  EndStructure
  
  Structure PROPVARIANT_CASCODE
    cElems.l
    *pElems.LONG
  EndStructure
  
  Structure PROPVARIANT_CAPROPVARIANT
    cElems.l
    *pElems.PROPVARIANT
  EndStructure
  
  Structure PROPVARIANT_CAH
    cElems.l
    *pElems.QUAD
  EndStructure
  
  Structure PROPVARIANT_CAUH
    cElems.l
    *pElems.QUAD
  EndStructure
  
  Structure PROPVARIANT_CALPSTR
    cElems.l
    *pElems.INTEGER
  EndStructure
  
  Structure PROPVARIANT_CALPWSTR
    cElems.l
    *pElems.INTEGER
  EndStructure
  
  Structure PROPVARIANT_CAFILETIME
    cElems.l
    *pElems.FILETIME
  EndStructure
  
  Structure PROPVARIANT_CACLIPDATA
    cElems.l
    *pElems.PROPVARIANT_CLIPDATA
  EndStructure
  
  Structure PROPVARIANT_CACLSID
    cElems.l
    *pElems.CLSID
  EndStructure
  
  Structure PROPVARIANT Align #PB_Structure_AlignC
    vt.w
    wReserved1.w
    wReserved2.w
    wReserved3.w
    StructureUnion
      cVal.b
      bVal.b
      iVal.w
      uiVal.w
      lVal.l
      ulVal.l
      intVal.l
      uintVal.l
      hVal.q
      uhVal.q
      fltVal.f
      dblVal.d
      boolVal.w
      scode.l
      cyVal.q
      date.d
      filetime.FILETIME
      *puuid.CLSID
      *pclipdata.PROPVARIANT_CLIPDATA
      bstrVal.i
      bstrblobVal.PROPVARIANT_BSTRBLOB
      blob.PROPVARIANT_BLOB
      *pszVal
      *pwszVal
      *punkVal.IUnknown
      *pdispVal.IDispatch
      *pStream.IStream
      *pStorage.IStorage
      *pVersionedStream.PROPVARIANT_VERSIONEDSTREAM
      *parray.SAFEARRAY
      cac.PROPVARIANT_CAC
      caub.PROPVARIANT_CAUB
      cai.PROPVARIANT_CAI
      caui.PROPVARIANT_CAUI
      cal.PROPVARIANT_CAL
      caul.PROPVARIANT_CAUL
      cah.PROPVARIANT_CAH
      cauh.PROPVARIANT_CAUH
      caflt.PROPVARIANT_CAFLT
      cadbl.PROPVARIANT_CADBL
      cabool.PROPVARIANT_CABOOL
      cascode.PROPVARIANT_CASCODE
      cacy.PROPVARIANT_CACY
      cadate.PROPVARIANT_CADATE
      cafiletime.PROPVARIANT_CAFILETIME
      cauuid.PROPVARIANT_CACLSID
      caclipdata.PROPVARIANT_CACLIPDATA
      cabstr.PROPVARIANT_CABSTR
      cabstrblob.PROPVARIANT_CABSTRBLOB
      calpstr.PROPVARIANT_CALPSTR
      calpwstr.PROPVARIANT_CALPWSTR
      capropvar.PROPVARIANT_CAPROPVARIANT
      *pcVal.BYTE
      *pbVal.BYTE
      *piVal.WORD
      *puiVal.WORD
      *plVal.LONG
      *pulVal.LONG
      *pintVal.LONG
      *puintVal.LONG
      *pfltVal.FLOAT
      *pdblVal.DOUBLE
      *pboolVal.WORD
      *pdecVal.VARIANT_DECIMAL
      *pscode.LONG
      *pcyVal.QUAD
      *pdate.DOUBLE
      *pbstrVal.INTEGER
      *ppunkVal.INTEGER
      *ppdispVal.INTEGER
      *pparray.INTEGER
      *pvarVal.PROPVARIANT
    EndStructureUnion
  EndStructure

  
  ;---------- Macro Definitions
  
  Macro CoInitialize()
    CoInitializeEx_(0, 0)
    IsInitialised = #True
  EndMacro
  
  Macro CoUninitialize()
    CoUninitialize_()
    IsInitialised = #False
  EndMacro
  
  Macro FAILED(hr)
    hr <> 0
  EndMacro
  
  Macro SUCCEEDED(hr)
    hr = 0
  EndMacro
  
  Macro DEFINE_PROPERTYKEY(Nm, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12)
    Nm:
    Data.l   p1
    Data.w   p2, p3
    Data.b   p4, p5, p6, p7, p8, p9, p10, p11
    Data.l   p12
  EndMacro
  
  Macro DEFINE_GUID(IID, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Data11) 
      IID: 
      Data.l Data1 
      Data.w Data2, Data3 
      Data.b Data4, Data5, Data6, Data7, Data8, Data9, Data10, Data11 
  EndMacro
  
  Macro CompareGuid(Guid1, Guid2)
    CompareMemory(Guid1, Guid2, SizeOf(Guid)) > 0
  EndMacro
  
  
  ;---------- Data Section
  
  DataSection
    ; "{0af10cec-2ecd-4b92-9581-34f6ae0637f3}"
    DEFINE_GUID(CLSID_PortableDeviceManager, $0af10cec, $2ecd, $4b92, $95, $81, $34, $f6, $ae, $06, $37, $f3)
    ; "{a1567595-4c2f-4574-a6fa-ecef917b9a40}"
    DEFINE_GUID(IID_IPortableDeviceManager, $a1567595, $4c2f, $4574, $a6, $fa, $ec, $ef, $91, $7b, $9a, $40)
    ; "{f7c0039a-4762-488a-b4b3-760ef9a1ba9b}"
    DEFINE_GUID(CLSID_PortableDeviceFTM, $f7c0039a, $4762, $488a, $b4, $b3, $76, $0e, $f9, $a1, $ba, $9b)
    ; "{625e2df8-6392-4cf0-9ad1-3cfa5f17775c}"
    DEFINE_GUID(IID_IPortableDevice, $625e2df8, $6392, $4cf0, $9a, $d1, $3c, $fa, $5f, $17, $77, $5c)
    ; "de2d022d-2480-43be-97f0-d1fa2cf98f4f"
    DEFINE_GUID(CLSID_PortableDeviceKeyCollection, $de2d022d, $2480, $43be, $97, $f0, $d1, $fa, $2c, $f9, $8f, $4f)
    ; "0c15d503-d017-47ce-9016-7b3f978721cc"
    DEFINE_GUID(CLSID_PortableDeviceValues, $0c15d503, $d017, $47ce, $90, $16, $7b, $3f, $97, $87, $21, $cc)
    ; "08a99e2f-6d6d-4b80-af5a-baf2bcbe4cb9
    DEFINE_GUID(CLSID_PortableDevicePropVariantCollection, $08a99e2f, $6d6d, $4b80, $af, $5a, $ba, $f2, $bc, $be, $4c, $b9)
    ; "89b2e422-4f1b-4316-bcef-a44afea83eb3"
    DEFINE_GUID(IID_IPortableDevicePropVariantCollection, $89b2e422, $4f1b, $4316, $bc, $ef, $a4, $4a, $fe, $a8, $3e, $b3)
    ; "6848f6f2-3155-4f86-b6f5-263eeeab3143"
    DEFINE_GUID(IID_IPortableDeviceValues, $6848f6f2, $3155, $4f86, $b6, $f5, $26, $3e, $ee, $ab, $31, $43)
    ; "6a96ed84-7c73-4480-9938-bf5af477d426"
    DEFINE_GUID(IID_IPortableDeviceContent, $6a96ed84, $7c73, $4480, $99, $38, $bf, $5a, $f4, $77, $d4, $26)
    ; "DADA2357-E0AD-492E-98DB-DD61C53BA353"
    DEFINE_GUID(IID_IPortableDeviceKeyCollection, $DADA2357, $E0AD, $492E, $98, $DB, $DD, $61, $C5, $3B, $A3, $53)
    ; "27E2E392-A111-48E0-AB0C-E17705A05F85"
    DEFINE_GUID(WPD_CONTENT_TYPE_FOLDER, $27E2E392, $A111, $48E0, $AB, $0C, $E1, $77, $05, $A0, $5F, $85)
    ; "4ad2c85e-5e2d-45e5-8864-4f229e3c6cf0"
    DEFINE_GUID(WPD_CONTENT_TYPE_AUDIO, $4ad2c85e, $5e2d, $45e5, $88, $64, $4f, $22, $9e, $3c, $6c, $f0)
    ; "0085e0a6-8d34-45d7-bc5c-447e59c73d48"
    DEFINE_GUID(WPD_CONTENT_TYPE_GENERIC_FILE, $0085e0a6, $8d34, $45d7, $bc, $5c, $44, $7e, $59, $c7, $3d, $48)
    ; "ef2107d5-a52a-4243-a26b-62d4176d7603"
    DEFINE_GUID(WPD_CONTENT_TYPE_IMAGE, $ef2107d5, $a52a, $4243, $a2, $6b, $62, $d4, $17, $6d, $76, $03)
    ; "9261b03c-3d78-4519-85e3-02c5e1f50bb9"
    DEFINE_GUID(WPD_CONTENT_TYPE_VIDEO, $9261b03c, $3d78, $4519, $85, $e3, $02, $c5, $e1, $f5, $0b, $b9)
    ; "99ED0160-17FF-4C44-9D98-1D7A6F941921"
    DEFINE_GUID(WPD_CONTENT_TYPE_FUNCTIONAL_OBJECT, $99ED0160, $17FF, $4C44, $9D, $98, $1D, $7A, $6F, $94, $19, $21)
    ; "23F05BBC-15DE-4C2A-A55B-A9AF5CE412EF"
    DEFINE_GUID(WPD_FUNCTIONAL_CATEGORY_STORAGE, $23F05BBC, $15DE, $4C2A, $A5, $5B, $A9, $AF, $5C, $E4, $12, $EF)
    ; WPD_OBJECT_FORMAT_ALL = new Guid("c1f62eb2-4bb3-479c-9cfa-05b5f3a57b22")
    DEFINE_GUID(WPD_OBJECT_FORMAT_ALL, $C1F62EB2, $4BB3, $479C, $9C, $FA, $05, $B5, $F3, $A5, $7B, $22)
    ; WPD_CONTENT_TYPE_ALL = new Guid("80e170d2-1055-4a3e-b952-82cc4f8a8689")
    DEFINE_GUID(WPD_CONTENT_TYPE_ALL, $80e170d2, $1055, $4a3e, $ba, $52, $82, $cc, $4f, $8a, $86, $89)
    
    DEFINE_PROPERTYKEY(WPD_CLIENT_NAME,                        $204D9F0C, $2292, $4080, $9F, $42, $40, $66, $4E, $70, $F8, $59, 2)
    DEFINE_PROPERTYKEY(WPD_CLIENT_MAJOR_VERSION,               $204D9F0C, $2292, $4080, $9F, $42, $40, $66, $4E, $70, $F8, $59, 3)
    DEFINE_PROPERTYKEY(WPD_CLIENT_MINOR_VERSION,               $204D9F0C, $2292, $4080, $9F, $42, $40, $66, $4E, $70, $F8, $59, 4)
    DEFINE_PROPERTYKEY(WPD_CLIENT_REVISION,                    $204D9F0C, $2292, $4080, $9F, $42, $40, $66, $4E, $70, $F8, $59, 5)
    DEFINE_PROPERTYKEY(WPD_CLIENT_SECURITY_QUALITY_OF_SERVICE, $204D9F0C, $2292, $4080, $9F, $42, $40, $66, $4E, $70, $F8, $59, 8)
    DEFINE_PROPERTYKEY(WPD_CLIENT_DESIRED_ACCESS,              $204D9F0C, $2292, $4080, $9F, $42, $40, $66, $4E, $70, $F8, $59, 9)
    
    DEFINE_PROPERTYKEY(WPD_OBJECT_ID,                 $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C,  2)
    DEFINE_PROPERTYKEY(WPD_OBJECT_PARENT_ID,          $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C,  3)
    DEFINE_PROPERTYKEY(WPD_OBJECT_NAME,               $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C,  4)
    DEFINE_PROPERTYKEY(WPD_OBJECT_FORMAT,             $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C,  6)
    DEFINE_PROPERTYKEY(WPD_OBJECT_CONTENT_TYPE,       $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C,  7)
    DEFINE_PROPERTYKEY(WPD_OBJECT_ISHIDDEN,           $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C,  9)
    DEFINE_PROPERTYKEY(WPD_OBJECT_ISSYSTEM,           $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C, 10)
    DEFINE_PROPERTYKEY(WPD_OBJECT_SIZE,               $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C, 11)
    DEFINE_PROPERTYKEY(WPD_OBJECT_ORIGINAL_FILE_NAME, $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C, 12)
    DEFINE_PROPERTYKEY(WPD_OBJECT_DATE_CREATED,       $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C, 18)
    DEFINE_PROPERTYKEY(WPD_OBJECT_DATE_MODIFIED,      $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C, 19)
    DEFINE_PROPERTYKEY(WPD_OBJECT_CAN_DELETE,         $EF6B490D, $5CD8, $437A, $AF, $FC, $DA, $8B, $60, $EE, $4A, $3C, 26)
    
    DEFINE_PROPERTYKEY(WPD_STORAGE_CAPACITY,            $01a3057a, $74d6, $4e80, $be, $a7, $dc, $4c, $21, $2c, $e5, $0a, 4)
    DEFINE_PROPERTYKEY(WPD_STORAGE_FREE_SPACE_IN_BYTES, $01a3057a, $74d6, $4e80, $be, $a7, $dc, $4c, $21, $2c, $e5, $0a, 5)
    
    DEFINE_PROPERTYKEY(WPD_FUNCTIONAL_OBJECT_CATEGORY,  $8f052d93, $abca, $4fc5, $a5, $ac, $b0, $1d, $f4, $db, $e5, $98, 2)
    DEFINE_PROPERTYKEY(WPD_RESOURCE_DEFAULT,            $e81e79be, $34f0, $41bf, $b5, $3f, $f1, $a0, $6a, $e8, $78, $42, 0)
    
  EndDataSection
  
  
  DataSection
    StartDevice:
      ; IncludeBinary "WPDLib_device.ico"
      Data.b $00, $00, $01, $00, $01, $00, $10, $10, $00, $00, $00, $00, $00, $00, $68, $04, $00, $00, $16, $00, $00, $00, $28, $00, $00, $00, $10, $00, $00, $00, $20, $00
      Data.b $00, $00, $01, $00, $20, $00, $00, $00, $00, $00, $00, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $DC, $DC
      Data.b $DC, $00, $DC, $DC, $DC, $06, $D7, $D7, $D7, $17, $C9, $C8, $C8, $35, $CB, $CB, $CB, $56, $CB, $CB, $CB, $5B, $C9, $C9, $C9, $5D, $CB, $CA, $CA, $5D, $CA, $CA
      Data.b $CA, $5D, $C8, $C8, $C8, $5D, $C8, $C8, $C8, $5C, $C8, $C8, $C8, $58, $C7, $C6, $C7, $3B, $D7, $D7, $D7, $18, $D9, $D9, $D9, $06, $D9, $D9, $D9, $00, $24, $24
      Data.b $24, $00, $24, $24, $24, $08, $20, $20, $20, $1B, $46, $46, $46, $7C, $95, $94, $94, $F9, $89, $88, $88, $F2, $84, $84, $84, $F3, $8A, $8A, $8A, $F3, $8D, $8C
      Data.b $8C, $F3, $80, $80, $80, $F3, $80, $7F, $7F, $F2, $8E, $8D, $8D, $F9, $4C, $4B, $4B, $B1, $1E, $1E, $1E, $1A, $27, $27, $27, $08, $27, $27, $27, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $01, $20, $20, $20, $00, $3C, $3C, $3C, $6F, $C7, $C6, $C7, $FF, $AB, $AC, $AC, $FF, $96, $97, $97, $FF, $A0, $A1, $A1, $FF, $9F, $A0
      Data.b $A0, $FF, $9C, $9D, $9E, $FF, $A4, $A4, $A4, $FF, $B9, $B8, $B9, $FF, $4C, $4B, $4C, $B4, $1E, $1E, $1E, $00, $27, $27, $27, $00, $27, $27, $27, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $66, $65, $64, $00, $3F, $3E, $3E, $85, $EB, $EC, $EC, $FF, $E6, $EC, $ED, $FF, $EE, $FB, $FB, $FF, $D0, $F0, $F7, $FF, $C1, $E2
      Data.b $EC, $FF, $DC, $F9, $F9, $FF, $D2, $E8, $EB, $FF, $E4, $E5, $E6, $FF, $6B, $6A, $69, $B0, $96, $95, $94, $00, $27, $27, $27, $00, $27, $27, $27, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $88, $88, $87, $00, $54, $54, $53, $85, $E6, $E1, $E0, $FF, $42, $42, $42, $FF, $41, $41, $41, $FF, $53, $53, $53, $FF, $59, $59
      Data.b $59, $FF, $52, $52, $52, $FF, $43, $43, $43, $FF, $E4, $D8, $D4, $FF, $74, $76, $76, $B1, $A3, $A5, $A5, $00, $A3, $A5, $A5, $00, $A3, $A5, $A5, $00, $86, $88
      Data.b $87, $00, $86, $88, $87, $00, $86, $88, $87, $00, $53, $54, $53, $85, $E2, $D6, $D4, $FF, $00, $00, $00, $FF, $00, $00, $00, $FF, $00, $00, $00, $FF, $00, $00
      Data.b $00, $FF, $00, $00, $00, $FF, $00, $00, $00, $FF, $E4, $C9, $BF, $FF, $74, $77, $78, $B1, $A2, $A7, $A9, $00, $A2, $A7, $A9, $00, $A2, $A7, $A9, $00, $88, $8A
      Data.b $89, $00, $88, $8A, $89, $00, $88, $8A, $89, $00, $54, $55, $54, $85, $E3, $D9, $D6, $FF, $1A, $1A, $1A, $FF, $02, $02, $02, $FF, $00, $00, $00, $FF, $00, $00
      Data.b $00, $FF, $03, $03, $03, $FF, $06, $06, $06, $FF, $E5, $CC, $C2, $FF, $75, $78, $7A, $B1, $A4, $A9, $AB, $00, $A4, $A9, $AB, $00, $A4, $A9, $AB, $00, $8D, $8E
      Data.b $8E, $00, $8D, $8E, $8E, $00, $8D, $8E, $8E, $00, $57, $57, $57, $85, $E4, $D9, $D7, $FF, $24, $24, $24, $FF, $35, $35, $35, $FF, $0C, $0C, $0C, $FF, $05, $05
      Data.b $05, $FF, $0D, $0D, $0D, $FF, $0D, $0D, $0D, $FF, $E7, $CF, $C5, $FF, $77, $7A, $7C, $B1, $A7, $AB, $AE, $00, $A7, $AB, $AE, $00, $A7, $AB, $AE, $00, $6C, $6D
      Data.b $6F, $00, $6C, $6D, $6F, $00, $6C, $6D, $6F, $00, $47, $48, $49, $93, $E8, $DD, $DA, $FF, $31, $31, $31, $FF, $3C, $3C, $3C, $FF, $3E, $3E, $3E, $FF, $0C, $0C
      Data.b $0C, $FF, $14, $14, $14, $FF, $16, $16, $16, $FF, $E7, $D2, $C7, $FF, $79, $7B, $7D, $B1, $A9, $AD, $AF, $00, $A9, $AD, $AF, $00, $A9, $AD, $AF, $00, $56, $58
      Data.b $5A, $00, $56, $58, $5A, $00, $56, $58, $5A, $00, $3B, $3C, $3D, $A2, $EA, $DF, $DC, $FF, $3C, $3C, $3C, $FF, $41, $41, $41, $FF, $4C, $4C, $4C, $FF, $41, $41
      Data.b $41, $FF, $1D, $1D, $1D, $FF, $24, $24, $24, $FF, $E8, $D6, $CA, $FF, $7B, $7D, $7E, $B1, $AC, $AF, $B1, $00, $AC, $AF, $B1, $00, $AC, $AF, $B1, $00, $5A, $5C
      Data.b $5E, $00, $5A, $5C, $5E, $00, $5A, $5C, $5E, $00, $3E, $3F, $40, $A2, $EC, $E2, $DE, $FF, $48, $48, $48, $FF, $50, $50, $50, $FF, $53, $53, $53, $FF, $5E, $5E
      Data.b $5E, $FF, $45, $45, $45, $FF, $2E, $2E, $2E, $FF, $EA, $DA, $CE, $FF, $7C, $7E, $80, $B1, $AE, $B1, $B4, $00, $AE, $B1, $B4, $00, $AE, $B1, $B4, $00, $58, $5A
      Data.b $5C, $00, $58, $5A, $5C, $00, $58, $5A, $5C, $00, $3C, $3D, $3F, $A2, $EF, $E4, $E0, $FF, $57, $57, $57, $FF, $61, $61, $61, $FF, $67, $67, $67, $FF, $6B, $6B
      Data.b $6B, $FF, $74, $74, $74, $FF, $49, $49, $49, $FF, $EC, $DF, $D1, $FF, $7E, $80, $82, $B1, $B1, $B3, $B6, $00, $B1, $B3, $B6, $00, $B1, $B3, $B6, $00, $69, $6A
      Data.b $6C, $00, $69, $6A, $6C, $00, $69, $6A, $6C, $00, $45, $46, $47, $96, $EC, $E3, $E0, $FF, $00, $00, $00, $FF, $00, $00, $00, $FF, $00, $00, $00, $FF, $05, $05
      Data.b $05, $FF, $00, $00, $00, $FF, $00, $00, $00, $FF, $EB, $E1, $D4, $FF, $80, $80, $82, $B1, $B3, $B4, $B6, $00, $B3, $B4, $B6, $00, $B3, $B4, $B6, $00, $FF, $FF
      Data.b $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $51, $50, $4F, $86, $E2, $E0, $E0, $FF, $DD, $D6, $D1, $FF, $DE, $D7, $D2, $FF, $D2, $CC, $C7, $FF, $CA, $C4
      Data.b $BF, $FF, $DE, $D8, $D3, $FF, $DB, $D7, $D0, $FF, $E0, $DE, $DC, $FF, $74, $74, $74, $B1, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF
      Data.b $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $3B, $3A, $39, $6C, $9E, $9E, $9E, $F6, $99, $9A, $9B, $F1, $96, $97, $98, $F1, $84, $85, $87, $F1, $76, $77
      Data.b $78, $F1, $99, $9A, $9B, $F1, $93, $94, $96, $F1, $9C, $9C, $9D, $FA, $6B, $69, $69, $94, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF
      Data.b $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF
      Data.b $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF, $FF, $00, $FF, $FF
      Data.b $00, $00, $F0, $07, $00, $00, $F0, $07, $00, $00, $E0, $07, $00, $00, $E0, $07, $00, $00, $E0, $07, $00, $00, $E0, $07, $00, $00, $E0, $07, $00, $00, $E0, $07
      Data.b $00, $00, $E0, $07, $00, $00, $E0, $07, $00, $00, $E0, $07, $00, $00, $E0, $07, $00, $00, $E0, $07, $00, $00, $F0, $07, $00, $00, $FF, $FF, $00, $00

    
    StartStorage:
    ; IncludeBinary "WPDLib_storage.ico"
      Data.b $00, $00, $01, $00, $01, $00, $10, $10, $00, $00, $00, $00, $00, $00, $68, $05, $00, $00, $16, $00, $00, $00, $28, $00, $00, $00, $10, $00, $00, $00, $20, $00
      Data.b $00, $00, $01, $00, $08, $00, $00, $00, $00, $00, $40, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $FF, $FF, $FF, $00, $05, $B4, $C9, $00, $53, $57, $55, $00, $7D, $F2, $FF, $00, $58, $90, $B2, $00, $3D, $E6, $F9, $00, $22, $84, $97, $00, $36, $34
      Data.b $2E, $00, $60, $CC, $D9, $00, $0F, $D7, $EE, $00, $7E, $DB, $E6, $00, $EC, $EE, $EE, $00, $1B, $C5, $D9, $00, $2A, $D5, $E9, $00, $68, $E5, $F4, $00, $42, $42
      Data.b $3E, $00, $95, $F4, $FF, $00, $04, $C8, $DF, $00, $51, $DF, $F1, $00, $01, $9F, $C3, $00, $51, $ED, $FF, $00, $12, $A7, $C8, $00, $52, $D6, $E6, $00, $1D, $D6
      Data.b $EC, $00, $8E, $EC, $F7, $00, $74, $E4, $F1, $00, $89, $F3, $FF, $00, $11, $C1, $D6, $00, $75, $D9, $E5, $00, $41, $EB, $FF, $00, $08, $A3, $C6, $00, $56, $DB
      Data.b $EC, $00, $0D, $B5, $C9, $00, $83, $EF, $FC, $00, $39, $38, $33, $00, $78, $E0, $ED, $00, $70, $E7, $F5, $00, $51, $54, $52, $00, $8D, $F3, $FF, $00, $38, $37
      Data.b $30, $00, $73, $E7, $F5, $00, $24, $85, $98, $00, $8B, $F3, $FF, $00, $52, $56, $54, $00, $00, $A0, $C4, $00, $02, $A0, $C3, $00, $76, $D9, $E4, $00, $53, $56
      Data.b $54, $00, $8A, $F3, $FF, $00, $84, $EF, $FC, $00, $22, $84, $98, $00, $01, $A0, $C3, $00, $01, $A0, $C4, $00, $40, $EB, $FF, $00, $72, $E7, $F5, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $00, $00, $00, $08, $2C, $08, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $08, $26, $08, $00, $00, $08
      Data.b $03, $08, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $08, $03, $08, $00, $00, $08, $03, $08, $05, $05, $05, $05, $05, $05, $05, $05, $08, $03, $08, $00, $00, $08
      Data.b $03, $23, $08, $08, $08, $08, $08, $08, $08, $08, $23, $03, $08, $00, $00, $08, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $08, $00, $00, $08
      Data.b $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $08, $00, $00, $08, $03, $2A, $2E, $2D, $2D, $2D, $2D, $2D, $2D, $34, $33, $03, $08, $00, $00, $08
      Data.b $03, $1F, $32, $19, $0B, $2F, $1A, $29, $29, $13, $35, $03, $08, $00, $00, $08, $03, $16, $31, $36, $0E, $21, $1C, $18, $0A, $25, $2D, $03, $08, $00, $00, $08
      Data.b $03, $16, $2B, $27, $04, $24, $09, $17, $0F, $37, $2D, $03, $08, $00, $00, $08, $03, $16, $1B, $1E, $15, $06, $0D, $02, $12, $29, $2D, $03, $08, $00, $00, $08
      Data.b $03, $1F, $22, $11, $11, $11, $19, $0B, $1D, $20, $35, $03, $08, $00, $00, $08, $03, $2A, $2E, $2D, $2D, $2D, $2D, $2D, $2D, $14, $07, $30, $08, $00, $00, $08
      Data.b $2C, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $10, $00, $00, $00, $00, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $28, $00, $00, $C0, $03
      Data.b $00, $00, $80, $01, $00, $00, $80, $01, $00, $00, $80, $01, $00, $00, $80, $01, $00, $00, $80, $01, $00, $00, $80, $01, $00, $00, $80, $01, $00, $00, $80, $01
      Data.b $00, $00, $80, $01, $00, $00, $80, $01, $00, $00, $80, $01, $00, $00, $80, $01, $00, $00, $80, $01, $00, $00, $80, $03, $00, $00, $C0, $03, $00, $00
    
    StartFolder:
    ; IncludeBinary "WPDLib_folder.ico"
      Data.b $00, $00, $01, $00, $01, $00, $10, $10, $00, $00, $00, $00, $00, $00, $68, $04, $00, $00, $16, $00, $00, $00, $28, $00, $00, $00, $10, $00, $00, $00, $20, $00
      Data.b $00, $00, $01, $00, $20, $00, $00, $00, $00, $00, $00, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $1D, $24, $28, $26, $73, $98, $AD, $58, $8D, $BB, $D5, $55, $98, $C3, $D9, $27, $B0, $D2, $E3, $0A, $FF, $FF
      Data.b $FF, $00, $00, $00, $00, $00, $57, $6F, $7E, $37, $8D, $BC, $D5, $B3, $98, $C4, $DB, $3C, $79, $C6, $F1, $00, $B3, $BB, $BE, $00, $00, $00, $00, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $03, $00, $00, $00, $3B, $37, $45, $4F, $99, $9A, $AD, $B4, $F3, $82, $B1, $CB, $F7, $7D, $B3, $D1, $E0, $83, $B7, $D4, $BB, $88, $BB
      Data.b $D7, $8B, $6A, $8E, $A1, $65, $4D, $64, $71, $82, $82, $B7, $D4, $F4, $83, $B8, $D5, $D2, $94, $BD, $D4, $39, $4C, $8D, $B4, $00, $CE, $E6, $F1, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $24, $00, $00, $00, $68, $3C, $4D, $57, $A5, $B6, $B8, $B2, $FC, $8A, $B5, $CC, $FF, $79, $B3, $D3, $FF, $7B, $B5, $D5, $FF, $7C, $B5
      Data.b $D4, $FF, $67, $96, $AF, $FC, $5B, $7F, $93, $F6, $84, $BB, $D9, $FD, $7C, $B5, $D5, $FF, $7C, $AD, $CA, $D7, $92, $B8, $CF, $38, $7E, $AA, $C4, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $2B, $00, $00, $00, $5D, $42, $55, $61, $97, $C0, $D2, $DB, $FC, $91, $C0, $DA, $FF, $7D, $B8, $D8, $FF, $7F, $BA, $DA, $FF, $7E, $B9
      Data.b $D9, $FF, $66, $96, $B0, $FF, $5C, $82, $97, $FF, $88, $C0, $DE, $FF, $80, $BB, $DC, $FF, $75, $A9, $C8, $FF, $86, $B0, $C9, $7C, $59, $8E, $AF, $00, $00, $00
      Data.b $00, $04, $00, $00, $00, $2A, $00, $00, $00, $4A, $4A, $5E, $6B, $8A, $C3, $D6, $E1, $FC, $98, $C7, $E1, $FF, $81, $BE, $DE, $FF, $82, $BF, $E0, $FF, $7F, $BA
      Data.b $DA, $FF, $64, $93, $AC, $FF, $5D, $84, $99, $FF, $8C, $C4, $E2, $FF, $84, $C1, $E2, $FF, $78, $AF, $CE, $FF, $88, $B3, $CC, $7C, $5F, $95, $B6, $00, $00, $00
      Data.b $00, $0B, $00, $00, $00, $27, $00, $00, $00, $35, $4D, $64, $73, $79, $B5, $D0, $E0, $FA, $9D, $CD, $E6, $FF, $89, $C5, $E4, $FF, $86, $C4, $E5, $FF, $7B, $B4
      Data.b $D2, $FF, $5C, $87, $9E, $FF, $61, $88, $9D, $FF, $92, $C9, $E7, $FF, $88, $C6, $E7, $FF, $7C, $B4, $D4, $FF, $8B, $B7, $D0, $78, $69, $A0, $C0, $00, $00, $00
      Data.b $00, $01, $00, $00, $00, $06, $00, $00, $00, $0F, $30, $3E, $48, $2E, $8E, $B9, $D1, $C9, $9B, $D0, $EB, $FF, $94, $CD, $EB, $FF, $8B, $CA, $EA, $FF, $7B, $B4
      Data.b $D2, $FF, $5B, $85, $9B, $FF, $80, $A9, $C0, $FF, $9E, $D6, $F5, $FF, $8C, $CA, $EB, $FF, $80, $BA, $DA, $FF, $8D, $BA, $D4, $70, $74, $AA, $CA, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $4F, $6C, $85, $00, $00, $00, $00, $02, $95, $BF, $D7, $A7, $A0, $D4, $EE, $FF, $9F, $D4, $EF, $FF, $91, $CE, $EE, $FF, $7E, $B7
      Data.b $D5, $FF, $5D, $86, $9D, $FF, $8E, $B7, $CE, $FF, $A6, $DC, $FB, $FF, $90, $CE, $EF, $FF, $84, $C0, $E0, $FF, $90, $BF, $D8, $66, $7D, $B4, $D2, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $53, $71, $8A, $00, $0C, $00, $0A, $02, $9A, $C3, $DA, $A8, $A4, $D7, $F1, $FF, $AA, $D9, $F3, $FF, $9B, $D3, $F2, $FF, $83, $BA
      Data.b $D8, $FF, $5F, $88, $9F, $FF, $90, $B7, $CE, $FF, $AC, $DF, $FC, $FF, $95, $D2, $F3, $FF, $88, $C5, $E5, $FF, $93, $C3, $DD, $62, $84, $BB, $D9, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $55, $72, $8C, $00, $2D, $2F, $3F, $03, $9E, $C6, $DD, $AD, $A9, $D9, $F4, $FF, $B1, $DE, $F6, $FF, $A8, $DA, $F6, $FF, $89, $BE
      Data.b $DB, $FF, $61, $8A, $A1, $FF, $92, $B7, $CD, $FF, $B1, $E2, $FD, $FF, $9B, $D5, $F6, $FF, $8B, $C9, $E9, $FF, $96, $C8, $E2, $62, $89, $C1, $DF, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $55, $72, $8C, $00, $44, $51, $64, $05, $A2, $CA, $E1, $B4, $AD, $DC, $F7, $FF, $B6, $E0, $F8, $FF, $B6, $E1, $F9, $FF, $90, $C2
      Data.b $DF, $FF, $65, $8C, $A3, $FF, $94, $B8, $CE, $FF, $B6, $E4, $FE, $FF, $A0, $D9, $F9, $FF, $8F, $CC, $ED, $FF, $9A, $CC, $E6, $61, $8E, $C6, $E4, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $54, $72, $8C, $00, $4B, $5F, $74, $07, $A5, $CC, $E3, $BB, $B2, $DF, $F9, $FF, $B9, $E2, $FA, $FF, $C1, $E6, $FB, $FF, $9C, $C8
      Data.b $E1, $FF, $69, $8F, $A5, $FF, $96, $B9, $CE, $FF, $BA, $E5, $FE, $FF, $A4, $DB, $FB, $FF, $93, $CF, $F0, $FE, $9D, $CE, $E8, $5E, $93, $C9, $E6, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $5D, $7B, $93, $00, $56, $6D, $82, $0A, $A8, $CD, $E4, $C0, $B6, $E2, $FB, $FF, $BB, $E4, $FC, $FF, $C8, $EA, $FD, $FF, $AC, $D2
      Data.b $E7, $FF, $71, $98, $AE, $FF, $9A, $BB, $CF, $FF, $BF, $E7, $FF, $FF, $A8, $DD, $FC, $FF, $97, $D2, $F3, $FD, $9F, $CF, $E9, $58, $97, $CC, $E9, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $60, $7E, $96, $00, $5A, $73, $89, $0B, $A9, $CE, $E5, $C4, $BA, $E5, $FD, $FF, $BC, $E5, $FD, $FF, $CC, $EB, $FE, $FF, $C4, $E4
      Data.b $F7, $FF, $95, $C2, $DB, $FF, $A4, $C7, $DD, $FF, $C4, $E8, $FE, $FF, $AC, $DF, $FD, $FF, $9C, $D5, $F6, $FB, $A1, $D2, $ED, $4F, $9B, $CF, $EC, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $58, $77, $8F, $00, $39, $53, $6C, $04, $A1, $C3, $D8, $70, $B5, $DA, $F0, $BB, $B8, $DE, $F5, $D4, $C9, $E6, $F8, $E8, $CD, $E9
      Data.b $FA, $F4, $B5, $E0, $F9, $FB, $A6, $D4, $EF, $FE, $B4, $DC, $F4, $FF, $AD, $DD, $F9, $FF, $A1, $D8, $F7, $F9, $A4, $D5, $F0, $4A, $9F, $D3, $EF, $00, $00, $00
      Data.b $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $44, $4F, $5C, $00, $2B, $31, $3B, $00, $84, $9D, $AE, $09, $9E, $BC, $CF, $1A, $AE, $CA, $DC, $31, $B6, $D2
      Data.b $E3, $4C, $B1, $D4, $E9, $66, $A3, $D1, $EC, $82, $A1, $CE, $E9, $9D, $A1, $CE, $E8, $B1, $A2, $CF, $E8, $BE, $A9, $D3, $EA, $3A, $A5, $D1, $E9, $00, $FF, $EF
      Data.b $00, $00, $E0, $47, $00, $00, $E0, $03, $00, $00, $E0, $03, $00, $00, $E0, $03, $00, $00, $F0, $03, $00, $00, $F0, $03, $00, $00, $F0, $03, $00, $00, $F0, $03
      Data.b $00, $00, $F0, $03, $00, $00, $F0, $03, $00, $00, $F0, $03, $00, $00, $F0, $03, $00, $00, $F0, $03, $00, $00, $F8, $03, $00, $00, $FF, $C3, $00, $00
  EndDataSection
  
  
  ;---------- Constants, Structures and Variables
  
  #PORTABLE_DEVICE_DELETE_NO_RECURSION    = 0
  #PORTABLE_DEVICE_DELETE_WITH_RECURSION  = 1
  #VT_LPWSTR = 31
  #SECURITY_IMPERSONATION = 2

  
  Structure sDeviceInformation
    FriendlyName.s
    Description.s
    Manufacturer.s
    device.IPortableDevice
    clientInformation.IPortableDeviceValues
    keys.IPortableDeviceKeyCollection
    content.IPortableDeviceContent
  EndStructure
  
  
  Define NewMap Devices.sDeviceInformation()
  Define IsInitialised.b=#False
  Define LastErrorMessage.s=""
  Define CurrentDirectory.s=""
  
  
  ;---------- Internal Procedures
  

  ; Internal Procedure to set the client information
  Procedure.b SetClientInformation(DeviceID.s, Client_Name.s, Client_Major_Ver.i, Client_Minor_Ver.i)
    Shared LastErrorMessage.s, Devices.sDeviceInformation()
    Protected hr.i
        
    LastErrorMessage = ""
    hr = CoCreateInstance_(?CLSID_PortableDeviceValues, 0, #CLSCTX_INPROC_SERVER, ?IID_IPortableDeviceValues, @Devices(DeviceID)\clientInformation)
    If FAILED(hr)
      LastErrorMessage = "Failed to CoCreateInstance CLSID_PortableDeviceValues"
      ProcedureReturn #False
    EndIf
    hr = Devices(DeviceID)\clientInformation\SetStringValue(?WPD_CLIENT_NAME, @Client_Name)
    If FAILED(hr)
      LastErrorMessage = "Failed to set WPD_CLIENT_NAME"
      ProcedureReturn #False
    EndIf
    hr = Devices()\clientInformation\SetUnsignedIntegerValue(?WPD_CLIENT_MAJOR_VERSION, Client_Major_Ver)
    hr = Devices()\clientInformation\SetUnsignedIntegerValue(?WPD_CLIENT_MINOR_VERSION, Client_Minor_Ver)
    hr = Devices()\clientInformation\SetUnsignedIntegerValue(?WPD_CLIENT_REVISION, 0)
    hr = Devices()\clientInformation\SetUnsignedIntegerValue(?WPD_CLIENT_SECURITY_QUALITY_OF_SERVICE, #SECURITY_IMPERSONATION)
    ProcedureReturn #True
  EndProcedure
  
  
  ; Convert Windows filetime to PurBasic Date
  Procedure.i toDate(Filedate.d)
    Protected SystemTime.SYSTEMTIME
    
    If Not VariantTimeToSystemTime_(Filedate, @SystemTime)
      ProcedureReturn 0
    EndIf
    ProcedureReturn Date(SystemTime\wYear, SystemTime\wMonth, SystemTime\wDay, SystemTime\wHour, SystemTime\wMinute, SystemTime\wSecond)
  EndProcedure
  
  
  ; Joins two elements to a path
  Procedure.s JoinPath(Path.s, Entry.s)
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      Protected.s SEPARATOR = "\"
    CompilerElse
      Protected.s SEPARATOR = "/"
    CompilerEndIf
    
    If Right(Path, 1) <> SEPARATOR And Path <> "" And Right(Path, 1) <> ":" : Path + SEPARATOR : EndIf
    If Left(Entry, 1) = SEPARATOR And Right(Path, 1) = SEPARATOR : Entry = Mid(Entry, 2) : EndIf
    ProcedureReturn Path + Entry
  EndProcedure
  
  
  ; create full qualified Directory or File Name.
  ; returns "" if Name not full qualified
  Procedure.s createFullQualifiedName(Name.s)
    Shared LastErrorMessage.s, CurrentDirectory.s
    
    Name = ReplaceString(Name, "/", "\")
    If Left(Name, 2) <> "\\" : Name = JoinPath(CurrentDirectory, Name) : EndIf
    If Left(Name, 2) <> "\\"
      LastErrorMessage = "Directory or Filename '" + Name + "' is not full qualified, not starting with \\"
      ProcedureReturn ""
    EndIf
    ProcedureReturn Name
  EndProcedure
  

  
  ;---------- External Procedures
 
  
  ; Return last error message
  Procedure.s GetErrorMessage()
    Shared LastErrorMessage.s
    
    ProcedureReturn LastErrorMessage
  EndProcedure
  
  ; Clears last error message
  Procedure ClearErrorMessage()
    Shared LastErrorMessage.s
    
    LastErrorMessage = ""
  EndProcedure
  
  
  ; Close devices and free all memory
  Procedure close()
    Shared Devices.sDeviceInformation(), LastErrorMessage.s, IsInitialised.b
    
    ; Alle geöffneten Devices wieder schliessen
    ForEach Devices()
      If Devices()\device <> #NUL
        Devices()\device\Close()
        Devices()\device\Release()
      EndIf
      If Devices()\clientInformation <> #NUL
        Devices()\clientInformation\Release()
        Devices()\clientInformation = #NUL
      EndIf
      If Devices()\keys <> #NUL
        Devices()\keys\Release()
      EndIf
      If Devices()\content <> #NUL
        Devices()\content\Release()
      EndIf
    Next
    ; Speicher freigeben    
    ClearMap(Devices())
    LastErrorMessage = ""
    CoUninitialize()
    IsInitialised = #False
  EndProcedure

  
  ; Opens the portable Devices Interface
  Procedure.b open(Client_Name.s, Client_Major_Ver.i, Client_Minor_Ver.i)
    Shared IsInitialised.b, LastErrorMessage.s, Devices.sDeviceInformation()
    Protected deviceManager.IPortableDeviceManager
    Protected hr.l, pnpDeviceIDCount.l, retrievedDeviceIDCount.l, sl.i=124, index.l, DeviceID.s
    Protected S.s{124}
    
    If IsInitialised : close() : EndIf
    ; Initialiase the COM System
    CoInitialize()
    ; Initialise Variables
    LastErrorMessage = ""
    ; Create Instanze of CLSID_PortableDeviceManager
    hr = CoCreateInstance_(?CLSID_PortableDeviceManager, 0, #CLSCTX_INPROC_SERVER, ?IID_IPortableDeviceManager, @deviceManager)
    If FAILED(hr)
      LastErrorMessage = "Failed to CoCreateInstance CLSID_PortableDeviceManager. Returncode=0x" + Hex(hr)
      close()
      ProcedureReturn #False
    EndIf
    ; Get number of devices
    hr = deviceManager\GetDevices(0, @pnpDeviceIDCount)
    If FAILED(hr)
      LastErrorMessage = "Failed to get number of devices on the system."
      deviceManager\Release()
      close()
      ProcedureReturn #False
    EndIf
    ; If portable devices where found, get the properties
    If pnpDeviceIDCount > 0
      Dim pnpDeviceIDs.i(pnpDeviceIDCount)
      retrievedDeviceIDCount = pnpDeviceIDCount
      hr = deviceManager\GetDevices(@pnpDeviceIDs(0), @retrievedDeviceIDCount)
      If SUCCEEDED(hr)
        For index = 0 To retrievedDeviceIDCount -1
          DeviceID = PeekS(pnpDeviceIDs(index))
          deviceManager\GetDeviceFriendlyName(pnpDeviceIDs(index), @s, @sl)
          Devices(DeviceID)\FriendlyName = s
          S = ""
          sl = 124
          deviceManager\GetDeviceDescription(pnpDeviceIDs(index), @s, @sl)
          Devices(DeviceID)\Description = s
          S = ""
          sl = 124
          deviceManager\GetDeviceManufacturer(pnpDeviceIDs(index), @s, @sl)
          Devices(DeviceID)\Manufacturer = s
          Devices(DeviceID)\device = #NUL
          Devices(DeviceID)\clientInformation = #NUL
          Devices(DeviceID)\keys = #NUL
          SetClientInformation(DeviceID, Client_Name, Client_Major_Ver, Client_Minor_Ver)
          CoTaskMemFree_(pnpDeviceIDs(index))
          ; Open device
          hr = CoCreateInstance_(?CLSID_PortableDeviceFTM, 0, #CLSCTX_INPROC_SERVER, ?IID_IPortableDevice, @Devices(DeviceID)\device)
          If SUCCEEDED(hr)
            hr = Devices(DeviceID)\device\Open(@DeviceID, Devices(DeviceID)\clientInformation)
            If hr = $80070005   ; E_ACCESSDENIED
              Devices(DeviceID)\clientInformation\SetUnsignedIntegerValue(?WPD_CLIENT_DESIRED_ACCESS, #GENERIC_READ)
              hr = Devices(DeviceID)\device\Open(@DeviceID, Devices(DeviceID)\clientInformation)
            EndIf
          EndIf
          If FAILED(hr)
            LastErrorMessage = "Failed to open the device"
            ProcedureReturn #False
          EndIf
          hr = CoCreateInstance_(?CLSID_PortableDeviceKeyCollection, 0, #CLSCTX_INPROC_SERVER, ?IID_IPortableDeviceKeyCollection, @Devices(DeviceID)\keys)
          If FAILED(hr)
            LastErrorMessage = "Failed to get CLSID_PortableDeviceKeyCollection"
            ProcedureReturn #False
          EndIf
          Devices(DeviceID)\keys\Add(?WPD_OBJECT_CONTENT_TYPE)
          Devices(DeviceID)\keys\Add(?WPD_FUNCTIONAL_OBJECT_CATEGORY)
          Devices(DeviceID)\keys\Add(?WPD_OBJECT_ID)
          Devices(DeviceID)\keys\Add(?WPD_OBJECT_NAME)
          Devices(DeviceID)\keys\Add(?WPD_OBJECT_ORIGINAL_FILE_NAME)
          Devices(DeviceID)\keys\Add(?WPD_OBJECT_SIZE)
          Devices(DeviceID)\keys\Add(?WPD_OBJECT_DATE_MODIFIED)
          Devices(DeviceID)\keys\Add(?WPD_OBJECT_DATE_CREATED)
          Devices(DeviceID)\keys\Add(?WPD_STORAGE_CAPACITY)
          Devices(DeviceID)\keys\Add(?WPD_STORAGE_FREE_SPACE_IN_BYTES)
          ; Content Memory besorgen
          hr = Devices(DeviceID)\device\Content(@Devices(DeviceID)\content)
          If FAILED(hr)
            LastErrorMessage = "Failed to get IPortableDeviceContent from IPortableDevice"
            ProcedureReturn #False
          EndIf
        Next 
      EndIf
    EndIf
    deviceManager\Release()
    ProcedureReturn #True
  EndProcedure
  
  
  ; Get a List of all attached devices
  Procedure getDevices(List DeviceList.sDeviceEntry())
    Shared Devices.sDeviceInformation()
    
    ClearList(DeviceList())
    ForEach Devices()
      AddElement(DeviceList())
      DeviceList()\FriendlyName = Devices()\FriendlyName
      DeviceList()\Manufacturer = Devices()\Manufacturer
      DeviceList()\ID = MapKey(Devices())
    Next
  EndProcedure

  
  ; Get content of a Storage or Directory as List defined by the ID of the parent directory
  ; Use "" as ID for the root of the device.
  ; Use the DeviceID returned in DeviceList from by getDevies
  ; 
  ; Return #False in case of an error
  Procedure.b GetDirectoryById(DeviceID.s, DirectoryID.s, List DirectoryList.sDirectoryEntry())
    Shared Devices.sDeviceInformation(), LastErrorMessage.s
    Protected *DevicePtr.sDeviceInformation, *pointer
    Protected properties.IPortableDeviceProperties, enumObjectIDs.IEnumPortableDeviceObjectIDs
    Protected values.IPortableDeviceValues, contentType.Guid, functionalType.Guid
    Protected amountObjectIdiGot.u, EntryType.i, FileSize.q, DateModified.q, PropVar.PROPVARIANT, lInt.q, hr.i
    Protected Dim objectIDi.i(1)
    
    LastErrorMessage = ""
    ClearList(DirectoryList())
    If DirectoryID = "" : DirectoryID = "DEVICE" : EndIf
    
    ; Does the deviceID exist?
    *DevicePtr = FindMapElement(Devices(), DeviceID)
    If *DevicePtr = #Null
      LastErrorMessage = "DeviceID not found in portable devices."
      ProcedureReturn #False
    EndIf
    
    *DevicePtr\content\Properties(@properties)
    hr = *DevicePtr\content\EnumObjects(0, @DirectoryID, 0, @enumObjectIDs)
    If (FAILED(hr))
      LastErrorMessage = "Failed to get IEnumPortableDeviceObjectIDs from IPortableDeviceContent. Errorcode: $" + Hex(hr)
      ProcedureReturn #False
    EndIf
    
    ; Enumerate the enumObjectIDs we got
    objectIDi(0) = 0
    While #True
      ; Speicher freigeben wenn er durch den Schleifendurchlauf vorher bereits reserviert wurde
      If objectIDi(0) <> 0 : CoTaskMemFree_(objectIDi(0)) : EndIf
      ; Nächstes Element laden, wenn keines mehr da, Schleife verlassen
      enumObjectIDs\Next(1, @objectIDi(0), @amountObjectIdiGot) 
      If amountObjectIdiGot = 0 : objectIDi(0) = 0 : Break : EndIf
      EntryType = #WPD_Undefined
      ; Wrap objects
      ; Bestimme die Values des Objectes anhand er Keys
      properties\GetValues(objectIDi(0), *DevicePtr\keys, @values)
      hr = values\GetGuidValue(?WPD_OBJECT_CONTENT_TYPE, @contentType)
      If FAILED(hr)
        LastErrorMessage = "Could not get content type"
        Break
      EndIf
      If CompareGuid(contentType, ?WPD_FUNCTIONAL_CATEGORY_STORAGE)
        EntryType = #WPD_Storage
      ElseIf CompareGuid(contentType, ?WPD_CONTENT_TYPE_FUNCTIONAL_OBJECT)
        EntryType = #WPD_Storage
        ; Get Type of content, use only storage
        hr = values\GetGuidValue(?WPD_FUNCTIONAL_OBJECT_CATEGORY, @functionalType)
        If Not CompareGuid(functionalType, ?WPD_FUNCTIONAL_CATEGORY_STORAGE)
          EntryType = #WPD_Undefined
        EndIf
      ElseIf CompareGuid(contentType, ?WPD_CONTENT_TYPE_FOLDER)
        EntryType = #WPD_Directory
      ElseIf CompareGuid(contentType, ?WPD_CONTENT_TYPE_AUDIO) Or CompareGuid(contentType, ?WPD_CONTENT_TYPE_GENERIC_FILE) Or 
             CompareGuid(contentType, ?WPD_CONTENT_TYPE_IMAGE) Or CompareGuid(contentType, ?WPD_CONTENT_TYPE_VIDEO)
        EntryType = #WPD_File
      EndIf
      ; Nur bekannte Einträge übernehmen
      If #True    ; EntryType <> #WPD_Undefined
        AddElement(DirectoryList())
        DirectoryList()\Typ = EntryType
        hr = values\GetStringValue(?WPD_OBJECT_ORIGINAL_FILE_NAME, @*pointer)
        If hr = $80070032
          hr = values\GetStringValue(?WPD_OBJECT_NAME, @*pointer)
        EndIf
        If FAILED(hr)
          LastErrorMessage = "Could not get filename. returncode=0x" + Hex(hr)
          Break
        EndIf
        DirectoryList()\Name = PeekS(*Pointer)
        CoTaskMemFree_(*pointer)
        hr = values\GetStringValue(?WPD_OBJECT_ID, @*pointer)
        If FAILED(hr)
          LastErrorMessage = "Could not get object ID"
          Break
        EndIf
        DirectoryList()\ID = PeekS(*Pointer)
        CoTaskMemFree_(*pointer)
        hr = values\GetUnsignedLargeIntegerValue(?WPD_OBJECT_SIZE, @FileSize)
        If hr = $80070032
          DirectoryList()\FileSize = 0
        ElseIf FAILED(hr)
          LastErrorMessage = "Could not get filesize; returncode=0x" + Hex(hr)
          Break
        Else
          DirectoryList()\FileSize = FileSize
        EndIf
        hr = values\GetValue(?WPD_OBJECT_DATE_MODIFIED, @PropVar)
        If hr = $80070490
          hr = values\GetFloatValue(?WPD_OBJECT_DATE_CREATED, @PropVar)
        EndIf
        If hr = $80070032 Or hr = $80070490
          DirectoryList()\LastWriteTime = 0
        ElseIf FAILED(hr)
          LastErrorMessage = "Could not get date modified (" + DirectoryList()\Name + "); returncode=0x" + Hex(hr)
          Break
        Else
          DirectoryList()\LastWriteTime = toDate(PropVar\dblVal)
          PropVariantClear_(@PropVar)
        EndIf
        If EntryType = #WPD_Storage
          values\GetUnsignedLargeIntegerValue(?WPD_STORAGE_CAPACITY, @lInt)
          DirectoryList()\StorageCapacity = lInt
          values\GetUnsignedLargeIntegerValue(?WPD_STORAGE_FREE_SPACE_IN_BYTES, @lInt)
          DirectoryList()\StorageFreeSpace = lInt          
        Else
          DirectoryList()\StorageCapacity = 0
          DirectoryList()\StorageFreeSpace = 0
        EndIf
      EndIf
    Wend
    ; Free memory wenn belegt
    If objectIDi(0) <> 0 : CoTaskMemFree_(objectIDi(0)) : EndIf
    ; Free memory
    enumObjectIDs\Release()
    SortStructuredList(DirectoryList(), #PB_Sort_Ascending, OffsetOf(sDirectoryEntry\Name), #PB_String)
    ProcedureReturn Bool(LastErrorMessage = "")
  EndProcedure
  
  
  ; get the DeviceID from the list of devices. DirectoryName must be full qualified
  Procedure.s GetDeviceIDByName(DirectoryName.s)
    Shared IsInitialised.b, LastErrorMessage.s, Devices.sDeviceInformation(), CurrentDirectory.s
    Protected DeviceName.s, lDeviceName.s, DeviceID.s=""
    
    ; Open MTP Devices if not open. Use 1.0 as Version Numbers
    If Not IsInitialised : open(GetFilePart(ProgramFilename(), #PB_FileSystem_NoExtension), 1, 0) : EndIf
    ; Search Device ID bei DeviceName
    DeviceName = StringField(DirectoryName, 3, "\")
    lDeviceName = LCase(DeviceName)
    ForEach Devices()
      If lDevicename = LCase(Devices()\FriendlyName)
        DeviceID = MapKey(Devices())
        Break
      EndIf
    Next
    If DeviceID = ""
      LastErrorMessage = "Device '" + DeviceName + "' nicht gefunden."
    EndIf
    ProcedureReturn DeviceID
  EndProcedure

  
  ; Searches through all directories and returns in DirectoryList the content of DirectoryName
  ; return #True when found else #False
  Procedure.b GetDirectoryByName(DirectoryName.s, List DirectoryList.sDirectoryEntry())
    Shared IsInitialised.b, LastErrorMessage.s, Devices.sDeviceInformation(), CurrentDirectory.s
    Protected DeviceName.s, lDeviceName.s, FieldIndex=3, Verzeichnisname.s, VerzeichnisID.s="", DeviceID.s
    
    ClearList(DirectoryList())
    DirectoryName = createFullQualifiedName(DirectoryName)
    If DirectoryName = ""
      ProcedureReturn #False
    EndIf
    DeviceID = GetDeviceIDByName(DirectoryName)
    If DeviceID = ""
      ProcedureReturn #False
    EndIf
    ; Search through directory tree to find dir we are looking for
    While #True
      ; Get Directory, on Error return #False
      If Not getDirectoryById(DeviceID, VerzeichnisID, DirectoryList())
        ClearList(DirectoryList())
        ProcedureReturn #False
      EndIf
      FieldIndex + 1
      Verzeichnisname = LCase(StringField(DirectoryName, FieldIndex, "\"))
      If Verzeichnisname = ""
        ; Return the list we just got
        ProcedureReturn #True
      EndIf
      ; Search in DirecoryList for the directory
      VerzeichnisID = ""
      ForEach DirectoryList()
        If LCase(DirectoryList()\Name) = Verzeichnisname
          VerzeichnisID = DirectoryList()\ID
          Break
        EndIf
      Next
      ; Return #False if not found
      If VerzeichnisID = ""
        ClearList(DirectoryList())
        ProcedureReturn #False
      EndIf
    Wend
    ClearList(DirectoryList())
    ProcedureReturn #False
  EndProcedure
    
  
  ; Get Current Directory on MTP device
  Procedure.s GetCurrentDirectoryByName()
    Shared CurrentDirectory.s
    
    ProcedureReturn CurrentDirectory
  EndProcedure
    

  ; Set Current Directory on MTP device to the given directory
  Procedure.i SetCurrentDirectoryByName(DirectoryName.s)
    Shared CurrentDirectory.s, LastErrorMessage.s
    Protected rwert.i=#False
    Protected NewList DirectoryList.sDirectoryEntry()
    
    DirectoryName = createFullQualifiedName(DirectoryName)
    If DirectoryName = ""
      ProcedureReturn #False
    EndIf
    ; Check if dir exists
    If getDirectoryByName(DirectoryName, DirectoryList())
      rwert = #True
      CurrentDirectory = DirectoryName
    EndIf
    ProcedureReturn rwert
  EndProcedure
    

  ; Creates a new directory
  Procedure.i CreateDirectoryByName(DirectoryName.s)
    Shared Devices.sDeviceInformation(), LastErrorMessage.s
    Protected DeviceID.s, VerzeichnisID.s="", LastVerzeichnisID.s="", Verzeichnisname.s, FieldIndex.i=3, hr.i
    Protected deviceValues.IPortableDeviceValues
    Protected *pszNewlyCreatedObject=#NUL
    Protected NewList DirectoryList.sDirectoryEntry()
    
    DirectoryName = createFullQualifiedName(DirectoryName)
    If DirectoryName = ""
      ProcedureReturn #False
    EndIf
    DeviceID = GetDeviceIDByName(DirectoryName)
    If DeviceID = ""
      ProcedureReturn #False
    EndIf
    ; Search through directory tree to find dir we are looking for
    LastVerzeichnisID = VerzeichnisID
    While #True
      ; Get Directory, on Error return error
      If Not getDirectoryById(DeviceID, VerzeichnisID, DirectoryList())
        ProcedureReturn #False
      EndIf
      FieldIndex + 1
      Verzeichnisname = LCase(StringField(DirectoryName, FieldIndex, "\"))
      If Verzeichnisname = ""
        ProcedureReturn #True
      EndIf
      ; Search in DirectoryList for the directory
      VerzeichnisID = ""
      ForEach DirectoryList()
        If LCase(DirectoryList()\Name) = Verzeichnisname
          VerzeichnisID = DirectoryList()\ID
          Break
        EndIf
      Next
      ; create new directory, if searched dir not found
      If VerzeichnisID = ""
        ; Content Memory für Values besorgen
        hr = CoCreateInstance_(?CLSID_PortableDeviceValues, 0, #CLSCTX_INPROC_SERVER, ?IID_IPortableDeviceValues, @deviceValues)
        If FAILED(hr)
          LastErrorMessage = "Failed to CoCreateInstance CLSID_PortableDeviceValues. Returncode=0x" + Hex(hr)
          ProcedureReturn #False
        EndIf
        ; set Values
        hr = deviceValues\SetStringValue(?WPD_OBJECT_PARENT_ID, @LastVerzeichnisID)
        Verzeichnisname = StringField(DirectoryName, FieldIndex, "\")
        hr = deviceValues\SetStringValue(?WPD_OBJECT_NAME, @Verzeichnisname)
        hr = deviceValues\SetStringValue(?WPD_OBJECT_ORIGINAL_FILE_NAME, @Verzeichnisname)
        hr = deviceValues\SetGuidValue(?WPD_OBJECT_CONTENT_TYPE, ?WPD_CONTENT_TYPE_FOLDER)
        hr = Devices(DeviceID)\content\CreateObjectWithPropertiesOnly(deviceValues, @*pszNewlyCreatedObject)
        If FAILED(hr)
          LastErrorMessage = "Failed to create directory: " + Verzeichnisname + " Returncode=0x" + Hex(hr)
          deviceValues\Release()
          ProcedureReturn #False
        EndIf
        LastVerzeichnisID = PeekS(*pszNewlyCreatedObject)
        deviceValues\Release()
        CoTaskMemFree_(*pszNewlyCreatedObject)
      Else
        LastVerzeichnisID = VerzeichnisID
      EndIf
    Wend
    ProcedureReturn #False
  EndProcedure
    

  ; Removes a directory including content
  Procedure.i RemoveDirectoryByName(DirectoryName.s)
    Shared Devices.sDeviceInformation(), LastErrorMessage.s
    Protected DeviceID.s, VerzeichnisID.s="", Verzeichnisname.s, FieldIndex.i=3, hr.i
    Protected pv.PROPVARIANT
    Protected ListeVerzeichnisIDs.IPortableDevicePropVariantCollection
    Protected NewList DirectoryList.sDirectoryEntry()
    
    DirectoryName = createFullQualifiedName(DirectoryName)
    If DirectoryName = ""
      ProcedureReturn #False
    EndIf
    DeviceID = GetDeviceIDByName(DirectoryName)
    If DeviceID = ""
      ProcedureReturn #False
    EndIf
    ; Search through directory tree to find the dir we are looking for
    While #True
      ; Get Directory, on Error return error
      If Not getDirectoryById(DeviceID, VerzeichnisID, DirectoryList())
        ProcedureReturn #False
      EndIf
      FieldIndex + 1
      Verzeichnisname = LCase(StringField(DirectoryName, FieldIndex, "\"))
      If Verzeichnisname = ""
        ProcedureReturn #True
      EndIf
      ; Search in DirectoryList for the directory
      VerzeichnisID = ""
      ForEach DirectoryList()
        If LCase(DirectoryList()\Name) = Verzeichnisname
          VerzeichnisID = DirectoryList()\ID
          Break
        EndIf
      Next
      ; Wenn Verzeichnis in der Liste gefunden wurde, und dies das letzte Verzeichnis im Directorynamen ist,
      ; dann haben wir das Verzeichnis das gelöscht werden soll.
      If VerzeichnisID <> "" And StringField(DirectoryName, FieldIndex+1, "\") = ""
        hr = CoCreateInstance_(?CLSID_PortableDevicePropVariantCollection, 0, #CLSCTX_INPROC_SERVER, ?IID_IPortableDevicePropVariantCollection, @ListeVerzeichnisIDs)
        If FAILED(hr)
          LastErrorMessage = "Failed to CoCreateInstance CLSID_PortableDevicePropVariantCollection. Returncode=0x" + Hex(hr)
          ProcedureReturn #False
        EndIf
        ; Die folgenden Zeilen entsprechen der C Funktion: InitPropVariantFromString
        pv\vt = #VT_LPWSTR
        pv\pwszVal = @VerzeichnisID
        ListeVerzeichnisIDs\Add(@pv)
        hr = Devices(DeviceID)\content\Delete(#PORTABLE_DEVICE_DELETE_WITH_RECURSION, ListeVerzeichnisIDs, 0)
        ListeVerzeichnisIDs\Release()
        If FAILED(hr) Or hr <> #S_OK
          LastErrorMessage = "Failed to delete directory: " + Verzeichnisname + " Returncode=0x" + Hex(hr)
          ProcedureReturn #False
        Else
          ProcedureReturn #True
        EndIf
      EndIf
    Wend
    ProcedureReturn #False
  EndProcedure
  
  
  ; Removes a File
  Procedure.i RemoveFileByName(DirectoryName.s)
    Shared LastErrorMessage.s
    
    If Not RemoveDirectoryByName(DirectoryName)
      ReplaceString(LastErrorMessage, "directory", "file")
      ProcedureReturn #False
    EndIf
    ProcedureReturn #True
  EndProcedure
  
  
  ; Copies a file to an WPD device
  Procedure.i CopyFileToDevice(SourceFilename.s, DestinationFilename.s)
    Shared Devices.sDeviceInformation(), LastErrorMessage.s
    Protected DeviceID.s, VerzeichnisID.s="", DestinationDirectory.s, Verzeichnisname.s, FieldIndex.i=3, SoureFile.i
    Protected *ContentType, *Buffer, DestinationOnlyFilename.s, DestinationOnlyFilenameWithoutExtension.s, tempStream.IStream
    Protected optimalTransferSizeBytes.l, AnzahlGelesen.l, IstreamRwert.i, bytesWritten.l, ContentType.i, hr.i
    Protected pv.PROPVARIANT, deviceValues.IPortableDeviceValues
    Protected ListeVerzeichnisIDs.IPortableDevicePropVariantCollection
    Protected NewList DirectoryList.sDirectoryEntry()
    
    ; Open the sourcefile, id it can't be opend we don't have to do the rest
    SoureFile = ReadFile(#PB_Any, SourceFilename, #PB_File_SharedRead)
    If Not SoureFile
      LastErrorMessage = "Can't open source file '" + SourceFilename + "'."
      ProcedureReturn #False
    EndIf
    ; Try to get content type out if the file extension
    Select LCase(GetExtensionPart(DestinationFilename))
      Case "wma", "mp3"
        ContentType = ?WPD_CONTENT_TYPE_AUDIO
      Case "jpg"
        ContentType = ?WPD_CONTENT_TYPE_IMAGE
      Case "wmc", "avi"
        ContentType = ?WPD_CONTENT_TYPE_VIDEO
      Default
        ContentType = ?WPD_CONTENT_TYPE_GENERIC_FILE
    EndSelect
    
    ; Get device information
    DestinationFilename = createFullQualifiedName(DestinationFilename)
    If DestinationFilename = "" : ProcedureReturn #False : EndIf
    DestinationOnlyFilename = GetFilePart(DestinationFilename)
    DestinationOnlyFilenameWithoutExtension = GetFilePart(DestinationOnlyFilename, #PB_FileSystem_NoExtension)
    DeviceID = GetDeviceIDByName(DestinationFilename)
    If DeviceID = "" : ProcedureReturn #False : EndIf
    
    ; Get the directory to put the file into
    DestinationDirectory = GetPathPart(DestinationFilename)  ; Cut the filename of
    CreateDirectoryByName(DestinationDirectory)              ; Create the dir if not existing
    ; Search through directory tree to find the parent directory we are looking for
    While #True
      ; Get Directory, on Error return error
      If Not getDirectoryById(DeviceID, VerzeichnisID, DirectoryList())
        ProcedureReturn #False
      EndIf
      FieldIndex + 1
      Verzeichnisname = LCase(StringField(DestinationDirectory, FieldIndex, "\"))
      If Verzeichnisname = ""   
        ProcedureReturn #False  ; LastErrorMessage should contain an errormessage from CreateDirectoryByName
      EndIf
      ; Search in DirectoryList for the directory
      VerzeichnisID = ""
      ForEach DirectoryList()
        If LCase(DirectoryList()\Name) = Verzeichnisname
          VerzeichnisID = DirectoryList()\ID
          Break
        EndIf
      Next
      ; Wenn Verzeichnis in der Liste gefunden wurde, und dies das letzte Verzeichnis im Directorynamen ist,
      ; dann haben wir das Verzeichnis in das die Datei kopiert werden soll
      If VerzeichnisID <> "" And StringField(DestinationDirectory, FieldIndex+1, "\") = ""
        hr = CoCreateInstance_(?CLSID_PortableDeviceValues, 0, #CLSCTX_INPROC_SERVER, ?IID_IPortableDeviceValues, @deviceValues)
        If FAILED(hr)
          LastErrorMessage = "Failed to CoCreateInstance CLSID_PortableDeviceValues. Returncode=0x" + Hex(hr)
          ProcedureReturn #False
        EndIf
        ; set Values
        hr = deviceValues\SetStringValue(?WPD_OBJECT_PARENT_ID, @VerzeichnisID)
        hr = deviceValues\SetUnsignedLargeIntegerValue(?WPD_OBJECT_SIZE, FileSize(SourceFilename))
        hr = deviceValues\SetStringValue(?WPD_OBJECT_ORIGINAL_FILE_NAME, @DestinationOnlyFilename)
        hr = deviceValues\SetStringValue(?WPD_OBJECT_NAME, @DestinationOnlyFilenameWithoutExtension)
        hr = deviceValues\SetGuidValue(?WPD_OBJECT_CONTENT_TYPE, ?WPD_CONTENT_TYPE_GENERIC_FILE) ; *ContentType)
        hr = deviceValues\SetBoolValue(?WPD_OBJECT_CAN_DELETE, #True)
        hr = Devices(DeviceID)\content\CreateObjectWithPropertiesAndData(deviceValues, @tempStream, @optimalTransferSizeBytes, 0)
        If FAILED(hr)
          LastErrorMessage = "Failed to create file: " + DestinationFilename + " Returncode=0x" + Hex(hr)
          deviceValues\Release()
          CloseFile(SoureFile)
          ProcedureReturn #False
        EndIf
        *Buffer = AllocateMemory(optimalTransferSizeBytes)
        If *Buffer = 0
          LastErrorMessage = "Couldn't allocate memory for filecopy of file: " + DestinationFilename
          deviceValues\Release()
          CloseFile(SoureFile)
          ProcedureReturn #False
        EndIf
        While Eof(SoureFile) = 0
          AnzahlGelesen = ReadData(SoureFile, *Buffer, optimalTransferSizeBytes)
          IstreamRwert = tempStream\Write(*Buffer, AnzahlGelesen, @bytesWritten)
          If IstreamRwert <> #S_OK
            LastErrorMessage = "Error while writing: " + DestinationFilename + " errorcode: 0x" + Hex(IstreamRwert)
            deviceValues\Release()
            CloseFile(SoureFile)
            ProcedureReturn #False
          EndIf
        Wend
        hr = tempStream\Commit(0)
        If FAILED(hr)
          LastErrorMessage = "Failed to create file: " + DestinationFilename + " Returncode=0x" + Hex(hr)
          tempStream\Release()
          deviceValues\Release()
          CloseFile(SoureFile)
          ProcedureReturn #False
        EndIf
        tempStream\Release()
        deviceValues\Release()
        CloseFile(SoureFile)
        ProcedureReturn #True
      EndIf
    Wend
    ProcedureReturn #False
  EndProcedure
  
  
  ; Copies a file from an WPD device
  Procedure.i CopyFileFromDevice(SourceFilename.s, DestinationFilename.s)
    Shared Devices.sDeviceInformation(), LastErrorMessage.s
    Protected DeviceID.s, VerzeichnisID.s="", Verzeichnisname.s, FileID.s, DestFile.i, IstreamRwert.i, AnzahlGelesen.l, FieldIndex.i=3, hr.i, *Buffer
    Protected resources.IPortableDeviceResources, optimalTransferSizeBytes.l, objectDataStream.IStream
    Protected NewList DirectoryList.sDirectoryEntry()
    
    SourceFilename = createFullQualifiedName(SourceFilename)
    ; Get device information
    If SourceFilename = "" : ProcedureReturn #False : EndIf
    DeviceID = GetDeviceIDByName(SourceFilename)
    If DeviceID = "" : ProcedureReturn #False : EndIf
    
    ; Search through directory tree to find the parent directory we are looking for
    While #True
      ; Get Directory, on Error return error
      If Not GetDirectoryById(DeviceID, VerzeichnisID, DirectoryList())
        ProcedureReturn #False
      EndIf
      FieldIndex + 1
      Verzeichnisname = LCase(StringField(SourceFilename, FieldIndex, "\"))
      If Verzeichnisname = ""   
        ProcedureReturn #False  ; LastErrorMessage should contain an errormessage from CreateDirectoryByName
      EndIf
      ; Search in DirectoryList for the file
      VerzeichnisID = ""
      ForEach DirectoryList()
        If LCase(DirectoryList()\Name) = Verzeichnisname
          VerzeichnisID = DirectoryList()\ID
          Break
        EndIf
      Next
      ; Wenn Verzeichnis in der Liste gefunden wurde, und dies das letzte Verzeichnis im Directorynamen ist,
      ; dann haben wir die Datei gefunden die kopiert werden soll.
      If VerzeichnisID <> "" And StringField(SourceFilename, FieldIndex+1, "\") = ""
        FileID = VerzeichnisID
        hr = Devices(DeviceID)\content\Transfer(@resources)
        If FAILED(hr)
          LastErrorMessage = "Failed to Resources. Returncode=0x" + Hex(hr)
          ProcedureReturn #False
        EndIf
        hr = resources\GetStream(FileID, ?WPD_RESOURCE_DEFAULT, #STGM_READ, @optimalTransferSizeBytes, @objectDataStream)
        If FAILED(hr)
          LastErrorMessage = "Failed to Stream object. Returncode=0x" + Hex(hr)
          ProcedureReturn #False
        EndIf
        ; Copy the file
        *Buffer = AllocateMemory(optimalTransferSizeBytes)
        If *Buffer = 0
          LastErrorMessage = "Couldn't allocate memory for filecopy of file: " + DestinationFilename
          objectDataStream\Release()
          ProcedureReturn #False
        EndIf
        DestFile = CreateFile(#PB_Any, DestinationFilename)
        While #True
          IstreamRwert = objectDataStream\Read(*Buffer, optimalTransferSizeBytes, @AnzahlGelesen)
          If IstreamRwert <> #S_OK
            LastErrorMessage = "Error while reading: " + SourceFilename + " errorcode: 0x" + Hex(IstreamRwert)
            objectDataStream\Release()
            CloseFile(DestFile)
            ProcedureReturn #False
          EndIf
          If AnzahlGelesen = 0 : Break : EndIf
          WriteData(DestFile, *Buffer, AnzahlGelesen)
        Wend
        objectDataStream\Release()
        CloseFile(DestFile)
        ProcedureReturn #True
      EndIf
    Wend
    
    ProcedureReturn #True
  EndProcedure
  
  
  
  ;---------- Gadgets
  
  ; Select Directory for MPD Devices
  
  Structure sTreeListInfos
    DeviceID.s
    ID.s
    Type.i
    TreeHirachie.i
    SubdirsAlreadyLoaded.b
  EndStructure
  
  Define Window_SelectDirectory.i, Button_OK.i, Button_Abbrechen.i, Tree_0.i, DeviceImage.i, StorageImage.i, FolderImage.i
  Define NewList TreeListInfos.sTreeListInfos()
  
  ; Icons laden
  DeviceImage = ImageID(CatchImage(#PB_Any, ?StartDevice))
  StorageImage = ImageID(CatchImage(#PB_Any, ?StartStorage))
  FolderImage = ImageID(CatchImage(#PB_Any, ?StartFolder))
  
  
  Procedure ResizeGadgetsWindow_SelectDirectory()
    Shared Window_SelectDirectory.i, Button_OK.i, Button_Abbrechen.i, Tree_0.i
    Protected FormWindowWidth, FormWindowHeight
    
    FormWindowWidth = WindowWidth(Window_SelectDirectory)
    FormWindowHeight = WindowHeight(Window_SelectDirectory)
    ResizeGadget(Button_OK, FormWindowWidth - 220, FormWindowHeight - 40, 100, 25)
    ResizeGadget(Button_Abbrechen, FormWindowWidth - 110, FormWindowHeight - 40, 100, 25)
    ResizeGadget(Tree_0, 10, 10, FormWindowWidth - 20, FormWindowHeight - 70)
  EndProcedure
  
  
  Procedure LoadDirectoryEbene(DeviceID.s, DirID.s, TreelistAfter.i, TreeLevel.i)
    Shared TreeListInfos.sTreeListInfos()
    Shared Tree_0, DeviceImage.i, StorageImage.i, FolderImage.i
    Protected NewList DirectoryList.HF_WPDLib::sDirectoryEntry()
    Protected Icon.i, *SelectedEntry
    
    If HF_WPDLib::getDirectoryByID(DeviceID, DirID, DirectoryList())
      ForEach DirectoryList()
        Select DirectoryList()\Typ
          Case HF_WPDLib::#WPD_Directory, HF_WPDLib::#WPD_Storage
            *SelectedEntry = AddElement(TreeListInfos())
            TreeListInfos()\DeviceID = DeviceID
            TreeListInfos()\ID = DirectoryList()\ID
            TreeListInfos()\Type = DirectoryList()\Typ
            TreeListInfos()\SubdirsAlreadyLoaded = #False
            If DirectoryList()\Typ = #WPD_Storage
              Icon = StorageImage
            Else 
              Icon = FolderImage
            EndIf
            AddGadgetItem(Tree_0, TreelistAfter+1, DirectoryList()\Name, Icon, TreeLevel)
            SetGadgetItemData(Tree_0, TreelistAfter+1, *SelectedEntry)
        EndSelect     
      Next
    EndIf
  EndProcedure
  
  
  ; Gadget to search through the MTP devices
  Procedure.s PathRequestor(callingWindow.i, Titel.s="MTP Verzeichnisauswahl")
    Shared TreeListInfos.sTreeListInfos()
    Shared Window_SelectDirectory.i, Button_OK.i, Button_Abbrechen.i, Tree_0.i, DeviceImage.i, StorageImage.i, FolderImage.i
    Protected x.i, y.i, Width.i, Height.i, Verzeichnisname.s="", *SelectedTreeEntry, TreeEntry.i, SubLevel.i, Event.i
    Protected NewList DeviceList.HF_WPDLib::sDeviceEntry()
    
    ClearList(TreeListInfos())
    ; Get callingWindow Position
    Width = 470
    Height = 610
    x = WindowX(callingWindow) + WindowWidth(callingWindow) / 2 - Width / 2
    y = WindowY(callingWindow) + WindowHeight(callingWindow) / 2 - Height / 2
    Window_SelectDirectory = OpenWindow(#PB_Any, x, y, width, height, Titel, #PB_Window_SystemMenu | #PB_Window_SizeGadget)
    Button_OK = ButtonGadget(#PB_Any, 250, 570, 100, 25, "OK", #PB_Button_Default)
    Button_Abbrechen = ButtonGadget(#PB_Any, 360, 570, 100, 25, "Abbrechen")
    Tree_0 = TreeGadget(#PB_Any, 10, 10, 450, 540, #PB_Tree_AlwaysShowSelection | #PB_Tree_NoButtons)
    GadgetToolTip(Tree_0, "Wählen sie ein Verzeichnis aus.")
    StickyWindow(Window_SelectDirectory, #True)
    
    ; Deviceliste laden
    HF_WPDLib::getDevices(DeviceList())
    If ListSize(DeviceList()) = 0
      MessageRequester(Titel, "Keine MTP Devices gefunden.", #PB_MessageRequester_Info)
    Else
      ForEach DeviceList()
        AddGadgetItem(Tree_0, -1, DeviceList()\FriendlyName, DeviceImage, 0)
        *SelectedTreeEntry = AddElement(TreeListInfos())
        TreeListInfos()\DeviceID = DeviceList()\ID
        TreeListInfos()\ID = ""
        TreeListInfos()\Type = #WPD_Device
        TreeListInfos()\SubdirsAlreadyLoaded = #False
        SetGadgetItemData(Tree_0, CountGadgetItems(Tree_0)-1, *SelectedTreeEntry)
      Next
      Repeat
        ; When opened all application events are routed here
        Event = WaitWindowEvent()
        Select event
          Case #PB_Event_SizeWindow
            ResizeGadgetsWindow_SelectDirectory()
          Case #PB_Event_CloseWindow
            Break
          Case #PB_Event_Gadget
            Select EventGadget()
              Case Button_Abbrechen 
                Break
              Case Button_OK
                *SelectedTreeEntry = GetGadgetItemData(Tree_0, GetGadgetState(Tree_0))
                ChangeCurrentElement(TreeListInfos(), *SelectedTreeEntry)
                Verzeichnisname = GetGadgetText(Tree_0)
                SubLevel = GetGadgetItemAttribute(Tree_0, GetGadgetState(Tree_0), #PB_Tree_SubLevel)
                For TreeEntry = GetGadgetState(Tree_0)-1 To 0 Step -1
                  If GetGadgetItemAttribute(Tree_0, TreeEntry, #PB_Tree_SubLevel) < Sublevel
                    Verzeichnisname = GetGadgetItemText(Tree_0, TreeEntry) + "\" + Verzeichnisname
                    SubLevel = GetGadgetItemAttribute(Tree_0, TreeEntry, #PB_Tree_SubLevel)
                  EndIf
                Next TreeEntry
                Verzeichnisname = "\\" + Verzeichnisname
                Break
              Case Tree_0
                TreeEntry = GetGadgetState(Tree_0)
                *SelectedTreeEntry = GetGadgetItemData(Tree_0, TreeEntry)
                ChangeCurrentElement(TreeListInfos(), *SelectedTreeEntry)
                If Not TreeListInfos()\SubdirsAlreadyLoaded
                  TreeListInfos()\SubdirsAlreadyLoaded = #True
                  LoadDirectoryEbene(TreeListInfos()\DeviceID, TreeListInfos()\ID, GetGadgetState(Tree_0), 
                                     GetGadgetItemAttribute(Tree_0, TreeEntry, #PB_Tree_SubLevel)+1)
                EndIf
            EndSelect
        EndSelect
      ForEver
    EndIf
    CloseWindow(Window_SelectDirectory)
    ClearList(TreeListInfos())
    ProcedureReturn Verzeichnisname
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 34
; Folding = ------
; EnableXP