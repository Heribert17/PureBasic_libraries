; ---------------------------------------------------------------------------------------
;
; Modul for additional cipher functions
;
; Author:  Heribert Füchtenhans
; Version: 1.0
; OS:      Windows, Linux, Mac
;
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



DeclareModule HF_Cipher
  
  Declare.s hmac_256(key.s, msg.s, DecodeKeyFromHex.b=#False)
  ; Create hmac_256 hash string
  ;
  ; key = key to sign with
  ; msg = message to sign
  ; DecodeKeyFromHex = if True, the key is as hexadecimal string (another hash value) that must
  ;     be converted to ist binary values bevor.
  ;     Example:
  ;     The key is "10ab5f4d" that values will be converted to their binary values $10$ab$5f$4d
  ;     This is neede for example ig you create S3 signining keys
  ;
  ; see: https://en.wikipedia.org/wiki/HMAC
  ; see for c implementation: http://www.ouah.org/ogay/hmac/
  ; You may use https://codebeautify.org/hmac-generator fro testing
  
  Declare.s AESEncodeToHexString(StringToDecode.s, *AESKey, *AESVector)
  ; Decode String to an Hexstring using AESDecode, for AESKey and AESVecotor see PublureBasic Help about AESEncode
  ; Return: The AESDecodes String as a string of 2 Chars HEX Values
  
  
  Declare.s AESDecodeFromHexString(HexStringToEncode.s, *AESKey, *AESVector)
  ; Encodes a HEX String, AESKey and AESVector mus be the same as used by AESDEcodeToHexString
  ; Return: The encode HEX String.
  
  
  Declare.s MD5HashBase64Decoded(MD5HashString.s)
  ; Converts the MD5 Hex String into a base64 decoded string
  ; Return: The decoded MD5 String
EndDeclareModule



Module HF_Cipher
  
  EnableExplicit
  
  ; Create hmac_256 hash string
  ;
  ; key = key to sign with
  ; msg = message to sign
  ; DecodeKeyFromHex = if True, the key is as hexadecimal string (another hash value) that must
  ;     be converted to ist binary values bevor.
  ;     Example:
  ;     The key is "10ab5f4d" that values will be converted to their binary values $10$ab$5f$4d
  ;     This is neede for example ig you create S3 signining keys
  ;     see Test belove
  ;
  ; see: https://en.wikipedia.org/wiki/HMAC
  ; see for c implementation: http://www.ouah.org/ogay/hmac/
  ; You may use https://codebeautify.org/hmac-generator fro testing
  Procedure.s hmac_256(key.s, msg.s, DecodeKeyFromHex.b=#False)
    Protected i.i, rwert.s, inner_fingerprint.s
    Protected *keybuffer, *messagebuffer, *opadbuffer, *ipadbuffer, *ipad, UsedFingerprint.i
    #BLOCKSIZE = 512 / 8   ; for sha-256
    #SHA256_DIGEST_SIZE = 256 / 8
    
    UseSHA2Fingerprint()
    ; Adjust the key to #SHA256_DIGEST_SIZE
    If DecodeKeyFromHex
      *keybuffer = AllocateMemory(Len(key) / 2)
      For i = 0 To (Len(key) / 2) - 1
        PokeB(*keybuffer+i, Val("$" + Mid(key, i*2+1, 2)))
      Next i
    Else
      *keybuffer = UTF8(key)
    EndIf
    ; Keys longer than blockSize are shortened by hashing them
    If MemorySize(*keybuffer)-1 > #BLOCKSIZE
      FreeMemory(*keybuffer)
      *keybuffer = AllocateMemory(#SHA256_DIGEST_SIZE+1)    ; Because UTF8 function used above adds \0 to end of string
      rwert = StringFingerprint(key, #PB_Cipher_SHA2, 256)
      ; Transfer Hex String back to binary
      For i = 0 To #SHA256_DIGEST_SIZE-1
        PokeB(*keybuffer+i, Val("$" + Mid(rwert, i*2+1, 2)))
      Next i
    EndIf
    ; Keys shorter than blockSize are padded to blockSize by padding with zeros on the right
    If MemorySize(*keybuffer)-1 < #BLOCKSIZE
      *keybuffer = ReAllocateMemory(*keybuffer, #BLOCKSIZE+1)    ; Because UTF8 function used above adds \0 to end of string
    EndIf
    
    ; Create the inner and outer paddings
    *opadbuffer = AllocateMemory(#BLOCKSIZE)
    *ipadbuffer = AllocateMemory(#BLOCKSIZE)
    For i = 0 To #BLOCKSIZE-1
      PokeB(*ipadbuffer+i, PeekB(*keybuffer+i) ! $36)
      PokeB(*opadbuffer+i, PeekB(*keybuffer+i) ! $5c)
    Next i
    ; create hash value to return hash(o_key_pad + hash(i_key_pad + message))
    *messagebuffer = UTF8(msg)
    UsedFingerprint = StartFingerprint(#PB_Any, #PB_Cipher_SHA2, 256)
    UseSHA2Fingerprint()
    AddFingerprintBuffer(UsedFingerprint, *ipadbuffer, #BLOCKSIZE)
    AddFingerprintBuffer(UsedFingerprint, *messagebuffer, MemorySize(*messagebuffer)-1)
    inner_fingerprint = FinishFingerprint(UsedFingerprint)
    ; Convert string from inner_fingerprint back to Hex values
    *ipad = AllocateMemory(#SHA256_DIGEST_SIZE)
    For i = 0 To #SHA256_DIGEST_SIZE-1
      PokeB(*ipad+i, Val("$" + Mid(inner_fingerprint, i*2+1, 2)))
    Next i
    UsedFingerprint = StartFingerprint(#PB_Any, #PB_Cipher_SHA2, 256)
    AddFingerprintBuffer(UsedFingerprint, *opadbuffer, #BLOCKSIZE)
    AddFingerprintBuffer(UsedFingerprint, *ipad, #SHA256_DIGEST_SIZE)
    rwert = FinishFingerprint(UsedFingerprint)
    ; Free all allocated memory
    FreeMemory(*ipad)
    FreeMemory(*ipadbuffer)
    FreeMemory(*opadbuffer)
    FreeMemory(*messagebuffer)
    FreeMemory(*keybuffer)
    ProcedureReturn rwert
  EndProcedure
  
  
  Procedure.s AESEncodeToHexString(StringToDecode.s, *AESKey, *AESVector)
    ; Decode String to an Hexstring using AESDecode, for AESKey and AESVecotor see PublureBasic Help about AESEncode
    ; Return: The AESDecodes String as a string of 2 Chars HEX Values
    Protected StringMemorySize.i, i.i, outstring.s=StringToDecode, *CipheredString
    
    If Len(StringToDecode) < 16
      StringToDecode = LSet(StringToDecode, 16, " ")
    EndIf
    StringMemorySize = StringByteLength(StringToDecode) + SizeOf(Character) ; Space for the string and its null terminating character
    *CipheredString = AllocateMemory(StringMemorySize)   
    If AESEncoder(@StringToDecode, *CipheredString, StringByteLength(StringToDecode), *AESKey, 128, *AESVector)
      outstring = ""
      For i = 0 To StringByteLength(StringToDecode) - 1
        outstring + RSet(Hex(PeekB(*CipheredString+i), #PB_Byte), 2, "0")
      Next i
      FreeMemory(*CipheredString)
    EndIf
    ProcedureReturn outstring
  EndProcedure
  
  
  Procedure.s AESDecodeFromHexString(HexStringToEncode.s, *AESKey, *AESVector)
    ; Encodes a HEX String, AESKey and AESVector mus be the same as used by AESDEcodeToHexString
    ; Return: The encode HEX String.
    Protected StringMemorySize.i, i.i, outstring.s, *CipheredString, *DecipheredString
    
    StringMemorySize = StringByteLength(HexStringToEncode) / 2 + SizeOf(Character) ; Space for the string and its null terminating character
    *CipheredString = AllocateMemory(StringMemorySize)
    *DecipheredString = AllocateMemory(StringMemorySize) 
    ; Hex to string in memory
    For i = 0 To (Len(HexStringToEncode) / 2)   ; without -1 because of trailing \0
      PokeB(*CipheredString+i, Val("$" + Mid(HexStringToEncode, i*2+1, 2)))
    Next i
    AESDecoder(*CipheredString, *DecipheredString, Len(HexStringToEncode) / 2, *AESKey, 128, *AESVector)
    outstring = Trim(PeekS(*DecipheredString))
    FreeMemory(*CipheredString)
    FreeMemory(*DecipheredString)
    ProcedureReturn outstring
  EndProcedure
  
    
  Procedure.s MD5HashBase64Decoded(MD5HashString.s)
  ; Converts the MD5 Hex String into a base64 decoded string
  ; Return: The decoded MD5 String
    Protected *buffer, buffersize.i, i.i, rwert.s
    
    buffersize = Len(MD5HashString) / 2
    *buffer = AllocateMemory(Len(MD5HashString) / 2)
    ; Hex to string in memory
    For i = 0 To buffersize   ; without -1 because of trailing \0
      PokeB(*buffer+i, Val("$" + Mid(MD5HashString, i*2+1, 2)))
    Next i
    rwert = Base64Encoder(*buffer, buffersize) 
    FreeMemory(*buffer)
    ProcedureReturn rwert
  EndProcedure

EndModule


; --- Test --------------------------------------------------------------------------------------------
CompilerIf #PB_Compiler_IsMainFile = 1
  OpenConsole()
  
  PrintN("HMAC Test")
  PrintN("Is:     " + HF_Cipher::hmac_256("key", "The quick brown fox jumps over the lazy dog"))
  PrintN("Should: " + "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8")
  PrintN("")
  PrintN("Is:     " + HF_Cipher::hmac_256("6b6579", "The quick brown fox jumps over the lazy dog", #True))
  PrintN("Should: " + "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8")
  PrintN("")
  PrintN("Is:     " + HF_Cipher::hmac_256("Füchtenhans", "The quick brown fox jumps over the lazy dogüüü"))
  PrintN("Should: " + "c1df8981d29dd3dab7309c9f1b347858f394ebac5a63d88c8ba54151f3b6f7cb")
  PrintN("")
  PrintN("")
  PrintN("AES to Hex Test")
  PrintN("Is:     " + HF_Cipher::AESDecodeFromHexString(HF_Cipher::AESEncodeToHexString("The quick brown fox jumps over the lazy dog. äöüßÄÖÜ", ?Key, 
                                                                                        ?InitializationVector), ?Key, ?InitializationVector))
  PrintN("Should: " + "The quick brown fox jumps over the lazy dog. äöüßÄÖÜ")
  Print("Continue with Return...")
  Input()
  CloseConsole()

  DataSection
    Key:
      Data.b $06, $a9, $21, $40, $36, $b8, $a1, $5b, $51, $2e, $03, $d5, $34, $12, $00, $06
  
    InitializationVector:
      Data.b $3d, $af, $ba, $42, $9d, $9e, $b4, $30, $b4, $22, $da, $80, $2c, $9f, $ac, $41
  EndDataSection
  
CompilerEndIf



; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 128
; FirstLine = 93
; Folding = --
; EnableXP
; CompileSourceDirectory