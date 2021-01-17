; ---------------------------------------------------------------------------------------
;
; Modul for accessing S3 fikesystems with the most used functions
; The module is inspired by the Pure Basic Directory functions
;
; Author:  Heribert Füchtenhans
; Version: 2020.10.25
; OS:      Windows
;
; For signature creation see:
;   https://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html#canonical-request
;
; For further information on S3 see
;   https://czak.pl/2015/09/15/s3-rest-api-with-curl.html
;   https://docs.aws.amazon.com/general/latest/gr/signature-v4-examples.html#signature-v4-examples-python
;
; The Rest API documentation from Amazon
;   https://docs.aws.amazon.com/AmazonS3/latest/API/Welcome.html
;
; ---------------------------------------------------------------------------------------
;
; MIT License
; 
; Copyright (c) 2020 Heribert Füchtenhans
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


XIncludeFile "HF_Cipher.pbi"
XIncludeFile "HF_Windows.pbi"



DeclareModule HF_S3
  
  Structure sConnectionParameter
    Host.s              ; Host IP or name
    Port.s              ; Port for the communication
    Bucket.s            ; S3 bucket
    AccessKey.s         ; S3 Access key (Username)
    SecretKey.s         ; S3 Secret key (Password)
    ErrorString.s       ; Returns the last error message
  EndStructure
  
 
  Declare.i ExamineS3Directory(connection.i, *ConnectionParameter.sConnectionParameter, prefix.s, delimiter.s)
  ; Start to examine a S3 directory with functions NextS3DirectoryEntry(), S3DirectoryEntryName, etc.
  ; Parameters
  ;   connection            A number to identify the new directory listing. #PB_Any can be used as a parameter
  ;                         to auto-generate this number.
  ;   ConnectionParameter   Structure with the paramter to call S3 functions
  ;   prefix                Prefix to use to select entries
  ;   delimiter             Virtual Path delimiter for the S3 filenames
  ;
  ; Returns
  ;   Returns nonzero if the directory can be enumerated or zero if there was an error. If #PB_Any was used as 
  ;   the connection parameter then the generated directory number is returned. 
  ;
  ; Remarks
  ;   Once the Enumeration is done, FinishS3Directory() must be called to free the resources associated to the listing.
  ;   Even if the functions returns none zero, check with GetLastError() ist an error ocured during getting the first
  ;   Entries from S3 storage.
  
  
  Declare FinishS3Directory(connection.i)
  ; Finish the enumeration started with ExamineS3Directory(). This frees the resources associated with the #Directory listing. 
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory(). 
  
  
  Declare.i NextS3DirectoryEntry(connection.i, *ConnectionParameter.sConnectionParameter)
  ; This function must be called after an ExamineS3Directory(). It will go step-by-step into the directory and list its contents
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory(). 
  ;   ConnectionParameter   Structure with the paramter to call S3 functions
  ; Returns
  ;   Returns nonzero if a new entry was read from the directory and zero if there are no more entries
  ; Remarks
  ;   The entry name can be read with the S3DirectoryEntryName() function. If you want to know whether 
  ;   an entry is a subdirectory Or a file, use the S3DirectoryEntryType() function.
  ;   NextS3DirectoryEntry returns Directory entries first bevor all filenames
  
  
  Declare.s S3DirectoryEntryName(connection.i)
  ; Returns the name of the current entry in the directory being listed with ExamineS3Directory() and NextS3DirectoryEntry() functions
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory(). 
  ; Returns
  ;     Returns the name of the current directory entry. 
  
  
  Declare.i S3DirectoryEntryDate(connection.i)
  ; Returns the filedate of the current entry in the directory being listed with ExamineS3Directory() and NextS3DirectoryEntry() functions
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory(). 
  ; Returns
  ;     Returns the date of the current directory entry, for directories thsi is always the aktual date and time
  
  
  Declare.i S3DirectoryEntrySize(connection.i)
  ; Returns the size of the current entry in the directory being listed with ExamineS3Directory() and NextS3DirectoryEntry() functions
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory(). 
  ; Returns
  ;     Returns the size of the current directory entry in bytes
  
  
  Declare.i S3DirectoryEntryType(connection.i)
  ; Returns the type of the current entry in the directory being listed with ExamineS3Directory() and NextS3DirectoryEntry() functions
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory(). 
  ; Returns
  ;     Returns one of the following values: 
  ;     #PB_DirectoryEntry_File     : This entry is a file.
  ;     #PB_DirectoryEntry_Directory: This entry is a directory.
  
  Declare CopyFileFromS3(*ConnectionParameter.sConnectionParameter, S3Filename.s, PCFilename.s, PCFilenameMetadata.s="")
  ; Copies a file from S3 to PCFilename, check ConnectionParameter \errormessage for errors
  ; Returns the S3 metadata of the file
  ; Parameters
  ;   ConnectionParameter   Structure with the paramter to call S3 functions
  ;   S3Filename            Name of the S3 file to copy
  ;   PCFilename            Name of the file to store in
  ;   PCFilenameMetadata    Filename for the S3 Metadata (Headers)
  ;
  ; Returns
  ;   Returns An errormessage if something went wrong else an empty string
  
  Declare CopyFileToS3(*ConnectionParameter.sConnectionParameter, PCFilename.s, S3Filename.s, Map AdditionalHeader.s())
  ; Stores a PC file as S3 file
  ; Parameters
  ;   ConnectionParameter   Structure with the paramter to call S3 functions
  ;   PCFilename            Name of the file to store in
  ;   S3Filename            Name of the S3 file to copy
  
  Declare DeleteFileFromS3(*ConnectionParameter.sConnectionParameter, S3Filename.s)
  ; Deletes a file from the S3 storage
  
  
  Declare.i S3FileSize(*ConnectionParameter.sConnectionParameter, S3Filename.s)
    ; get the filesize for an S3 file
    ; Returns the size of the file in bytes, or one of the following values: 
    ;   -1: File Not found.
    ;   -2: Multiple files exist starting with the filename
  
EndDeclareModule



InitNetwork()

Module HF_S3
  
  EnableExplicit
  
  ImportC ""    ; to get time structure with utc time
   time(*tm=#Null)
  EndImport
  

  Structure sDirectoryList
    filename.s
    filedate.i
    filesize.i
    entrytype.i
  EndStructure
    
  Structure sS3DirectoryExamineParameter
    host.s
    port.s
    url.s
    s3_access_key.s
    s3_secret_key.s
    s3_bucket.s
    prefix.s
    delimiter.s
    HTTPReturnCode.s
    HTTPErrormessage.s
    ContinuationToken.s
    List DirectoryList.sDirectoryList()
  EndStructure
  
  
  #EmptyFilePayloadHash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  #DefaultRegion = "eu-central-1"
  
  NewMap S3DirectoryExamineParamter.sS3DirectoryExamineParameter()
  Define S3Mutex.i=CreateMutex()
  
  
  ;--- Internal functions --------------------------------------------
  
  ; Return a spcial URI Encodes string for AWS
  Procedure.s URIEncode(url.s, EncodeSlash.b=#True)
    Protected Str.s="", i.i, chr.s, ch.b
    
    For i = 1 To Len(url)
      chr = Mid(url, i, 1)
      ch = Asc(chr)
      If (ch >= 'A' And ch <= 'Z') Or (ch >= 'a' And ch <= 'z') Or (ch >= '0' And ch <= '9') Or ch = '_' Or ch = '-' Or ch = '~' Or ch = '.'
        Str + chr
      ElseIf ch = '/'
        If EncodeSlash
          Str + "%2F"
        Else
          Str + chr
        EndIf
      Else
        Str + "%" + RSet(Hex(ch), 2, "0")
      EndIf
    Next i
    ProcedureReturn Str
  EndProcedure
  
  
  Procedure.s GetHTTPResponseError(HTTPRequest.i)
    Protected response.s, error.s, message.s
    
    response = HTTPInfo(HTTPRequest, #PB_HTTP_Response)
    error = HTTPInfo(HTTPRequest, #PB_HTTP_ErrorMessage)
    If CountString(response, "<Message>") <> 0
      message = StringField(response, 2, "<Message>")
      message = StringField(message, 1, "</Message>")
      If Len(error) > 0
        message + " : " + error
      EndIf
    Else
      message = error
    EndIf
    ProcedureReturn message
  EndProcedure
    

  Procedure.s CreateCanonicalQueryString(Map QueryParameterMap.s())
    Protected NewList QueryList.s(), QueryString.s
    
    ; Create CanonicalQueryString
    ForEach QueryParameterMap()
      AddElement(QueryList()) : QueryList() = URIEncode(MapKey(QueryParameterMap())) + "=" + URIEncode(QueryParameterMap())
    Next
    SortList(QueryList(), #PB_Sort_Ascending)
    ForEach QueryList()
      If QueryString <> ""
        QueryString + "&"
      EndIf
      QueryString + QueryList()
    Next
    ProcedureReturn QueryString
  EndProcedure
  
  
  ; QueryParameterMap is a map with the Query Parameter, for example:
  ;    p("list-type") = "2"
  ;    p("delimiter") = "/"
  Procedure.s createCanonicalRequest(HTTPMethod.s, CanonicalURI.s, Map QueryParameterMap.s(), Map CanonicalHeaderMap.s(), HashedPayload.s)
    Protected Request.s, QueryString.s="", HeaderString.s="", SignedHeaders.s=""
    Protected NewList Headerlist.s()
    
    Request = HTTPMethod + ~"\n"
    Request + URIEncode(CanonicalURI, #False) + ~"\n"
    Request + CreateCanonicalQueryString(QueryParameterMap()) + ~"\n"
    ; Create CanonicalHeaders and SignedHeader
    ForEach CanonicalHeaderMap()
      AddElement(Headerlist()) : Headerlist() = LCase(MapKey(CanonicalHeaderMap())) + ":" + Trim(CanonicalHeaderMap())
    Next
    SortList(Headerlist(), #PB_Sort_Ascending)
    ForEach Headerlist()
      If SignedHeaders <> ""
        SignedHeaders + ";"
      EndIf
      HeaderString + Headerlist() + ~"\n"
      SignedHeaders + StringField(Headerlist(), 1, ":")
    Next
    Request + HeaderString + ~"\n"
    Request + SignedHeaders + ~"\n"
    Request + HashedPayload
    ProcedureReturn Request
  EndProcedure
  
  
  Procedure.s createStringToSign(Timestamp.s, Scope.s, Request.s)
    Protected StringToSign.s
    
    StringToSign = ~"AWS4-HMAC-SHA256\n"
    StringToSign + Timestamp + ~"\n"
    StringToSign + Scope + ~"\n"
    UseSHA2Fingerprint()
    StringToSign + StringFingerprint(Request, #PB_Cipher_SHA2, 256)
    ProcedureReturn StringToSign
  EndProcedure
  
  
  Procedure.s createSingningKey(key.s, dateStamp.s, regionName.s, serviceName.s)
    Protected *kSecret, SingningKey.s, kDate.s, kRegion.s, kService.s, kSigning.s
    
    kDate = HF_Cipher::hmac_256("AWS4" + key, dateStamp)
    kRegion = HF_Cipher::hmac_256(kDate, regionName, #True)
    kService = HF_Cipher::hmac_256(kRegion, serviceName, #True)
    kSigning = HF_Cipher::hmac_256(kService, "aws4_request", #True)
    ProcedureReturn kSigning
  EndProcedure
  
  
  ; QueryParameterMap is a map with the Query Parameter, for example:
  ;    p("list-type") = "2"
  ;    p("delimiter") = "/"
  Procedure.s createSignedHeader(Map HeaderMap.s())
    Protected SignedHeaders.s="", NewList Headerlist.s()
    
    ; Create CanonicalHeaders and SignedHeader
    ForEach HeaderMap()
      AddElement(Headerlist()) : Headerlist() = LCase(MapKey(HeaderMap()))
    Next
    SortList(Headerlist(), #PB_Sort_Ascending)
    ForEach Headerlist()
      If SignedHeaders <> ""
        SignedHeaders + ";"
      EndIf
      SignedHeaders + Headerlist()
    Next
    ProcedureReturn SignedHeaders
  EndProcedure

  
  ; Creates the actual time as an UTC string
  Procedure.s create_datetime()
    ProcedureReturn FormatDate("%yyyy%mm%ddT%hh%ii%ssZ", time(#Null))
  EndProcedure
 
  
  ; Function: GET, PUT, POST, etc.
  ; host: host or ip
  ; PayloadHash: hash of the payload to send. If an empty string, the default for an emty file will be used
  ; Headers: Map as used for the HTTPRequest
  ; s3_secret_key: Access security string
  Procedure.s createSignature(Function.s, Host.s, Query.s, Map QueryParameterMap.s(), Map HeaderMap.s(), PayloadHash.s, DateTime.s, Scope.s, 
                              s3_secret_key.s, region.s)
    Protected Request.s, StringToSign.s, SigninKey.s
    
    If PayloadHash = "" : PayloadHash = #EmptyFilePayloadHash : EndIf
    ; Add host for the signing key
    Request = createCanonicalRequest(Function, StringField(Query, 1, "?"), QueryParameterMap(), HeaderMap(), PayloadHash)
    StringToSign = createStringToSign(DateTime, Scope, Request)
    SigninKey = createSingningKey(s3_secret_key, Left(DateTime, 8), region, "s3")
    ProcedureReturn HF_Cipher::hmac_256(SigninKey, StringToSign, #True)
  EndProcedure
  
  
  Procedure TestCreateSignature()
    Protected Signature.s, NewMap QueryParameterMap.s(),NewMap HeaderMap.s()
    
    Debug("--- TestCreateSignature GET -----------------------------------------------------")
    HeaderMap("x-amz-Date") = "20130524T000000Z"
    HeaderMap("range") = "bytes=0-9"
    HeaderMap("x-amz-content-sha256") = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    Headermap("host") = "examplebucket.s3.amazonaws.com"
    Signature = createSignature("GET", "examplebucket.s3.amazonaws.com", "/test.txt", QueryParameterMap(), HeaderMap(), #EmptyFilePayloadHash, "20130524T000000Z", 
                                "20130524/us-east-1/s3/aws4_request", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY", "us-east-1")
    If Signature <> "f0e8bdb87c964420e857bd35b5d6ed310bd44f0170aba48dd91039c6036bdb41"
      Debug("ERROR: Testsignatures do not match.")
    EndIf
    Debug("--- TestCreateSignature PUT -----------------------------------------------------")
    ClearMap(HeaderMap())
    HeaderMap("Date") = "Fri, 24 May 2013 00:00:00 GMT"
    HeaderMap("x-amz-Date") = "20130524T000000Z"
    HeaderMap("x-amz-storage-class") = "REDUCED_REDUNDANCY"
    HeaderMap("x-amz-content-sha256") = "44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072"
    Headermap("host") = "examplebucket.s3.amazonaws.com"
    Signature = createSignature("PUT", "examplebucket.s3.amazonaws.com", "/test$file.text", QueryParameterMap(), HeaderMap(), 
                                "44ce7dd67c959e0d3524ffac1771dfbba87d2b6b4b4e99e42034a8b803f8b072", "20130524T000000Z",
                                "20130524/us-east-1/s3/aws4_request", "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY", "us-east-1")
    If Signature <> "98ad721746da40c64f1a55b78f14c238d841ea1380cd77a1b5971af0ece108bd"
      Debug("ERROR: Testsignatures do not match.")
    EndIf
    Debug("--- TestCreateSignature End -----------------------------------------------------")
  EndProcedure
  
  
  ; Set S3Connection\HTTPReturnCode und S3Connetion\HTTPErrormessage
  ; Return: the http response text or "" if we didn't get a 200 response
  Procedure.s sendGetRequest(*mappointer.sS3DirectoryExamineParameter, Map QueryParameterMap.s())
    Protected DateTime.s, scope.s, url.s, NewMap HeaderMap.s()
    Protected rwert.s="", Signature.s, HTTPRequest.i
    
    DateTime = create_datetime()
    Scope = Left(DateTime, 8) + "/" + #DefaultRegion + "/s3/aws4_request"
    With *mappointer
      HeaderMap("host") = \host
      HeaderMap("x-amz-content-sha256") = #EmptyFilePayloadHash
      HeaderMap("x-amz-date") = DateTime
      Signature = createSignature("GET", \host, "/" + \s3_bucket, QueryParameterMap(), HeaderMap(), #EmptyFilePayloadHash, DateTime, Scope, 
                                  \s3_secret_key, #DefaultRegion)
      HeaderMap("Authorization") = "AWS4-HMAC-SHA256 Credential=" + \s3_access_key + "/" + scope + ",SignedHeaders=host;x-amz-content-sha256;x-amz-date" +
                                 ",Signature=" + Signature
      url = "http://" + \host + ":" + \port + "/" + \s3_bucket + "?" + CreateCanonicalQueryString(QueryParameterMap())
      HttpRequest = HTTPRequest(#PB_HTTP_Get, url, "", #PB_HTTP_NoSSLCheck, HeaderMap())
      If HttpRequest
        \HTTPReturnCode = HTTPInfo(HTTPRequest, #PB_HTTP_StatusCode)
        If \HTTPReturnCode = "200"
          \HTTPErrormessage = ""
          rwert = HTTPInfo(HTTPRequest, #PB_HTTP_Response)
        Else
          \HTTPErrormessage = GetHTTPResponseError(HTTPRequest)
        EndIf
        FinishHTTP(HTTPRequest)
      Else
        \HTTPReturnCode = "500"
        \HTTPErrormessage = "Request creation failed"
      EndIf
    EndWith
    ProcedureReturn rwert
  EndProcedure
  

  Procedure.s GetFilelist_parse_XML(*mappointer.sS3DirectoryExamineParameter, xmlstring.s)
    Protected rwert.s="", xmlparser.i, *MainNode, *subnode, *subnode_1, AnzahlEintraege.i, i.i, Subnodepath.s
    Protected filename.s, filedatestr.s, filedate.i, filelength.i, *listpointer.sDirectoryList
    
    xmlparser = ParseXML(#PB_Any, xmlstring)
    If xmlparser And XMLStatus(xmlparser) = #PB_XML_Success
      *MainNode = MainXMLNode(xmlparser)
      If *MainNode
        ; Bestimme die Anzahl der Einträge
        *subnode = XMLNodeFromPath(*MainNode, "/ListBucketResult/KeyCount")
        If *subnode
          AnzahlEintraege = Val(GetXMLNodeText(*subnode))
        EndIf
        ; Get ContinuationKey if exist
        *subnode = XMLNodeFromPath(*MainNode, "/ListBucketResult/NextContinuationToken")
        If *subnode
          *mappointer\ContinuationToken = GetXMLNodeText(*subnode)
        Else
          *mappointer\ContinuationToken = ""
        EndIf
        ; Get all Directory Entries
        For i = 1 To AnzahlEintraege
          Subnodepath ="/ListBucketResult/CommonPrefixes[" + Str(i) + "]"
          *subnode = XMLNodeFromPath(*MainNode, Subnodepath)
          If *subnode
            *subnode_1 = XMLNodeFromPath(*subnode, "Prefix")
            If *subnode_1
              filename = URLDecoder(GetXMLNodeText(*subnode_1))
            EndIf
            *listpointer = AddElement(*mappointer\DirectoryList())
            *listpointer\filename = filename
            *listpointer\filedate = Date()
            *listpointer\filesize = 0
            *listpointer\entrytype = #PB_DirectoryEntry_Directory
          Else
            Break     ; no more entries
          EndIf
        Next i

        ; Get all Filenames
        For i = 1 To AnzahlEintraege
          Subnodepath ="/ListBucketResult/Contents[" + Str(i) + "]"
          *subnode = XMLNodeFromPath(*MainNode, Subnodepath)
          If *subnode
            *subnode_1 = XMLNodeFromPath(*subnode, "Key")
            If *subnode_1
              filename = URLDecoder(GetXMLNodeText(*subnode_1))
            EndIf
            *subnode_1 = XMLNodeFromPath(*subnode, "LastModified")
            If *subnode_1
              filedatestr = GetXMLNodeText(*subnode_1)
              filedate = ParseDate("%yyyy-%mm-%ddT%hh:%ii:%ss", StringField(filedatestr, 1, ".")) ; StringField to truncate the Millsec part
            EndIf
            *subnode_1 = XMLNodeFromPath(*subnode, "Size")
            If *subnode_1
              filelength = Val(GetXMLNodeText(*subnode_1))
            EndIf
            If filename <> ""
              *listpointer = AddElement(*mappointer\DirectoryList())
              *listpointer\filename = filename
              *listpointer\filedate = filedate + HF_Windows::GetUTCTimeDiff()
              *listpointer\filesize = filelength
              *listpointer\entrytype = #PB_DirectoryEntry_File
            EndIf
          Else
            Break     ; no more entries
          EndIf
        Next i
      Else
        rwert = "500: Fehler im Aufbau der XML: " + XMLError(xmlparser)
      EndIf
    Else
      rwert = "500: Fehler beim parsen des XML returns: " + XMLError(xmlparser)
    EndIf
    If xmlparser <> 0 : FreeXML(xmlparser) : EndIf
    ; Set Directory List to first entry
    ResetList(*mappointer\DirectoryList())
    ProcedureReturn rwert
  EndProcedure
  
  
  Procedure.b GetFilelist(*mappointer.sS3DirectoryExamineParameter, *ConnectionParameter.sConnectionParameter)
  ; get the content of the directory
  ; return: true if OK else false
  ;         if false, ConnectionParameter\Errorstring will bes set
    Protected httpresp.s, NewMap QueryMap.s(), rtext.s
    
    With *mappointer
      QueryMap("list-type") = "2"
      QueryMap("prefix") = \prefix
      QueryMap("delimiter") = \delimiter
      QueryMap("encoding-type") = "url"
      If \ContinuationToken <> ""
        QueryMap("continuation-token") = \ContinuationToken
      EndIf
      httpresp = sendGetRequest(*mappointer, QueryMap())
      If httpresp <> ""
        rtext = GetFilelist_parse_XML(*mappointer, httpresp)
        If rtext <> ""
          *ConnectionParameter\ErrorString = rtext
          ProcedureReturn #False
        EndIf
      Else
        *ConnectionParameter\ErrorString = "HTTP Fehler " +  \HTTPReturnCode + ": " +  \HTTPErrormessage
        ProcedureReturn #False      
      EndIf
    EndWith
    ProcedureReturn #True
  EndProcedure
  
  Procedure downloadFile(*ConnectionParameter.sConnectionParameter, S3Filename.s, PCFilename.s, PCFilenameMetadata.s)
    ; Download s3 content to a file
    Protected outfilehandle.i, DateTime.s, Scope.s, url.s, *Value, Metadata.s, HttpReq.i, HTTPReturnCode.s, HTTPResonse.s
    Protected Signature.s, NewMap QueryMap.s(), NewMap HeaderMap.s(), Retries.i, Progress.i
    
    DateTime = create_datetime()
    Scope = Left(DateTime, 8) + "/" + #DefaultRegion + "/s3/aws4_request"
    S3Filename = URIEncode(S3Filename, #False)
    With *ConnectionParameter
      HeaderMap("host") = \host
      HeaderMap("x-amz-date") = DateTime
      Signature = createSignature("GET", \host, "/" + \Bucket + "/" + S3Filename, QueryMap(), HeaderMap(), #EmptyFilePayloadHash,  DateTime, Scope, 
                                  \SecretKey, #DefaultRegion)
      HeaderMap("Authorization") = "AWS4-HMAC-SHA256 Credential=" + \AccessKey + "/" + scope + 
                                   ",SignedHeaders=host;x-amz-date,Signature=" + Signature
      url = "http://" + \host + ":" + \port + "/" + \Bucket + "/" + S3Filename
    EndWith
    For Retries = 1 To 10
      *ConnectionParameter\ErrorString = ""
      HttpReq = HTTPRequest(#PB_HTTP_Get, url, "", 0, HeaderMap())
      If HttpReq
        HTTPReturnCode = HTTPInfo(HttpReq, #PB_HTTP_StatusCode)
        Metadata = HTTPInfo(HttpReq, #PB_HTTP_Headers)
        HTTPResonse = GetHTTPResponseError(HttpReq)
        *Value = HTTPMemory(HttpReq)
        FinishHTTP(HttpReq)
        If HTTPReturnCode = "200"
          If *Value
            outfilehandle = CreateFile(#PB_Any, PCFilename)
            If outfilehandle
              WriteData(outfilehandle, *Value, MemorySize(*Value))
              CloseFile(outfilehandle)
              FreeMemory(*Value)
              If PCFilenameMetadata <> ""
                outfilehandle = CreateFile(#PB_Any, PCFilenameMetadata)
                If outfilehandle
                  WriteString(outfilehandle, Metadata)
                  CloseFile(outfilehandle)
                Else
                  *ConnectionParameter\ErrorString = "500: Can't create file: " + PCFilenameMetadata
                EndIf
              EndIf
            Else              
              *ConnectionParameter\ErrorString = "500: Can't create file: " + PCFilename
            EndIf
          EndIf
          Break   ; leave Retry loop
        Else
          *ConnectionParameter\ErrorString = HTTPReturnCode + ": " + HTTPResonse + ": " + url
        EndIf
        If HTTPReturnCode = "404" Or HTTPReturnCode = "403"
          Break
        EndIf
      Else
        *ConnectionParameter\ErrorString = "500: Request creation failed"
      EndIf
      Delay(100)
    Next Retries
  EndProcedure
  
  
  Procedure uploadFile(*ConnectionParameter.sConnectionParameter, PCFilename.s, S3Filename.s, Map AdditionalHeader.s())
    ; Upload a PC file to S3
    Protected MD5Hash.s, Payload.s, filelength.i, infilehandle.i, DateTime.s, Scope.s, url.s, *Value, *Buffer, HttpReq.i, HTTPReturnCode.s
    Protected Signature.s, NewMap QueryMap.s(), NewMap HeaderMap.s(), Retries.i, SignedHeaders.s
    
    DateTime = create_datetime()
    Scope = Left(DateTime, 8) + "/" + #DefaultRegion + "/s3/aws4_request"
    filelength = FileSize(PCFilename)
    ; Read file to memory
    *Buffer = AllocateMemory(filelength+1)
    If *Buffer = 0
      *ConnectionParameter\ErrorString = "500: Can't get memeory for file: " + PCFilename
      ProcedureReturn
    EndIf
    infilehandle = OpenFile(#PB_Any, PCFilename)
    If infilehandle = 0
      *ConnectionParameter\ErrorString = "500: Can't open file: " + PCFilename
      ProcedureReturn
    EndIf
    ReadData(infilehandle, *Buffer,  filelength)
    CloseFile(infilehandle)
    ; Calculate hash values
    UseMD5Fingerprint()
    MD5Hash = Fingerprint(*Buffer, filelength, #PB_Cipher_MD5)
    Debug MD5Hash
    UseSHA2Fingerprint()
    Payload = Fingerprint(*Buffer, filelength, #PB_Cipher_SHA2, 256)
    S3Filename = URIEncode(S3Filename, #False)
    With *ConnectionParameter
      HeaderMap("content-length") = Str(filelength)
      HeaderMap("content-md5") = HF_Cipher::MD5HashBase64Decoded(MD5Hash)
      HeaderMap("host") = \host
      HeaderMap("x-amz-content-sha256") = Payload
      HeaderMap("x-amz-date") = DateTime
      HeaderMap("x-amz-storage-class") = "REDUCED_REDUNDANCY"
      Signature = createSignature("PUT", \host, "/" + \Bucket + "/" + S3Filename, QueryMap(), HeaderMap(), Payload,  DateTime, Scope, 
                                  \SecretKey, #DefaultRegion)
      HeaderMap("Authorization") = "AWS4-HMAC-SHA256 Credential=" + \AccessKey + "/" + scope + 
                                   ",SignedHeaders=" + createSignedHeader(HeaderMap()) + ",Signature=" + Signature
      url = "http://" + \host + ":" + \port + "/" + \Bucket + "/" + S3Filename
    EndWith
    For Retries = 1 To 10
      *ConnectionParameter\ErrorString = ""
      HttpReq = HTTPRequestMemory(#PB_HTTP_Put, url, *Buffer, filelength, #PB_HTTP_NoSSLCheck, HeaderMap())
      If HttpReq
        HTTPReturnCode = HTTPInfo(HttpReq, #PB_HTTP_StatusCode)
        If HTTPReturnCode = "200"
          FinishHTTP(HttpReq)
          Break   ; leave Retry loop
        Else
          *ConnectionParameter\ErrorString = HTTPReturnCode + ": " + GetHTTPResponseError(HttpReq)
          If HTTPReturnCode = "400" Or HTTPReturnCode = "403" : Break  : EndIf ; leave Retry loop
        EndIf
        FinishHTTP(HttpReq)
      Else
        *ConnectionParameter\ErrorString = "500: Request creation failed"
      EndIf
      Delay(100)
    Next Retries
    FreeMemory(*Buffer)
    ProcedureReturn
  EndProcedure
  
  
  Procedure deleteaFile(*ConnectionParameter.sConnectionParameter, S3Filename.s)
    ; Delete an S3 file
    Protected DateTime.s, Scope.s, url.s, HttpReq.i, HTTPReturnCode.s
    Protected Signature.s, NewMap QueryMap.s(), NewMap HeaderMap.s()
    
    DateTime = create_datetime()
    Scope = Left(DateTime, 8) + "/" + #DefaultRegion + "/s3/aws4_request"
    S3Filename = URIEncode(S3Filename, #False)
    With *ConnectionParameter
      HeaderMap("host") = \host
      HeaderMap("x-amz-date") = DateTime
      Signature = createSignature("DELETE", \host, "/" + \Bucket + "/" + S3Filename, QueryMap(), HeaderMap(), #EmptyFilePayloadHash, 
                                  DateTime, Scope, \SecretKey, #DefaultRegion)
      HeaderMap("Authorization") = "AWS4-HMAC-SHA256 Credential=" + \AccessKey + "/" + scope + ",SignedHeaders=host;x-amz-date,Signature=" + Signature
      url = "http://" + \host + ":" + \port + "/" + \Bucket + "/" + S3Filename
    EndWith
    HttpReq = HTTPRequest(#PB_HTTP_Delete, url, "", #PB_HTTP_NoSSLCheck, HeaderMap())
    If HttpReq
      HTTPReturnCode = HTTPInfo(HttpReq, #PB_HTTP_StatusCode)
      If HTTPReturnCode <> "200" And HTTPReturnCode <> "204"    ; 204 = No content, an empty file
        *ConnectionParameter\ErrorString = GetHTTPResponseError(HttpReq)
      EndIf
      FinishHTTP(HttpReq)
    Else
      *ConnectionParameter\ErrorString = "500: Request creation failed"
    EndIf
  EndProcedure


  ;--- External functions --------------------------------------------
  
  
  Procedure.i ExamineS3Directory(connection.i, *ConnectionParameter.sConnectionParameter, prefix.s, delimiter.s)
    ; Start to examine a S3 directory with functions NextS3DirectoryEntry(), S3DirectoryEntryName, etc.
    Shared S3Mutex.i, S3DirectoryExamineParamter.sS3DirectoryExamineParameter()
    Protected connectionNr.i, *mappointer.sS3DirectoryExamineParameter
    
    LockMutex(S3Mutex)
    ; get the connectionNr to use
    If connection <> #PB_Any
      ; Test if connection already used
      If FindMapElement(S3DirectoryExamineParamter(), Str(connection)) <> 0
        *ConnectionParameter\ErrorString = "Connection ID " + Str(connection) + " already in use."
        ProcedureReturn 0
      EndIf
      connectionNr = connection
    Else
      ; find a free number
      connectionNr = 1
      While FindMapElement(S3DirectoryExamineParamter(), Str(connectionNr)) <> 0
        connectionNr + 1
      Wend
    EndIf
    ; Save Parameter
    *mappointer = AddMapElement(S3DirectoryExamineParamter(), Str(connectionNr))
    If *mappointer = 0
      *ConnectionParameter\ErrorString = "Internal error, couldn'd add additional Memeory."
      ProcedureReturn 0
    EndIf
    With *mappointer
      \host = *ConnectionParameter\Host
      \port = *ConnectionParameter\Port
      \s3_bucket = *ConnectionParameter\Bucket
      \s3_access_key = *ConnectionParameter\AccessKey
      \s3_secret_key = *ConnectionParameter\SecretKey
      \prefix = prefix
      \delimiter = delimiter
      UnlockMutex(S3Mutex)
      *ConnectionParameter\ErrorString = ""
      ; Get the content of the directory
      If Not GetFilelist(*mappointer, *ConnectionParameter)
        FinishS3Directory(connectionNr)
        ProcedureReturn 0
      EndIf
    EndWith
    ProcedureReturn connectionNr
  EndProcedure
  
  
  Procedure FinishS3Directory(connection.i)
  ; Finish the enumeration started with ExamineS3Directory(). This frees the resources associated with the #Directory listing. 
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory().
    Shared S3Mutex.i, S3DirectoryExamineParamter.sS3DirectoryExamineParameter()
    
    If FindMapElement(S3DirectoryExamineParamter(), Str(connection)) = 0  ; Connection not open
     ProcedureReturn
    EndIf
    ; Close the connection
    LockMutex(S3Mutex)
    ClearList(S3DirectoryExamineParamter(Str(connection))\DirectoryList())
    DeleteMapElement(S3DirectoryExamineParamter(), Str(connection))
    UnlockMutex(S3Mutex)
  EndProcedure
  
  
  Procedure.i NextS3DirectoryEntry(connection.i, *ConnectionParameter.sConnectionParameter)
  ; This function must be called after an ExamineS3Directory(). It will go step-by-step into the directory and list its contents
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory(). 
  ; Returns
  ;   Returns nonzero if a new entry was read from the directory and zero if there are no more entries
  ; Remarks
  ;   The entry name can be read with the S3DirectoryEntryName() function. If you want to know whether 
  ;   an entry is a subdirectory Or a file, use the S3DirectoryEntryType() function.
    Shared S3DirectoryExamineParamter.sS3DirectoryExamineParameter()
    Protected *mappointer.sS3DirectoryExamineParameter
    
    *mappointer = FindMapElement(S3DirectoryExamineParamter(), Str(connection))
    If *mappointer = 0  ; Connection not open
       ProcedureReturn 0
    EndIf
    If NextElement(*mappointer\DirectoryList())
      ProcedureReturn 1
    EndIf
    ; Read next entries from s3 if there is a continuation token
    If *mappointer\ContinuationToken <> ""
      ClearList(*mappointer\DirectoryList())
      GetFilelist(*mappointer, *ConnectionParameter)
      If NextElement(*mappointer\DirectoryList())
        ProcedureReturn 1
      EndIf
    EndIf
    ClearList(*mappointer\DirectoryList())
    ProcedureReturn 0
  EndProcedure
  
  
  Procedure.s S3DirectoryEntryName(connection.i)
  ; Returns the name of the current entry in the directory being listed with ExamineS3Directory() and NextS3DirectoryEntry() functions
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory(). 
  ; Returns
  ;     Returns the name of the current directory entry. 
    Shared S3DirectoryExamineParamter.sS3DirectoryExamineParameter()
    Protected conncetionStr.s
    
    conncetionStr = Str(connection)
    If FindMapElement(S3DirectoryExamineParamter(), conncetionStr) = 0  ; Connection not open
     ProcedureReturn ""
    EndIf
    ProcedureReturn S3DirectoryExamineParamter(conncetionStr)\DirectoryList()\filename
  EndProcedure


  Procedure.i S3DirectoryEntrySize(connection.i)
  ; Returns the size of the current entry in the directory being listed with ExamineS3Directory() and NextS3DirectoryEntry() functions
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory(). 
  ; Returns
  ;     Returns the size of the current directory entry in bytes
    Shared S3DirectoryExamineParamter.sS3DirectoryExamineParameter()
    Protected conncetionStr.s
    
    conncetionStr = Str(connection)
    If FindMapElement(S3DirectoryExamineParamter(), conncetionStr) = 0  ; Connection not open
     ProcedureReturn 0
    EndIf
    ProcedureReturn S3DirectoryExamineParamter(conncetionStr)\DirectoryList()\filesize
  EndProcedure
  
  
  Procedure.i S3DirectoryEntryDate(connection.i)
  ; Returns the filedate of the current entry in the directory being listed with ExamineS3Directory() and NextS3DirectoryEntry() functions
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory(). 
  ; Returns
  ;     Returns the date of the current directory entry, for directories thsi is always the aktual date and time
    Shared S3DirectoryExamineParamter.sS3DirectoryExamineParameter()
    Protected conncetionStr.s
    
    conncetionStr = Str(connection)
    If FindMapElement(S3DirectoryExamineParamter(), conncetionStr) = 0  ; Connection not open
     ProcedureReturn 0
    EndIf
    ProcedureReturn S3DirectoryExamineParamter(conncetionStr)\DirectoryList()\filedate
  EndProcedure
  
  
  Procedure.i S3DirectoryEntryType(connection.i)
  ; Returns the type of the current entry in the directory being listed with ExamineS3Directory() and NextS3DirectoryEntry() functions
  ; Parameters
  ;   connection            The directory examined with ExamineS3Directory(). 
  ; Returns
  ;     Returns one of the following values: 
  ;     #PB_DirectoryEntry_File     : This entry is a file.
  ;     #PB_DirectoryEntry_Directory: This entry is a directory.
    Shared S3DirectoryExamineParamter.sS3DirectoryExamineParameter()
    Protected conncetionStr.s
    
    conncetionStr = Str(connection)
    If FindMapElement(S3DirectoryExamineParamter(), conncetionStr) = 0  ; Connection not open
     ProcedureReturn #PB_DirectoryEntry_File
    EndIf
    ProcedureReturn S3DirectoryExamineParamter(conncetionStr)\DirectoryList()\entrytype
  EndProcedure
  
  
  Procedure CopyFileFromS3(*ConnectionParameter.sConnectionParameter, S3Filename.s, PCFilename.s, PCFilenameMetadata.s="")
    ; Copies a file from S3 to PCFilename
    ; Returns the S3 metadata of the file
    *ConnectionParameter\ErrorString = ""
    ProcedureReturn downloadFile(*ConnectionParameter, S3Filename, PCFilename, PCFilenameMetadata)
  EndProcedure
  
  
  Procedure CopyFileToS3(*ConnectionParameter.sConnectionParameter, PCFilename.s, S3Filename.s, Map AdditionalHeader.s())
    ; Copies a PC File to an S3 file
    *ConnectionParameter\ErrorString = ""
    uploadFile(*ConnectionParameter, PCFilename, S3Filename, AdditionalHeader())
  EndProcedure
  
  
  Procedure DeleteFileFromS3(*ConnectionParameter.sConnectionParameter, S3Filename.s)
    ; Deletes a file from the S3 storage
    *ConnectionParameter\ErrorString = ""
    DeleteaFile(*ConnectionParameter, S3Filename)
  EndProcedure
  
  
  Procedure.i S3FileSize(*ConnectionParameter.sConnectionParameter, S3Filename.s)
    ; get the filesize for an S3 file
    ; Returns the size of the file in bytes, or one of the following values: 
    ;   -1: File Not found.
    ;   -2: Multiple files exist starting with the filename
    Protected DirectoryHandle.i, Countfiles.i=0, rwert.i=-1
    
    DirectoryHandle = HF_S3::ExamineS3Directory(#PB_Any, *ConnectionParameter, S3Filename, "")
    If DirectoryHandle
      If *ConnectionParameter\ErrorString = ""
        While HF_S3::NextS3DirectoryEntry(DirectoryHandle, *ConnectionParameter)
          Countfiles + 1
          rwert = HF_S3::S3DirectoryEntrySize(DirectoryHandle)
        Wend
      EndIf
    Else
      *ConnectionParameter\ErrorString = "S3 Directory couldn't be initialised."
    EndIf
    If Countfiles > 1
      rwert = -2
    EndIf
    ProcedureReturn rwert
  EndProcedure

EndModule  



;--- Test if started as main -------------------------------------
CompilerIf #PB_Compiler_IsMainFile = 1
  ; http://194.175.160.232:9020/san-prod-global/A3/4346048D32FB0050000000000A808F24/_data.Data

  Define prefix.s="T1/", delimiter.s=""
  Define ConPara.HF_S3::sConnectionParameter, DirectoryHandle.i, i.i, NewList ThreadList.i(), ID.i
  Define S3Filename.s, PCFilename.s, PCFilenameMetadata.s
  Define NewList S3Files.s(), ThreadMutex.i=CreateMutex()
  
  Procedure TestThread(value.i)
    Shared ConPara.HF_S3::sConnectionParameter, S3Files.s(), ThreadMutex.i
    Protected i.i, MyConPara.HF_S3::sConnectionParameter, S3Filename.s, PCFilename.s, PCFilenameMetadata.s
    
    MyConPara = ConPara
    Repeat
      LockMutex(ThreadMutex)
      If (ListSize(S3Files()) = 0)
        UnlockMutex(ThreadMutex)
        Break
      EndIf
      FirstElement(S3Files()) : S3Filename = S3Files() : DeleteElement(S3Files())
      UnlockMutex(ThreadMutex)
      PCFilename = "X:\Sanimed\A3-S3-Backup-2021-01-15\Test\" + Str(value) + ".dat"
      PCFilenameMetadata = PCFilename + ".meta"
      HF_S3::CopyFileFromS3(MyConPara, S3Filename, PCFilename, PCFilenameMetadata)
      If MyConPara\ErrorString <> ""
        PrintN(MyConPara\ErrorString)
      EndIf
    ForEver
  EndProcedure
  

  OpenConsole()
  ConPara\host = "194.175.160.232"
  ConPara\Port = "9020"
  ConPara\Bucket = "s3test"
  ConPara\SecretKey = "0YTkhZB6csvvh27aMp6OMr0wJIEN4i2YW7iXGePP"
  ConPara\AccessKey = "s3Test"
  PrintN("--- Open connection -----------------------------------------------------------------------------------------")
;   prefix = ""
;   delimiter = "/"
  
;   DirectoryHandle = HF_S3::ExamineS3Directory(#PB_Any, ConPara, prefix, delimiter)
;   PrintN("DirectoryHandle = " + Str(DirectoryHandle))
;   If DirectoryHandle
;     If HF_S3::GetLastError(DirectoryHandle) = ""
;       While HF_S3::NextS3DirectoryEntry(DirectoryHandle)
;         PrintN("Dirlist: " + HF_S3::S3DirectoryEntryName(DirectoryHandle) + "->" + 
;               FormatDate("%dd.%mm.%yyyy %hh:%ii:%ss", HF_S3::S3DirectoryEntryDate(DirectoryHandle)) + "->" +
;               HF_S3::S3DirectoryEntrySize(DirectoryHandle) + "->" +
;               HF_S3::S3DirectoryEntryType(DirectoryHandle))
;       Wend
;     Else
;       PrintN(HF_S3::GetLastError(DirectoryHandle))
;     EndIf
;   Else
;     PrintN("ERROR: S3 Directory couldn't be initialised.")
;   EndIf
  
  PrintN("Read datafile")
  infile = ReadFile(#PB_Any, "X:\Sanimed\A3-S3-Backup-2021-01-15\Test.txt")
  If infile
    While Eof(infile) = 0
      AddElement(S3Files()) : S3Files() = ReadString(infile)
    Wend
  Else
    PrintN("Can't open X:\Sanimed\A3-S3-Backup-2021-01-15\Test.txt")
  EndIf
  PrintN("Start reading")
  i = 0
  While ListSize(S3Files()) <> 0
    FirstElement(S3Files()) : S3Filename = S3Files() : DeleteElement(S3Files())
    PCFilename = "X:\Sanimed\A3-S3-Backup-2021-01-15\Test\" + Str(value) + ".dat"
    PCFilenameMetadata = PCFilename + ".meta"
    HF_S3::CopyFileFromS3(ConPara, S3Filename, PCFilename, PCFilenameMetadata)
    i + 1
    If i % 1000 = 0
      PrintN(Str(i))
    EndIf
;     If ConPara\ErrorString <> ""
;       PrintN(ConPara\ErrorString)
;     EndIf
  Wend
  Print("Weiter mit Return...")
  Input()
  CloseConsole()
CompilerEndIf

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 560
; FirstLine = 549
; Folding = ------
; EnableThread
; EnableXP
; CompileSourceDirectory