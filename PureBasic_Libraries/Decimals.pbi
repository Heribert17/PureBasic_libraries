;|¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;|  Titel....: Dezimalzahlen / Decimals
;|  Datei....: Decimal.pbi
;|  Datum....: 22.12.2009
;|  Inhalt...: * Rechnen mit (unlimitierten) Dezimalzahlen
;|             * Calculating with (unlimited) Decimals
;|_____________________________________________________________________________






;  Vorausgesetzte Includes 
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯






;  Konstanten
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯



 #Decimal_FieldSize      = 9            ; Dezimalstellen eines Feldes
 #Decimal_FieldValue     = 1000000000   ; mögliche Dezimalzahlen eines Feldes
 
 #NoDecimal       = 0
 #FirstDecimal    = 1
 #SecondDecimal   = 2
 #BothDecimal     = 3


 



;  Strukturen
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯



 ; Struktur einer Dezimalzahl
 Structure Decimal
  Sign.i                     ; Vorzeichen
  Magnitude.i                ; GigaPotenz ... (10^9)^Magnitude
  StructureUnion
   Size.l                    ; Anzahl der Felder
   Field.l[0]                ; Feld (beginnend bei 1 bis Size, 0 wäre Size selbst)
  EndStructureUnion
 EndStructure






;  Arrays und LinkedLists
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯






;  Proceduren und Macros
;¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯



 ; Interne Prozeduren
 ;- - - - - - - - - - -

 Procedure Decimal_GetMaxField(String$)
  Protected Length = Len(String$)
  If Not Length
   ProcedureReturn 0
  ElseIf Length % #Decimal_FieldSize
   ProcedureReturn Int(Length/#Decimal_FieldSize)+1
  Else
   ProcedureReturn Int(Length/#Decimal_FieldSize)
  EndIf 
 EndProcedure

 Procedure Decimal_GetMax(Value1, Value2)
  If Value1 < Value2
   ProcedureReturn Value2
  Else
   ProcedureReturn Value1
  EndIf
 EndProcedure
 
 Procedure Decimal_GetMin(Value1, Value2)
  If Value1 < Value2
   ProcedureReturn Value1
  Else
   ProcedureReturn Value2
  EndIf
 EndProcedure

 Procedure Decimal_UnsignedCompare(*Decimal1.Decimal, *Decimal2.Decimal)
  Protected Field, MaxField, MinField
  If *Decimal1\Size+*Decimal1\Magnitude < *Decimal2\Size+*Decimal2\Magnitude
   ProcedureReturn -1
  ElseIf *Decimal1\Size+*Decimal1\Magnitude > *Decimal2\Size+*Decimal2\Magnitude
   ProcedureReturn 1
  Else
   MaxField = *Decimal1\Size+*Decimal1\Magnitude
   MinField = Decimal_GetMax(*Decimal1\Magnitude, *Decimal2\Magnitude) + 1
   For Field = MaxField To MinField Step -1
    If *Decimal1\Field[Field-*Decimal1\Magnitude] < *Decimal2\Field[Field-*Decimal2\Magnitude]
     ProcedureReturn -1
    ElseIf *Decimal1\Field[Field-*Decimal1\Magnitude] > *Decimal2\Field[Field-*Decimal2\Magnitude]
     ProcedureReturn 1
    EndIf
   Next
   If *Decimal1\Size < *Decimal2\Size
    ProcedureReturn -1
   ElseIf *Decimal1\Size > *Decimal2\Size
    ProcedureReturn 1
   Else 
    ProcedureReturn 0
   EndIf
  EndIf
 EndProcedure  

 ;- - - - - - - - - - -



 ; Erstellt den Speicher für eine Dezimalzahl
 ;  (und nutz dabei, wenn angegeben, den alten Speicher)
 Procedure CreateDecimal(Size, *Decimal.Decimal=0)
  If *Decimal
   If *Decimal\Size <> Size
    *Decimal = ReAllocateMemory(*Decimal, SizeOf(Decimal)+Size*SizeOf(Long))
    *Decimal\Size = Size
   EndIf
  Else
   *Decimal = AllocateMemory(SizeOf(Decimal)+Size*SizeOf(Long))
   *Decimal\Size = Size
  EndIf
  ProcedureReturn *Decimal
 EndProcedure



 ; Kopiert eine Dezimalzahl und gibt die Kopie zurück
 Procedure CopyDecimal(*Decimal.Decimal)
  Protected *ReturnDecimal = CreateDecimal(*Decimal\Size)
  CopyMemory(*Decimal, *ReturnDecimal, SizeOf(Decimal)+*Decimal\Size*SizeOf(Long))
  ProcedureReturn *ReturnDecimal
 EndProcedure



 ; Gibt der Speicher eine Dezimalzahl frei
 Procedure FreeDecimal(*Decimal.Decimal)
  FreeMemory(*Decimal)
 EndProcedure



 ; Gibt detailierte Informationen zu einer Dezimalzahl als string zurück
 Procedure.s DebugDecimal(*Decimal.Decimal)
  Protected String$, Field
  With *Decimal
   If \Sign = -1
    String$ + " - "
   Else
    String$ + " + "
   EndIf
   For Field = \Size To 1 Step -1
    String$ + " "+RSet(Str(\Field[Field]), #Decimal_FieldSize, "0")
   Next 
   String$ + "  *10^  "+Str(\Magnitude*#Decimal_FieldSize) 
  EndWith
  ProcedureReturn String$
 EndProcedure



 ; Optimiert eine Dezimalzahl (löscht führende und endende Nullen)
 Procedure OptimizeDecimal(*Decimal.Decimal)
  Protected Field = 1
  With *Decimal
   If \Size
    If Not \Field[Field]
     Repeat
      \Size - 1
      \Magnitude + 1
      Field + 1
     Until Not \Size Or \Field[Field]
     If \Size
      MoveMemory(@*Decimal\Field[Field], @*Decimal\Field[1], \Size*SizeOf(Long))
     EndIf
    EndIf
    While \Size And Not \Field[\Size]
     \Size - 1
    Wend
    If Not \Size
     \Magnitude = 0
     \Sign = 1
    EndIf
    ProcedureReturn CreateDecimal(\Size, *Decimal)
   Else
    *Decimal\Sign = 1
    *Decimal\Magnitude = 0
    ProcedureReturn *Decimal
   EndIf
  EndWith
 EndProcedure



 ;- - - - - - - - - - -
  
 

 ; Wandelt eine Zeichenkette in eine Dezimalzahl um und gibt diese zurück
 Procedure StringToDecimal(String$)
  Protected High$, Low$, HighSize, LowSize, Trim, HighTrim, LowTrim
  Protected Field, Sign = 1, Magnitude = 0, Position
  String$ = RemoveString(String$, " ")
  If String$ = ""
   String$ = "0"
  ElseIf Left(String$,1) = "-" 
   Sign = -1 : String$ = Mid(String$, 2)
  EndIf
  High$ = LTrim(StringField(String$, 1, "."),"0")
  Low$ = RTrim(StringField(String$, 2, "."),"0")
  HighSize = Decimal_GetMaxField(High$)
  LowSize = Decimal_GetMaxField(Low$)
  High$ = RSet(High$, HighSize*#Decimal_FieldSize, "0")
  Low$ = LSet(Low$, LowSize*#Decimal_FieldSize, "0")
  String$ = High$ + Low$
  Magnitude = -LowSize
  If Not LowSize
   HighTrim = Int((Len(High$)-Len(RTrim(High$,"0")))/#Decimal_FieldSize)
   Magnitude + HighTrim
   HighSize - HighTrim
  EndIf
  If Not HighSize
   LowTrim = Int((Len(Low$)-Len(LTrim(Low$,"0")))/#Decimal_FieldSize)
   LowSize - LowTrim
  EndIf
  Protected *Decimal.Decimal = CreateDecimal(HighSize+LowSize)
  If *Decimal
   With *Decimal
    \Sign = Sign
    \Magnitude = Magnitude
    For Field = 1 To \Size
     Position = 1 + Len(String$) - (Field+HighTrim)*#Decimal_FieldSize 
     \Field[Field] = Val(Mid(String$, Position, #Decimal_FieldSize))
    Next
   EndWith
  EndIf
  ProcedureReturn *Decimal
 EndProcedure



 ; Wandelt eine Long oder Quad in eine Dezimalzahl um und gibt diese zurück
 Procedure IntegerToDecimal(Integer.q)
  Protected Size = 2, Sign = 1, Magnitude = 0, Field
  If Integer < #Decimal_FieldValue And Integer > -#Decimal_FieldValue
   Size = 1
  EndIf
  If Not Integer % #Decimal_FieldValue
   Size = 1
   Magnitude = 1
   Integer = Int(Integer/#Decimal_FieldValue)
  EndIf
  If Integer < 0
   Sign = -1
   Integer * -1
  EndIf
  If Integer = 0
   Size = 0
   Magnitude = 0
  EndIf
  Protected *Decimal.Decimal = CreateDecimal(Size)
  If *Decimal
   With *Decimal
    \Sign = Sign
    \Magnitude = Magnitude
    For Field = 1 To \Size
     \Field[Field] = Integer % #Decimal_FieldValue
     Integer = Int(Integer/#Decimal_FieldValue)
    Next
   EndWith
  EndIf
  ProcedureReturn *Decimal
 EndProcedure



 ; Wandelt eine Dezimalzahl in eine Integer (Long oder Quad) um und gibt diese zurück
 ;   (und gibt, wenn gewünscht, den Speicher wieder frei)
 Procedure.q DecimalToInteger(*Decimal.Decimal, Delete=#FirstDecimal)
  Protected Integer.q, Field, Magnitude
  With *Decimal 
   If \Size
    For Field = \Size To 1 Step -1
     Integer * #Decimal_FieldValue
     Integer + \Field[Field]
    Next
    For Magnitude = 1 To \Magnitude
     Integer * #Decimal_FieldValue
    Next
    Integer * \Sign
   Else
    Integer = 0
   EndIf
  EndWith
  ProcedureReturn Integer
 EndProcedure



 ; Wandelt eine Dezimalzahl in eine Double um und gibt diese zurück
 ;   (und gibt, wenn gewünscht, den Speicher wieder frei)
 Procedure.d DecimalToDouble(*Decimal.Decimal, Delete=#FirstDecimal)
  Protected Double.d, Field
  With *Decimal 
   If \Size
    For Field = \Size To 1 Step -1
     Double * #Decimal_FieldValue
     Double + \Field[Field]
    Next
    Double * Pow(10, \Magnitude*#Decimal_FieldSize)
    Double * \Sign
   Else
    Double = 0
   EndIf
  EndWith
  ProcedureReturn Double
 EndProcedure



 ; Wandelt eine Dezimalzahl in eine Zeichenkette um und gibt diese zurück
 ;   (und gibt wenn gewünscht den Speicher wieder frei)
 Procedure.s DecimalToString(*Decimal.Decimal, Delete=#FirstDecimal)
  Protected String$, Field
  With *Decimal
   If \Sign = -1
    String$ + "-"
   EndIf
   If \Size
    If -\Magnitude >= \Size
     ; nur Low
     String$ + "0."
     String$ + LSet("", (-(\Size+\Magnitude))*#Decimal_FieldSize, "0")
     For Field = \Size To 2 Step -1
      String$ + RSet(Str(\Field[Field]), #Decimal_FieldSize, "0")
     Next
     String$ + RTrim(RSet(Str(\Field[1]), #Decimal_FieldSize, "0"), "0")
    ElseIf \Magnitude >= 0
     ; nur High
     String$ + Str(\Field[\Size])
     For Field = \Size-1 To 1 Step -1
      String$ + RSet(Str(\Field[Field]), #Decimal_FieldSize, "0")
     Next
     String$ + LSet("", (\Magnitude)*#Decimal_FieldSize, "0")
    Else
     ; gemischt
     String$ + Str(\Field[\Size])
     For Field = \Size-1 To 2 Step -1
      If Field = -\Magnitude
       String$ + "."
      EndIf
      String$ + RSet(Str(\Field[Field]), #Decimal_FieldSize, "0")
     Next
     If \Magnitude = -1
      String$ + "."
     EndIf
     String$ + RTrim(RSet(Str(\Field[1]), #Decimal_FieldSize, "0"), "0")
    EndIf
   Else
    String$ + "0"
   EndIf
  EndWith
  If Delete & #FirstDecimal  : FreeDecimal(*Decimal) : EndIf
  ProcedureReturn String$
 EndProcedure



 ; Vordefinieren einiger wichtiger Zahlen
 Global Dim *ConstantDecimal(11), ConstantDecimal.i
 For ConstantDecimal = 0 To 10
  *ConstantDecimal(ConstantDecimal) = StringToDecimal(Str(ConstantDecimal))
 Next
 *ConstantDecimal(11) = StringToDecimal("0.5")



 ; Rundet eine Decimalzahl und gibt diese zurück
 Procedure CutDecimal(*Decimal.Decimal, Position=0, Delete=#FirstDecimal)
  Protected LowSize, Size, Long.l
  Protected *ReturnDecimal.Decimal
  With *ReturnDecimal
   If Position % #Decimal_FieldSize
    LowSize = Round(Position/#Decimal_FieldSize, #PB_Round_Down)+1
   Else
    LowSize = Round(Position/#Decimal_FieldSize, #PB_Round_Down)
   EndIf
   Size = *Decimal\Size + *Decimal\Magnitude + LowSize
   If Size < *Decimal\Size 
    If Size > 0
     *ReturnDecimal = CreateDecimal(Size)
     \Sign = *Decimal\Sign
     \Magnitude = *Decimal\Magnitude + (*Decimal\Size - Size)
     CopyMemory(@*Decimal\Field[*Decimal\Size-Size+1], @\Field[1], Size*SizeOf(Long))
     Long = Pow(10,LowSize*#Decimal_FieldSize-Position)
     \Field[1] - (\Field[1]%Long)
     *ReturnDecimal = OptimizeDecimal(*ReturnDecimal)
    Else
     *ReturnDecimal = CreateDecimal(0)
     \Sign = *Decimal\Sign
     \Magnitude = 0
    EndIf    
   ElseIf *Decimal\Magnitude < 0
    *ReturnDecimal = CopyDecimal(*Decimal)
    Long = Pow(10,LowSize*#Decimal_FieldSize-Position)
    \Field[1] - (\Field[1]%Long)    
   Else
    *ReturnDecimal = CopyDecimal(*Decimal)
   EndIf
  EndWith
  If Delete & #FirstDecimal  : FreeDecimal(*Decimal) : EndIf
  ProcedureReturn *ReturnDecimal 
 EndProcedure



 ; Gibt die Präzision einer Decimalzahl zurück
 Procedure DecimalPrecision(*Decimal.Decimal)
  Protected Precision, n, Power = 10
  With *Decimal
   Precision = \Size*#Decimal_FieldSize
   If \Size
    Precision - #Decimal_FieldSize + Round(Log10(\Field[\Size])+1, #PB_Round_Down)
    For n = 0 To #Decimal_FieldSize-1
     If \Field[1] % Power
      Break
     EndIf
     Power * 10
    Next
    Precision - n
   EndIf
  EndWith
  ProcedureReturn Precision
 EndProcedure



 ; Vergleich zwei Dezimalzahlen und gibt zurück ob *Decimal1
 ; größer (1), kleiner (-1) oder gleich (0) ist als *Decimal2
 Procedure CompareDecimal(*Decimal1.Decimal, *Decimal2.Decimal)
  If *Decimal1\Sign < *Decimal2\Sign
   ProcedureReturn -1
  ElseIf *Decimal1\Sign > *Decimal2\Sign
   ProcedureReturn 1
  ElseIf *Decimal1\Sign = 1
   ProcedureReturn Decimal_UnsignedCompare(*Decimal1, *Decimal2)
  ElseIf *Decimal1\Sign = -1
   ProcedureReturn -Decimal_UnsignedCompare(*Decimal1, *Decimal2)
  Else
   ProcedureReturn 0
  EndIf
 EndProcedure



 ;- - - - - - - - - - -



 ; Addiert zwei Dezimalzahlen und gibt das Ergebnis zurück
 Procedure PlusDecimal(*Decimal1.Decimal, *Decimal2.Decimal, Delete=#BothDecimal)
  Protected Field, Field1, Field2
  Protected Result.q, Transfer.q, Sign.i
  Protected Magnitude = Decimal_GetMin(*Decimal1\Magnitude, *Decimal2\Magnitude)
  Protected HighSize = Decimal_GetMax(*Decimal1\Size+*Decimal1\Magnitude, *Decimal2\Size+*Decimal2\Magnitude)
  Protected UnsignedCompare = Decimal_UnsignedCompare(*Decimal1, *Decimal2)
  Protected *Decimal.Decimal = CreateDecimal(HighSize-Magnitude)
  With *Decimal
   If *Decimal1\Sign = *Decimal2\Sign
    \Sign = *Decimal1\Sign : Sign = 1
   ElseIf UnsignedCompare < 0
    \Sign = *Decimal2\Sign : Sign = -1
    Swap *Decimal1, *Decimal2
   Else
    \Sign = *Decimal1\Sign : Sign = -1
   EndIf
   \Magnitude = Magnitude
   For Field = 1 To \Size
    Field1 = \Magnitude - *Decimal1\Magnitude + Field
    Field2 = \Magnitude - *Decimal2\Magnitude + Field
    Result = #Decimal_FieldValue
    If Field1 > 0 And Field1 <= *Decimal1\Size     
     Result + *Decimal1\Field[Field1]
    EndIf
    If Field2 > 0 And Field2 <= *Decimal2\Size     
     Result + *Decimal2\Field[Field2] * Sign
    EndIf
    Result + Transfer
    \Field[Field] = Result % #Decimal_FieldValue
    Transfer = IntQ(Result/#Decimal_FieldValue)-1
   Next
   If Transfer
    *Decimal = CreateDecimal(\Size+1, *Decimal)
    \Field[\Size] = Transfer
   EndIf
  EndWith
  If Delete & #FirstDecimal  : FreeDecimal(*Decimal1) : EndIf
  If Delete & #SecondDecimal And *Decimal1 <> *Decimal2 : FreeDecimal(*Decimal2) : EndIf
  ProcedureReturn OptimizeDecimal(*Decimal)
 EndProcedure



 ; Subtrahiert zwei Dezimalzahlen und gibt das Ergebnis zurück
 Procedure MinusDecimal(*Decimal1.Decimal, *Decimal2.Decimal, Delete=#BothDecimal)
  Protected *Decimal.Decimal
  If *Decimal1 = *Decimal2
   If Delete & #FirstDecimal  : FreeDecimal(*Decimal1) : EndIf
   If Delete & #SecondDecimal And *Decimal1 <> *Decimal2 : FreeDecimal(*Decimal2) : EndIf   
   ProcedureReturn CopyDecimal(*ConstantDecimal(0))
  ElseIf *Decimal2\Size = 0
   *Decimal = CopyDecimal(*Decimal1)
   If Delete & #FirstDecimal  : FreeDecimal(*Decimal1) : EndIf
   If Delete & #SecondDecimal And *Decimal1 <> *Decimal2 : FreeDecimal(*Decimal2) : EndIf   
   ProcedureReturn *Decimal
  Else
   *Decimal2\Sign * -1
   *Decimal = PlusDecimal(*Decimal1, *Decimal2, Delete)
   If Not Delete & #SecondDecimal
    *Decimal2\Sign * -1
   EndIf
   ProcedureReturn *Decimal
  EndIf
 EndProcedure



 ; Multipliziert zwei Dezimalzahlen und gibt das Ergebnis zurück
 Procedure TimesDecimal(*Decimal1.Decimal, *Decimal2.Decimal, Delete=#BothDecimal)
  Protected Field, Field1, Field2
  Protected *Decimal.Decimal = CreateDecimal(*Decimal1\Size+*Decimal2\Size)
  Protected Transfer.q, Dim Result.q(*Decimal\Size)
  With *Decimal
   \Sign = *Decimal1\Sign * *Decimal2\Sign
   \Magnitude = *Decimal1\Magnitude + *Decimal2\Magnitude
   For Field1 = 1 To *Decimal1\Size
    For Field2 = 1 To *Decimal2\Size
     Field = Field1 + Field2 - 1
     Result(Field) + ( *Decimal1\Field[Field1] * *Decimal2\Field[Field2] )
     Transfer = IntQ(Result(Field)/#Decimal_FieldValue)
     While Transfer
      Result(Field+1) + Transfer
      Result(Field) % #Decimal_FieldValue 
      Field + 1
      Transfer = IntQ(Result(Field)/#Decimal_FieldValue)
     Wend
    Next
   Next 
   For Field = 1 To \Size
    \Field[Field] = Result(Field)
   Next
  EndWith
  If Delete & #FirstDecimal  : FreeDecimal(*Decimal1) : EndIf
  If Delete & #SecondDecimal And *Decimal1 <> *Decimal2 : FreeDecimal(*Decimal2) : EndIf
  ProcedureReturn OptimizeDecimal(*Decimal)
 EndProcedure



 ; Gibt die Fakultät einer ganzzahligen Dezimalzahl zurück
 Procedure FactorialDecimal(*Decimal.Decimal, Delete=#FirstDecimal)
  Protected *ReturnDecimal = CopyDecimal(*ConstantDecimal(1))
  Protected *TimesDecimal  = CopyDecimal(*ConstantDecimal(2))
  While CompareDecimal(*TimesDecimal, *Decimal) < 1
   *ReturnDecimal = TimesDecimal(*ReturnDecimal, *TimesDecimal, #FirstDecimal)
   *TimesDecimal = PlusDecimal(*TimesDecimal, *ConstantDecimal(1), #FirstDecimal)
  Wend
  FreeDecimal(*TimesDecimal)
  If Delete & #FirstDecimal  : FreeDecimal(*Decimal) : EndIf
  ProcedureReturn *ReturnDecimal
 EndProcedure



 ; Dividiert zwei Dezimalzahlen und gibt das Ergebnis zurück
 Procedure DivideDecimal(*Decimal1.Decimal, *Decimal2.Decimal, Precision=0, *Rest.Integer=0, Delete=#BothDecimal)
  Protected *Decimal.Decimal
  Protected *TempDecimal1.Decimal = CopyDecimal(*Decimal1) : *TempDecimal1\Sign = 1
  Protected *TempDecimal2.Decimal = CopyDecimal(*Decimal2) : *TempDecimal2\Sign = 1
  If Not *TempDecimal2\Size 
   *Decimal = CopyDecimal(*Decimal1)
   If Delete & #FirstDecimal  : FreeDecimal(*Decimal1) : EndIf
   If Delete & #SecondDecimal : FreeDecimal(*Decimal2) : EndIf
   ProcedureReturn *Decimal
  EndIf
  Protected Dim *Multiple.Decimal(9), Multiple.i, TimesCount.i
  Protected Position, Result$, NotNull = #False
  Protected ShiftMagnitude = (*Decimal1\Size-*Decimal2\Size) + (*Decimal1\Magnitude-*Decimal2\Magnitude)
  Protected Sign = *Decimal1\Sign * *Decimal2\Sign
  If ShiftMagnitude < 0
   *TempDecimal1\Magnitude - ShiftMagnitude
   Position = (ShiftMagnitude)*#Decimal_FieldSize
   TimesCount = -Position
  ElseIf ShiftMagnitude > 0
   *TempDecimal2\Magnitude + ShiftMagnitude 
   Position = (ShiftMagnitude)*#Decimal_FieldSize
  EndIf
  If *TempDecimal1\Field[*TempDecimal1\Size] > *TempDecimal2\Field[*TempDecimal2\Size]
   *TempDecimal2\Magnitude + 1
   Position + #Decimal_FieldSize
  EndIf 
  *Multiple(0) = *ConstantDecimal(0)
  *Multiple(1) = *TempDecimal2
  For Multiple = 2 To 9 
   *Multiple(Multiple) = TimesDecimal(*TempDecimal2, *ConstantDecimal(Multiple), #NoDecimal)
  Next
  If Position < 0
   Result$ + LSet(".", -Position, "0")
  EndIf 
  If Not Precision
   Precision = Position+1
   NotNull = #True
  EndIf
  While Decimal_UnsignedCompare(*TempDecimal1, *ConstantDecimal(0)) And Precision > 0
   If Decimal_UnsignedCompare(*TempDecimal1, *Multiple(1)) >= 0
    For Multiple = 9 To 1 Step -1
     If Decimal_UnsignedCompare(*TempDecimal1, *Multiple(Multiple)) >= 0
      Result$ + Str(Multiple)
      *TempDecimal1 = MinusDecimal(*TempDecimal1, *Multiple(Multiple), #FirstDecimal)
      NotNull = #True
      Break
     EndIf
    Next  
   Else
    Result$ + "0"
   EndIf
   If Position = 0
    Result$ + "."
   EndIf
   If NotNull
    Precision - 1
   EndIf
   *TempDecimal1 = TimesDecimal(*TempDecimal1, *ConstantDecimal(10), #FirstDecimal)
   TimesCount + 1
   Position - 1
  Wend
  If Position >= 0
   Result$ + LSet("", Position+1, "0")
  EndIf
  For Multiple = 1 To 9 
   FreeDecimal(*Multiple(Multiple))
  Next
  If *Rest
   If TimesCount
    *TempDecimal1 = TimesDecimal(*TempDecimal1, StringToDecimal("0."+LSet("", TimesCount-1, "0")+"1"), #BothDecimal)
    *TempDecimal1\Sign = *Decimal1\Sign
   EndIf
   *Rest\i = *TempDecimal1
  Else
   FreeDecimal(*TempDecimal1)
  EndIf
  *Decimal = StringToDecimal(Result$)
  *Decimal\Sign = Sign
  If Delete & #FirstDecimal  : FreeDecimal(*Decimal1) : EndIf
  If Delete & #SecondDecimal : FreeDecimal(*Decimal2) : EndIf
  ProcedureReturn *Decimal
 EndProcedure 
   
  
  
 ; Dividiert zwei Dezimalzahlen und gibt den Rest zurück
 Procedure ModuloDecimal(*Decimal1.Decimal, *Decimal2.Decimal, Delete=#BothDecimal)
  Protected *Rest
  Protected *Decimal = DivideDecimal(*Decimal1, *Decimal2, 0, @*Rest, Delete)
  FreeDecimal(*Decimal)
  ProcedureReturn *Rest
 EndProcedure 
   


 ; Potenziert zwei Dezimalzahlen und gibt das Ergebnis zurück
 Procedure PowerDecimal(*Decimal1.Decimal, *Decimal2.Decimal, Delete=#BothDecimal, Precision=0)
  Protected *Rest, *NewDecimal1, *NewDecimal2.Decimal, *ReturnDecimal, Sign = 1
  If *Decimal2\Sign = -1 : Swap Sign, *Decimal2\Sign : EndIf
  *NewDecimal2 = DivideDecimal(*Decimal2, *ConstantDecimal(2), 0, @*Rest, #NoDecimal)
  If CompareDecimal(*NewDecimal2, *ConstantDecimal(0))
   *NewDecimal1 = TimesDecimal(*Decimal1, *Decimal1, #NoDecimal)
   *ReturnDecimal = PowerDecimal(*NewDecimal1, *NewDecimal2, #BothDecimal)
   If Not CompareDecimal(*Rest, *ConstantDecimal(1))
    *ReturnDecimal = TimesDecimal(*ReturnDecimal, *Decimal1, #FirstDecimal)
   EndIf
  Else
   FreeDecimal(*NewDecimal2)
   If Not CompareDecimal(*Decimal2, *ConstantDecimal(0))
    *ReturnDecimal = CopyDecimal(*ConstantDecimal(1))
   Else
    *ReturnDecimal = CopyDecimal(*Decimal1)
   EndIf
  EndIf
  FreeDecimal(*Rest)
  If Sign = -1 :
   Swap Sign, *Decimal2\Sign
   *ReturnDecimal = DivideDecimal(*ConstantDecimal(1), *ReturnDecimal, Precision, 0, #SecondDecimal)
  EndIf
  If Delete & #FirstDecimal  : FreeDecimal(*Decimal1) : EndIf
  If Delete & #SecondDecimal : FreeDecimal(*Decimal2) : EndIf
  ProcedureReturn *ReturnDecimal
 EndProcedure
 
  
 
 ; Gibt die Eulersche Zahl mit der angegebenen Genauigkeit als Dezimalzahl zurück
 Procedure DecimalE(Precision)
  ;      n
  ; e = Sum ( 1/k! )
  ;     k=0
  Protected k, n = Precision/2+25
  Protected *PlusDecimal      = CopyDecimal(*ConstantDecimal(1))
  Protected *FactorialDecimal = CopyDecimal(*ConstantDecimal(1))
  For k = n To 2 Step -1
   *FactorialDecimal = TimesDecimal(*FactorialDecimal, IntegerToDecimal(k))
   *PlusDecimal = PlusDecimal(*PlusDecimal, *FactorialDecimal, #FirstDecimal)
  Next
  Protected *ReturnDecimal = DivideDecimal(*PlusDecimal, *FactorialDecimal, Precision)
  ProcedureReturn PlusDecimal(*ReturnDecimal, *ConstantDecimal(1), #FirstDecimal)
 EndProcedure
 

  
 ; Gibt die Kreiszahl Pi mit der angegebenen Genauigkeit als Dezimalzahl zurück
 Procedure DecimalPi(Precision)
  ;               n
  ; ArcTan(x) = Summe( (-1)^k * x^(2k+1) / (2k+1) )
  ;              k=0
  ; Pi = 4 * ( 4*ArcTan(1/5) - ArcTan(1/239) )
  Protected k, *Z, *IZ, *K, *Power1, *Power2, *Term
  Protected *Result      = CopyDecimal(*ConstantDecimal(0))
  Protected *Constant5   = StringToDecimal("0.2")
  Protected *Constant239 = DivideDecimal(*ConstantDecimal(1), IntegerToDecimal(239), Precision*2, 0, #SecondDecimal)
  For k = 0 To Precision+1
   *Z = IntegerToDecimal(2*k+1)
   *IZ = DivideDecimal(*ConstantDecimal(1), *Z, Precision*2, 0, #NoDecimal)
   *Power1 = PowerDecimal(*Constant5, *Z, #NoDecimal)
   *Power1 = TimesDecimal(*Power1, *ConstantDecimal(4), #FirstDecimal)
   If k < Precision*0.5
    *Power2 = PowerDecimal(*Constant239, *Z, #NoDecimal)
    *Power2 = CutDecimal(*Power2, Precision*2)
    *Term = MinusDecimal(*Power1, *Power2)
   Else
    *Term = *Power1
   EndIf
   *Term = TimesDecimal(*Term, *IZ)
   If k%2
    *Result = MinusDecimal(*Result, *Term)
   Else
     *Result = PlusDecimal(*Result, *Term)  
   EndIf
  Next
  *Result = TimesDecimal(*Result, *ConstantDecimal(4), #FirstDecimal)
  ProcedureReturn CutDecimal(*Result, Precision-1)
 EndProcedure


   
 ; Radiziert zwei Dezimalzahlen und gibt das ergebnis zurück
 Procedure RootDecimal(*Decimal1.Decimal, *Decimal2.Decimal, Precision=0)
  ; Iteration: y = ((n-1)*y^n+x)/(n*y^(n-1))
  Protected n, Max, *TempDecimal, *TempDecimal2
  Protected *Decimal3 = MinusDecimal(*Decimal2, *ConstantDecimal(1), #NoDecimal)
  Protected *ReturnDecimal = CopyDecimal(*Decimal1)
  Max = *Decimal2\Field[1]*5*Log10(*Decimal1\Field[1])
  For n = 1 To Max
   *TempDecimal = PowerDecimal(*ReturnDecimal, *Decimal2, #NoDecimal)
   *TempDecimal = TimesDecimal(*TempDecimal, *Decimal3, #FirstDecimal)
   *TempDecimal = PlusDecimal(*TempDecimal, *Decimal1, #FirstDecimal)
   *TempDecimal2 = PowerDecimal(*ReturnDecimal, *Decimal3, #FirstDecimal)
   *TempDecimal2 = TimesDecimal(*TempDecimal2, *Decimal2, #FirstDecimal)
   *ReturnDecimal = DivideDecimal(*TempDecimal, *TempDecimal2, Precision, 0, #BothDecimal)
  Next
  ProcedureReturn *ReturnDecimal
 EndProcedure



 ; Gibt den größten gemeinsammen Teiler der beiden Dezimalzahlen zurück
 Procedure GCDDecimal(*Decimal1.Decimal, *Decimal2.Decimal, Delete=#BothDecimal)
  Protected *TempDecimal1.Decimal = CopyDecimal(*Decimal1)
  Protected *TempDecimal2.Decimal = CopyDecimal(*Decimal2)
  Repeat
   Protected *ModDecimal.Decimal = ModuloDecimal(*TempDecimal1, *TempDecimal2, #FirstDecimal)
   If CompareDecimal(*ModDecimal, *ConstantDecimal(0))
    *TempDecimal1 = *TempDecimal2
    *TempDecimal2 = *ModDecimal
   EndIf
  Until Not CompareDecimal(*ModDecimal, *ConstantDecimal(0))
  If Delete & #FirstDecimal  : FreeDecimal(*Decimal1) : EndIf
  If Delete & #SecondDecimal : FreeDecimal(*Decimal2) : EndIf
  ProcedureReturn *TempDecimal2
 EndProcedure



 ; Gibt das kleinste Vielfache der beiden Dezimalzahlen zurück
 Procedure LCMDecimal(*Decimal1.Decimal, *Decimal2.Decimal, Delete=#BothDecimal)
  Protected Precision = Decimal_GetMax(-*Decimal1\Magnitude, -*Decimal2\Magnitude)*#Decimal_FieldSize 
  If Precision < 0 : Precision = 0 : EndIf
  Protected *TimesDecimal.Decimal = TimesDecimal(*Decimal1, *Decimal2, #NoDecimal)
  Protected *GCDDecimal.Decimal   = GCDDecimal(*Decimal1, *Decimal2, #NoDecimal)
  Protected *Decimal.Decimal      = DivideDecimal(*TimesDecimal, *GCDDecimal, Precision)
  If Delete & #FirstDecimal  : FreeDecimal(*Decimal1) : EndIf
  If Delete & #SecondDecimal : FreeDecimal(*Decimal2) : EndIf
  ProcedureReturn *Decimal
 EndProcedure



 ;- - - - - - - - - - -


 
 ; Schreibt eine Dezimalzahl in eine Datei
 Procedure WriteDecimal(File, *Decimal.Decimal)
  WriteData(File, *Decimal, SizeOf(Decimal)+*Decimal\Size*SizeOf(Long))
 EndProcedure



 ; Liest eine Dezimalzahl aus eine Datei und gibt diese zurück
 Procedure ReadDecimal(File)
  Protected Decimal.Decimal
  ReadData(File, @Decimal, SizeOf(Decimal))
  Protected *Decimal.Decimal = CreateDecimal(Decimal\Size)
  CopyMemory(@Decimal, *Decimal, SizeOf(Decimal))
  If Decimal\Size
   ReadData(File, @*Decimal\Field[1], *Decimal\Size*SizeOf(Long))
  EndIf
  ProcedureReturn *Decimal
 EndProcedure
 
 
 
; IDE Options = PureBasic 4.40 (Windows - x86)
; EnableThread
; EnableXP
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 226
; FirstLine = 222
; Folding = ------
; EnableXP
; CompileSourceDirectory