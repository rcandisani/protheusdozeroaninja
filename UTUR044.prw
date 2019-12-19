#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TURA044.CH"

#DEFINE OPER_FATURA		3 
#DEFINE OPER_REFATU		3
#DEFINE TP_VENDA		1
#DEFINE TP_APURA		2
#DEFINE TP_BREAK		3
#DEFINE TP_CREDITO		4			
#DEFINE GRIDMAXLIN 99999			

Static _nOper 	 := 0 		//Operacao da rotina
Static _nOperFat := 0 		//Operacao da rotina de refaturamento //candisani
Static _nTpFat	 := 0

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TURA044A
Função chamada pelo menu responsável pela geração e cancelamento de Fatura de Apurações.

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function UTUR044A()

If TURExistX1("TURA045C")
	SetKey(VK_F12, {|a, b| AcessaPerg("TURA045C", .T.)})	
EndIf

_nTpFat := TP_APURA

DbSelectArea("G84")

U_UTUR044()

Return

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TURA044V
Função chamada pelo menu responsável pela geração e cancelamento de Fatura de Vendas.

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function TURA044V()

If TURExistX1("TURA045C")
	SetKey(VK_F12, {|a, b| AcessaPerg("TURA045C", .T.)})	
EndIf

_nTpFat := TP_VENDA

DbSelectArea("G84")

TURA044()

Return

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TURA044B
Função chamada pelo menu responsável pela geração e cancelamento de Fatura de Breakage.

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function UTUR044B()

If TURExistX1("TURA045C")
	SetKey(VK_F12, {|a, b| AcessaPerg("TURA045C", .T.)})	
EndIf

_nTpFat := TP_BREAK

DbSelectArea("G84")

U_UTUR044()

Return

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TURA044C
Função chamada pelo menu responsável pela geração e cancelamento de Fatura de Crédito.

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function UTUR044C()

If TURExistX1("TURA045C")
	SetKey(VK_F12, {|a, b| AcessaPerg("TURA045C", .T.)})	
EndIf

_nTpFat := TP_CREDITO

DbSelectArea("G84")

U_UTUR044()

Return

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TURA044
Função chamada pelo menu responsável pela geração e cancelamento de Fatura de Vendas.

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function UTUR044()

Local oBrowse   := Nil
Local nRecnoG84 := 0

Private aRotina := {}

oBrowse := FwMBrowse():New()
oBrowse:SetAlias('G84')
oBrowse:SetMenudef('UTUR044')

If _nTpFat == TP_VENDA
	oBrowse:SetDescription(STR0001)	//"Faturas de Vendas"
ElseIf _nTpFat == TP_APURA
	oBrowse:SetDescription(STR0002) //"Faturas de Apurações"
ElseIf _nTpFat == TP_BREAK
	oBrowse:SetDescription(STR0039) //"Faturas de Breakage"
ElseIf _nTpFat == TP_CREDITO
	oBrowse:SetDescription(STR0051) //"Faturas de Crédito"
EndIf	

oBrowse:AddLegend("G84_STATUS == '1'", 'GREEN', STR0003) //"Fatura Ativa"
oBrowse:AddLegend("G84_STATUS == '2'", 'RED'  , STR0004) //"Fatura Cancelada" 

oBrowse:SetFilterDefault("G84_TPFAT == '" + AllTrim(Str(_nTpFat)) + "'")	

oBrowse:AddButton(STR0008	 , {|| nRecnoG84 := U_X44Fat(),oBrowse:Refresh(.F.),G84->(DbGoTo(nRecnoG84))},,3)
oBrowse:AddButton("Refaturar", {|| nRecnoG84 := U_X44Refat(),oBrowse:Refresh(.F.),G84->(DbGoTo(nRecnoG84))},,3)

oBrowse:Activate()

_nTpFat := 0

Return


/*/{Protheus.doc} MenuDef
Função responsável pela montagem do menu

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function MenuDef()

aRotina := {}

AAdd(aRotina,{ STR0005 	, 'PesqBrw'       	   , 0 , 1, 0, .T. } ) // "Pesquisar"
AAdd(aRotina,{ STR0006	, 'TA45Histor' 			, 0 , 2, 0, .T. } ) // "Visualizar"
AAdd(aRotina,{ STR0007  , 'U_X45Canc'   			, 0 , 6, 0, .T. } ) // "Cancelar"
AAdd(aRotina,{ STR0008  , 'U_X44Fat()'   			, 0 , 3, 0, .T. } ) // "Faturar"
AAdd(aRotina,{ "Refaturar"  , "U_X44Refat()", 0 , 9, 0, .T. } ) // "Refaturar"
AAdd(aRotina,{ STR0009	, "MsDocument('G84',G84->(RecNo()), 4)",0,7,0,.T.} ) // "Banco de Conhecimento"

Return (aRotina)

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44Fatura
Função para chamado do Faturamento

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------

User Function X44Fat()

Local cTitulo 	:= ""
Local cPrograma	:= ""
Local aEnableBut 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,OemToAnsi(STR0008)},{.T.,OemToAnsi(STR0007)},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }//"Faturar" //"Cancelar"
Local nOperation	:= MODEL_OPERATION_INSERT
Local bCancel		:= {|oModel| U_X44NoAlt(oModel)}
Local nRet			:= 0		

_nOper      	:= OPER_FATURA
cTitulo 		:= STR0040
cPrograma    	:= 'UTUR044'
nRet         	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, aEnableBut, bCancel, /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
_nOper      	:= 0

If nRet == 1
	U_XLibReg()
EndIf

T35DelCache()

Return G84->(RecNo())

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsável pela criação do modelo de dados.

@type 		Function
@author 	Jose Domingos Caldana jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel   	:= Nil
Local oStruXXX 	:= U_XStruXXX(.T.)
Local oStruG84 	:= U_XStruG84(.T.)		
Local oStruG85 	:= U_XStruG85(.T.)	
Local lTodasFil	:= .F.
Local cSelFil  	:= ""
Local cSegNeg		:= ""
Local cOperac		:= ""
Local cMoeda		:= ""

oStruG84:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
oStruG85:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)

oModel := MPFormModel():New('UTUR044_M', /*bPreValidacao*/, { |oModel| U_XValFat( oModel ) }/*bPosValidacao*/, { |oModel| U_X44Grava( oModel ) }/*bCommit*/, /*bCancel*/)


If _nTpFat == TP_VENDA
	oModel:SetDescription( STR0001 ) //"Faturas de Vendas"
ElseIf _nTpFat == TP_APURA
	oModel:SetDescription( STR0002 ) //"Faturas de Apurações"
ElseIf _nTpFat == TP_BREAK
	oModel:SetDescription( STR0039 ) //"Faturas de Breakage"
ElseIf _nTpFat == TP_CREDITO
	oModel:SetDescription( STR0051 ) //"Faturas de Crédito"
	oStruG84:SetProperty('G84_TIPOTI'		,MODEL_FIELD_VALID	,{|| Pertence('1|2') 	})
EndIf

oStruG85:AddField(; 					// Ord. Tipo Desc.
					  "Acerto?"		,; 		// [01] C Titulo do campo "Até IATA"
					  "IF de Acerto",; 		// [02] C ToolTip do campo
					  "G85_ACERTO" 	,; 		// [03] C identificador (ID) do Field
					  "C"			,; 		// [04] C Tipo do campo
					  1				,; 		// [05] N Tamanho do campo
					  0 			,; 		// [06] N Decimal do campo
					  {|| .T.}		,; 		// [07] B Code-block de validação do campo
					  NIL 			,; 		// [08] B Code-block de validação When do campo
					  NIL 			,; 		// [09] A Lista de valores permitido do campo
					  .F. 			,; 		// [10] L Indica se o campo tem preenchimento obrigatório
					  NIL 			,; 		// [11] B Code-block de inicializacao do campo
					  NIL 			,; 		// [12] L Indica se trata de um campo chave
					  NIL 			,; 		// [13] L Indica se o campo pode receber valor em uma operação de update.
					 .T.) 				   	// [14] L Indica se o campo é virtual
					 
oStruG85:AddField("",;						// Titulo //"Check"
						"Valor aux",;					// Descrição Tooltip 
						"G85_VLRAUX",;				// Nome do Campo
						"N",;						// Tipo de dado do campo
						16,;						// Tamanho do campo
						2,;							// Tamanho das casas decimais
						,;							// Bloco de Validação do campo
						,;							// Bloco de Edição do campo
						{},; 						// Opções do combo
						.F.,; 						// Obrigatório
						NIL,; 						// Bloco de Inicialização Padrão
						.F.,; 						// Campo é chave
						.F.,; 						// Atualiza?
						.T.) 						// Virtual?
					 

oModel:AddFields('XXX_MASTER', /*cOwner*/, oStruXXX )
oModel:GetModel('XXX_MASTER'):SetDescription( STR0010 ) //"Faturamento"

oModel:AddGrid('G84_DETAIL', 'XXX_MASTER', oStruG84, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)

oModel:AddGrid('G85_DETAIL', 'G84_DETAIL', oStruG85, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
oModel:SetRelation('G85_DETAIL', {{'G85_FILIAL', 'xFilial( "G85" )' }, { 'G85_FECHA', 'G84_FECHA' },{ 'G85_ITEMFE', 'G84_ITEMFE' } }, G85->(IndexKey(2)))

oModel:AddCalc('TOT_CALC' , 'XXX_MASTER', 'G85_DETAIL',  'G85_VLRAUX' , 'TOT_MARCAD'	, 'FORMULA', {|oModel| U_TA44Total(oModel,'0')}	,, STR0011 		,{|oModel,nTotalAtual,xValor,lSomando| U_TA44Calc(oModel,nTotalAtual,xValor,lSomando,'0')}, 14, 2) //'Total Selecionado'
If _nTpFat == TP_VENDA .Or. _nTpFat == TP_BREAK .Or. _nTpFat == TP_CREDITO
	oModel:AddCalc('TOT_CALC' , 'XXX_MASTER', 'G85_DETAIL', 'G85_VLRAUX' , 'TOT_VENDA' 	, 'FORMULA', {|oModel| U_TA44Total(oModel,'1')}	,, STR0012+"(+)"  ,{|oModel,nTotalAtual,xValor,lSomando| U_TA44Calc(oModel,nTotalAtual,xValor,lSomando,'1')}, 14, 2) //'Total de Vendas' 
	oModel:AddCalc('TOT_CALC' , 'XXX_MASTER', 'G85_DETAIL', 'G85_VLRAUX' , 'TOT_REEMB' 	, 'FORMULA', {|oModel| U_TA44Total(oModel,'2|5')}	,, STR0013+"(-)"  ,{|oModel,nTotalAtual,xValor,lSomando| U_TA44Calc(oModel,nTotalAtual,xValor,lSomando,'2')}, 14, 2) //'Total de Reembolso'
EndIf
oModel:AddCalc('TOT_CALC' , 'XXX_MASTER', 'G85_DETAIL', 'G85_VLRAUX' , 'TOT_RECEIT'	, 'FORMULA', {|oModel| U_TA44Total(oModel,'3')}	,, STR0014+"(+)"	,{|oModel,nTotalAtual,xValor,lSomando| U_TA44Calc(oModel,nTotalAtual,xValor,lSomando,'3')}, 14, 2) //'Total de Receitas'
oModel:AddCalc('TOT_CALC' , 'XXX_MASTER', 'G85_DETAIL', 'G85_VLRAUX' , 'TOT_ABATIM'	, 'FORMULA', {|oModel| U_TA44Total(oModel,'4')}	,, STR0015+"(-)"	,{|oModel,nTotalAtual,xValor,lSomando| U_TA44Calc(oModel,nTotalAtual,xValor,lSomando,'4')}, 14, 2) //'Total de Abatimento'


oModel:GetModel('G84_DETAIL' ):SetOptional(.T.)
oModel:GetModel('G85_DETAIL' ):SetOptional(.T.)

oModel:GetModel('G84_DETAIL' ):SetNoDeleteLine(.T.)
oModel:GetModel('G85_DETAIL' ):SetNoDeleteLine(.T.)

oModel:GetModel('G84_DETAIL' ):SetNoInsertLine(.T.)
oModel:GetModel('G85_DETAIL' ):SetNoInsertLine(.T.)

oModel:GetModel('XXX_MASTER'):SetOnlyQuery(.T.)

oModel:GetModel( 'G85_DETAIL' ):SetMaxLine(GRIDMAXLIN)

oModel:SetPrimaryKey({'XXX_FECHA'} )

oModel:SetVldActivate( { |oModel| U_X44VlMod( oModel,@lTodasFil,@cSelFil,@cSegNeg,@cOperac,@cMoeda ) } )
oModel:SetActivate( {|oModel| U_X44Fech(oModel,lTodasFil,cSelFil,cSegNeg,cOperac,cMoeda) } )

Return oModel


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsável pela definição da visão da Apuração de Receita de Clientes.

@type 		Function
@author 	Jose Domingos Caldana jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel    := FWLoadModel('UTUR044')
Local oStruXXX  := U_XStruXXX(.F.)
Local oStruG84  := U_XStruG84(.F.)
Local oStruG85  := U_XStruG85(.F.)
Local oView     := FWFormView():New()
Local oStruTot  := FWCalcStruct(oModel:GetModel('TOT_CALC' ))

oView:SetModel( oModel )

//Remoção de campos da G84
oStruG84:RemoveField('G84_FILIAL')
oStruG84:RemoveField('G84_PREFIX')
oStruG84:RemoveField('G84_NUMFAT')
oStruG84:RemoveField('G84_SEGNEG')
oStruG84:RemoveField('G84_TPFAT')
oStruG84:RemoveField('G84_STATUS')
oStruG84:RemoveField('G84_DTCANC')
oStruG84:RemoveField('G84_USUCAN')
oStruG84:RemoveField('G84_NOMUSU')
oStruG84:RemoveField('G84_FECHA')
oStruG84:RemoveField('G84_ITEMFE')
oStruG84:RemoveField('G84_ENVELE')
If Empty(AllTrim(FwxFilial("G4L")))
	oStruG84:RemoveField('G84_FILCMP')
Endif 

If _nTpFat <> TP_CREDITO
	oStruG84:RemoveField('G84_TIPOTI')
EndIf

//Remoção de campos da G85
oStruG85:RemoveField('G85_FILIAL')
oStruG85:RemoveField('G85_PREFIX')
oStruG85:RemoveField('G85_NUMFAT')
oStruG85:RemoveField('G85_TIPO')
oStruG85:RemoveField('G85_STATUA')
oStruG85:RemoveField('G85_FATATU')
oStruG85:RemoveField('G85_FILATU')
oStruG85:RemoveField('G85_PRFATU')
oStruG85:RemoveField('G85_FECHA')
oStruG85:RemoveField('G85_ITEMFE')
oStruG85:RemoveField('G85_VLRAUX')

If _nTpFat == TP_VENDA .Or. _nTpFat == TP_BREAK .Or. _nTpFat == TP_CREDITO
	oStruG85:RemoveField('G85_IDIFA')
	oStruG85:RemoveField('G85_CODAPU')
ElseIf _nTpFat == TP_APURA
	oStruG85:RemoveField('G85_IDIF')
	oStruG85:RemoveField('G85_REGVEN')
	oStruG85:RemoveField('G85_ITVEND')
	oStruG85:RemoveField('G85_SEQIV')
	oStruG85:RemoveField('G85_DOC')
	oStruG85:RemoveField('G85_GRPPRD')
	oStruG85:RemoveField('G85_GRPDES')
	oStruG85:RemoveField('G85_SOLIC')
	oStruG85:RemoveField('G85_ITPRIN')
	
EndIf

oView:CreateHorizontalBox('ID_PASTA_CLI',34)
oView:CreateHorizontalBox('ID_PASTA_ITF',54)
oView:CreateHorizontalBox('ID_PASTA_TOT',12)

oView:AddGrid('VIEW_G84' , oStruG84, 'G84_DETAIL')
oView:AddIncrementField('VIEW_G84' , 'G84_ITEMFE'  )
oView:SetOwnerView('G84_DETAIL','ID_PASTA_CLI')
oView:EnableTitleView("G84_DETAIL","Clientes") 

oView:AddGrid('VIEW_G85' , oStruG85, 'G85_DETAIL')
oView:SetOwnerView('G85_DETAIL','ID_PASTA_ITF')

If _nTpFat == TP_VENDA .Or. _nTpFat == TP_BREAK .Or. _nTpFat == TP_CREDITO
	oView:EnableTitleView("G85_DETAIL", STR0016 ) //"Itens de Venda"
ElseIf _nTpFat == TP_APURA
	oView:EnableTitleView("G85_DETAIL", STR0017 ) //"Apurações"
EndIf

oView:AddField('VIEW_CALC_1', oStruTot, 'TOT_CALC')
oView:SetOwnerView('TOT_CALC','ID_PASTA_TOT')

oView:AddUserButton(STR0052, 'CLIPS', {|oVw| U_X44MkAll(oVw)}, , VK_F11, {MODEL_OPERATION_INSERT})	// "Marcar/Desmarcar Todos"

oView:SetInsertMessage( STR0010 , STR0018 ) //"Faturamento" //"Processamento realizado com sucesso."

Return oView


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44VLDMOD
Função responsável pela validação do cancelamento e carga dos itens para faturamento.

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function X44VlMod(oModel,lTodasFil,cSelFil,cSegNeg,cOperac,cMoeda)

Local lRet := .T. 

//+-----------------------------------------------------
// Chama função de parametros e seleção de itens para o fechamento
//+-----------------------------------------------------
If _nOper == OPER_FATURA .Or. _nOperFat == OPER_REFATU    
		lRet := U_X44ParFe(@lTodasFil,@cSelFil,@cSegNeg,@cOperac,@cMoeda)
EndIf

If _nOperFat == OPER_REFATU //candisani
	If G84->G84_STATUS == "1"
		Help( , , "TURA044_REFATU", , "Selecione uma fatura cancelada para refaturar" , 1, 0) 
		lRet := .F.
	Else
		lRet := .T.	
	EndIf
EndIf

Return lRet

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44ParFec
Função responsável por validar o pergunte da rotina e chamar a função de seleção de itens.

@type 		Function
@author 	Jose Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function X44ParFe(lTodasFil,cSelFil,cSegNeg,cOperac,cMoeda)

Local cPerg     	:= Nil
Local lRet			:= .F.
Local cTitulo		:= ""

If _nOper == OPER_FATURA .OR. _nOperFat == OPER_REFATU  

	If _nTpFat == TP_VENDA
		cPerg 		:= 'TURA44V'
		cTitulo	:= STR0001 	//"Faturas de Vendas"
	ElseIf _nTpFat == TP_APURA
		cPerg 		:= 'TURA44A'
		cTitulo	:= STR0002		//"Faturas de Apurações"
	ElseIf _nTpFat == TP_BREAK
		cPerg 		:= 'TURA44B'
		cTitulo	:= STR0039 	//"Faturas de Breakage"
	ElseIf _nTpFat == TP_CREDITO
		cPerg 		:= 'TURA44C'
		cTitulo	:= STR0051 	//"Faturas de Crédito"
	EndIf	
			
	//+----------------------------------------------------
	//|	Apresenta do pergunte de seleção de Itens para faturamento
	//+----------------------------------------------------
	If _nOperFat == OPER_REFATU //candisani
		Pergunte(cPerg,.F.,cTitulo)
	Else
		If Pergunte(cPerg, .T.,cTitulo)
			While !U_X44VldPg(@lTodasFil,@cSelFil,@cSegNeg,@cOperac,@cMoeda)
					lTodasFil	:= .F.
					cSelFil  	:= ""
					cSegNeg	:= ""
					cOperac	:= ""
				If !Pergunte(cPerg,.T.,cTitulo)
					Help( , , "TURA044", , STR0019, 1, 0,,,,,,{STR0041 + STR0008}) //"Para selecionar novos itens, clique no botão "//"Faturar"
					Return .F.
				EndIf
			EndDo
			lRet := .T.
		EndIf
	EndIf
	
	If !lRet
		Help( , , "TURA044", , STR0019, 1, 0,,,,,,{STR0041 + STR0008}) //"Para selecionar novos itens, clique no botão "//"Faturar"	
	EndIf
EndIf

Return lRet


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44Fecham
Função responsável por processar o Fechamento

@type 		Function
@author 	Jose Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function X44Fech(oModel,lTodasFil,cSelFil,cSegNeg,cOperac,cMoeda)

Local bProcess  	:= {||}

If _nOper == OPER_FATURA .OR. _nOperFat == OPER_REFATU
	If _nTpFat == TP_VENDA .Or. _nTpFat == TP_BREAK .Or. _nTpFat == TP_CREDITO
			If	_nOperFat == OPER_REFATU
				bProcess 	:= {|| U_XSelRef()} //candisani
			Else
				bProcess 	:= {|| U_XSelVen(oModel,lTodasFil,cSelFil,cSegNeg,cOperac)}
			Endif	
	ElseIf _nTpFat == TP_APURA //candisani
		If	_nOperFat == OPER_REFATU
			bProcess 	:= {|| U_XSelRef()} //candisani
		Else 
			bProcess 	:= {|| U_XSelApu(oModel,lTodasFil,cSelFil,cSegNeg,cMoeda)} //candisani
		Endif	
	EndIf
//Elseif _nOperFat == OPER_REFATU
//	bProcess 	:= {|| U_XSelVen(oModel,lTodasFil,cSelFil,cSegNeg,cOperac)}
Endif

If _nOper == OPER_FATURA 
	FWMsgRun(,bProcess,  , STR0020 ) //"Aguarde... Selecionando itens para faturamento..."
EndIf

If _nOperFat == OPER_REFATU 
	FWMsgRun(,bProcess,  , "Selecionando itens para refaturar... aguarde" )
EndIf

Return


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44VldPg
Função para validação do pergunte TURA044

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function X44VldPg(lTodasFil,cSelFil,cSegNeg,cOperac,cMoeda)

Local nX 		:= 0
Local nQtd		:= 0
Local aOper	:= {}
Local aSelFil	:= {}
Local lSelFil	:= .F.
Local lCorp	:= .F.
Local lEvento	:= .F. 		
Local lLazer	:= .F. 
Local aMoeda	:= {}		

If _nTpFat == TP_VENDA
	lSelFil	:= MV_PAR15 == 1
	lCorp		:= MV_PAR06 == 1
	lEvento	:= MV_PAR07 == 1
	lLazer		:= MV_PAR08 == 1
	
	//Seleção de Operaçãoes
	If MV_PAR14 == 1
		aOper := TLBoxOper()
		For nX := 1 to Len(aOper)
			If aOper[nX,1] 
				cOperac += aOper[nX,2] + "|"
				nQtd++
			EndIf	 
		Next
		cOperac := Left(cOperac, Len(cOperac) - 1) 
		If nQtd == 0
			Help(" ",1,"TURA044_OPERAC",,STR0021,1,0) //"Deve ser selecionada pelo menos uma Operação"
			Return .F.
		ElseIf nQtd == 1
			cOperac := "= '"+ AllTrim(cOperac)+"'"	
		Else
			cOperac := "IN "+ FormatIn(cOperac,"|")
		EndIf
	EndIf
	
ElseIf _nTpFat == TP_APURA
	lSelFil	:= MV_PAR13 == 1
	lCorp		:= MV_PAR09 == 1
	lEvento	:= MV_PAR10 == 1
	lLazer		:= MV_PAR11 == 1

	//Seleção de Moedas
	If MV_PAR12 == 1
		aMoeda := TLBoxMoed()
		For nX := 1 to Len(aMoeda)
			If aMoeda[nX,1] 
				cMoeda += aMoeda[nX,2] + "|"
				nQtd++
			EndIf	 
		Next
		cMoeda := Left(cMoeda, Len(cMoeda) - 1) 
		If nQtd == 0
			Help(" ",1,"TURA044_MOEDA",,STR0022,1,0) //"Deve ser selecionada pelo menos uma Moeda"
			Return .F.
		ElseIf nQtd == 1
			cMoeda := "= '"+ AllTrim(cMoeda)+"'"	
		Else
			cMoeda := "IN "+ FormatIn(cMoeda,"|")
		EndIf
	EndIf

ElseIf _nTpFat == TP_BREAK
	lSelFil	:= MV_PAR11 == 1
	lCorp		:= MV_PAR05 == 1
	lEvento	:= MV_PAR06 == 1
	lLazer		:= MV_PAR07 == 1

ElseIf _nTpFat == TP_CREDITO
	lSelFil	:= MV_PAR05 == 1
	lCorp		:= MV_PAR06 == 1
	lEvento	:= MV_PAR07 == 1
	lLazer		:= MV_PAR08 == 1

EndIf

//Seleção de Filiais
If lSelFil
	aSelFil := AdmGetFil(@lTodasFil,,"G4C")
	If Len(aSelFil) <= 0
		Return .F.
	EndIf
	cSelFil	:= U_XRngFil(aSelFil,"G4C")
Else
	lTodasFil := .T.
EndIf

If lCorp //Corporativo
	cSegNeg += "1|"
EndIf

If lEvento //Eventos
	cSegNeg += "2|"
EndIf

If lLazer //Lazer
	cSegNeg += "3|"
EndIf

If Len(cSegNeg) > 0
	cSegNeg := Left(cSegNeg, Len(cSegNeg) - 1 ) 
	If Len(cSegNeg) > 1
		cSegNeg := "IN "+FormatIn(cSegNeg,"|")	
	Else
		cSegNeg := "= '"+ cSegNeg +"'"
	Endif
Else
	Help(" ",1,"TURA044_SEGNEG",,STR0023,1,0)//"Deve ser selecionado pelo menos um Segmento de Negócio"
	Return .F.
EndIf

Return .T.


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44SelVen
Função responsável pela seleção dos Clientes com Itens Financeiro liberado para Faturamento

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function XSelVen(oModel,lTodasFil,cSelFil,cSegNeg,cOperac)

Local aArea       := GetArea()
Local oModelXXX   := oModel:GetModel("XXX_MASTER")
Local oModelG84   := oModel:GetModel("G84_DETAIL")
Local oModelG85   := oModel:GetModel("G85_DETAIL")
Local oModelTot   := oModel:GetModel("TOT_CALC")
Local aCmpDtFech  := {}
Local aXFech	  := {}
Local lIncluiG85  := .T.
Local lFecha      := .F.
Local lMarcar     := .F. //Define se inicializa marcado
Local lExtTurNat  := FindFunction('U_TURNAT')
Local cConinu     := Space(TamSx3("G4C_CONINU")[1])
Local cAliasITF   := ""
Local cWhere      := ""
Local cCondPg     := ""
Local cFilCond    := ""
Local cNat		  := ""
Local cNomeArq	  := ""
Local cExpSBM	  := cExpFil('SBM')
Local cExpSB1	  := cExpFil('SB1')
Local cExpSA1	  := cExpFil('SA1')
Local cExpSU5	  := cExpFil('SU5')
Local cExpG3E	  := cExpFil('G3E')
Local cExpG3G	  := cExpFil('G3G')
Local cExpG4L1    := cExpFil('G4L','G4L1')
Local cExpG4L2    := cExpFil('G4L','G4L2')
Local cExpG8B	  := cExpFil('G8B')
Local nItemG85    := 0
Local nItemG84    := 0
Local nTotal 	  := 0
Local nTOT_ABATIM := 0
Local nTOT_RECEIT := 0
Local nTOT_REEMB  := 0
Local nTOT_VENDA  := 0
Local nHandCre	  := 0
Local cItemG85    := 0	
Local nRecno	  := 0	
Local nPos        := 0
Local nX          := 0
Local nValor      := 0

//candisani //dados da fatura posicionada
Local aItemG85    := {}
Local cFilialG84  := G84->G84_FILIAL
Local cPrefix     := G84->G84_PREFIX
Local cNumFat     := G84->G84_NUMFAT
Local cClient     := G84->G84_CLIENT
Local cLoja       := G84->G84_LOJA
Local cCondPg     := G84->G84_CONDPG
Local cMoeda      := G84->G84_MOEDA
Local cFilCmp	  := G84->G84_FILCMP
Local cCmpCli     := G84->G84_CMPCLI
Local cTpFat      := G84->G84_TPFAT
Local cIDIF       := ""
Local cITPrin     := ""
Local cFilRef     := ""
Local cFilCond    := ""
Local cTipo       := ""
Local cRegVen     := ""
Local cItVend     := ""
Local cSeqIv      := ""
Local cDoc        := ""
Local cClass      := ""
Local cClaDes     := ""
Local cSeqNeg     := ""
Local cCodPrd     := ""
Local cPrdDes     := ""
Local cGrpPrd     := ""
Local cGrpDes     := ""
Local cPagRec     := ""
Local cSolic      := ""
Local cNumSol     := ""
Local cTpEnt      := ""
Local cEntDes     := ""
Local cItEnt      := ""
Local cItDesc     := ""
Local cAcerto     := ""
Local cNature     := ""
Local nAuxRegVen  := ""
Local nAuxItem	  := "" 

/*
//verificar se é Faturamento ou refaturamento
If _nOper == OPER_FATURA //candisani
*/	
	//+---------------------------------------------------
	//|	Tratamento do Where para parametros especificos
	//+--------------------------------------------------- 
	If _nTpFat == TP_VENDA
		
		lMarcar   := MV_PAR19 == 1 .Or. MV_PAR22 == 1 
		
		cWhere += " (G4C.G4C_TIPO = '1' OR (G4C.G4C_TIPO = '3' AND G4C.G4C_CLASS = 'V01')) AND "
		cWhere += " (G4C.G4C_PAGREC = '2' OR (G4C.G4C_PAGREC = '1' AND G4C.G4C_ACERTO = '1'))AND "
		cWhere += " G4C.G4C_GRPPRD BETWEEN '"+ MV_PAR09 + "' AND '"+ MV_PAR10 +"' AND "
	 	cWhere += " G4C.G4C_EMISS BETWEEN '"+ DTOS(MV_PAR11) +"' AND '"+ DTOS(MV_PAR12) +"' AND "
		
		If MV_PAR14 == 1
			 cWhere += " G4C.G4C_OPERAC "+ cOperac +" AND "
		EndIf
	
		If MV_PAR06 <> 1 .Or. MV_PAR07 <> 1 .Or.  MV_PAR08 <> 1
			 cWhere += " G4C.G4C_SEGNEG "+ cSegNeg +" AND "
		EndIf 
	
		If MV_PAR13 <> 3
			 cWhere += " G4C.G4C_DESTIN = '"+AllTrim(Str(MV_PAR13))+"' AND "
		EndIf
		
		cWhere += " G4C.G4C_NUMID BETWEEN '"+ MV_PAR16 +"' AND '"+ MV_PAR17 +"' AND " 
		
		cWhere += " SA1.A1_GRPVEN BETWEEN '"+ MV_PAR20 +"' AND '"+ MV_PAR21 +"' AND "
	
		If MV_PAR22 == 1
			 cWhere += " G4C.G4C_PREFAT = 'T' AND "
		EndIf
	
		If !Empty(MV_PAR23)
			 cWhere += " G3P.G3P_CODEX = '" + MV_PAR23 + "' AND "
		EndIf
		
	ElseIf _nTpFat == TP_BREAK
		
		lMarcar   := MV_PAR14 == 1
		
		If MV_PAR05 <> 1 .Or. MV_PAR06 <> 1 .Or.  MV_PAR07 <> 1
			 cWhere += " G4C.G4C_SEGNEG "+ cSegNeg +" AND"
		EndIf 
		If MV_PAR08 <> 3
			 cWhere += " G4C.G4C_DESTIN = '"+AllTrim(Str(MV_PAR08))+"' AND"
		EndIf
		
		cWhere += " G4C.G4C_VENCIM BETWEEN '"+ DTOS(MV_PAR09) +"' AND '"+ DTOS(MV_PAR10) +"' AND"
		cWhere += " G4C.G4C_TIPO = '5' AND"
		
		cWhere += " G4C.G4C_NUMID BETWEEN '"+ MV_PAR12 +"' AND '"+ MV_PAR13 +"' AND"
		
		cWhere += " SA1.A1_GRPVEN BETWEEN '"+ MV_PAR15 +"' AND '"+ MV_PAR16 +"' AND"
	
		If !Empty(MV_PAR17)
			 cWhere += " G3P.G3P_CODEX = '" + MV_PAR17 + "' AND "
		EndIf
	
	ElseIf _nTpFat == TP_CREDITO
		
		lMarcar   := MV_PAR16 == 1
		
		cWhere += " (G4C.G4C_TIPO IN ('1','2') OR (G4C.G4C_TIPO = '3' AND G4C.G4C_CLASS = 'V01')) AND"
		cWhere += " G4C.G4C_PAGREC = '1' AND" 
		cWhere += " G4C.G4C_GRPPRD BETWEEN '"+ MV_PAR09 + "' AND '"+ MV_PAR10 +"' AND"
	 	cWhere += " G4C.G4C_EMISS BETWEEN '"+ DTOS(MV_PAR11) +"' AND '"+ DTOS(MV_PAR12) +"' AND"
		
		If MV_PAR06 <> 1 .Or. MV_PAR07 <> 1 .Or.  MV_PAR08 <> 1
			 cWhere += " G4C.G4C_SEGNEG "+ cSegNeg +" AND"
		EndIf 
		If MV_PAR13 <> 3
			 cWhere += " G4C.G4C_DESTIN = '"+AllTrim(Str(MV_PAR13))+"' AND"
		EndIf
	
		cWhere += " G4C.G4C_NUMID BETWEEN '"+ MV_PAR14 +"' AND '"+ MV_PAR15 +"' AND"
		
		cWhere += " SA1.A1_GRPVEN BETWEEN '"+ MV_PAR17 +"' AND '"+ MV_PAR18 +"' AND"
	
		If !Empty(MV_PAR19)
			 cWhere += " G3P.G3P_CODEX = '" + MV_PAR19 + "' AND "
		EndIf
		
	EndIf
	
	If !lTodasFil
		 cWhere += " G4C.G4C_FILIAL "+ cSelFil +" AND"
	EndIf
	
	cWhere		:= '%'+ cWhere +'%'
	
	//+--------------------------------------------------------------------------
	//|	Query principal para tratamento dos itens financeiros de venda a faturar
	//+--------------------------------------------------------------------------
	cAliasITF := GetNextAlias()
	BeginSql Alias cAliasITF
		
		SELECT TMP1.*, G4P_FILIAL G4PFILIAL, G4P_ENVELE ENVELE, G4P.R_E_C_N_O_ G4PRECNO
		FROM (
	 		SELECT G4C_FILIAL G4CFILIAL, G4C_FILREF FILREF, G4C_IDIF IDIF, G4C_ACERTO ACERTO, G4C_CODIGO CLIENTE, G4C_LOJA LOJA, G4C_GRPPRD GRUPO, G4C_SEGNEG SEGNEG, G4C_EMISS EMISSAO,
	 				G4C_CONDPG CONDPG, G4C_MOEDA MOEDA, G4C_VALOR VALOR, G4C_NUMID NUMID, G4C_IDITEM IDITEM, G4C_NUMSEQ NUMSEQ, G4C_DOC DOC, G4C_TIPO TIPO, 
	 				G4C_CODPRO CODPRO, G4C_CLASS CLASSIF, G4C_PAGREC PAGREC, G4C_SOLIC SOLIC, G4C_ENTAD TPENT, G4C_ITRAT ITENT, G4C_NATUR NATURE, G4C.R_E_C_N_O_ G4CRECNO, 
	 				COALESCE(G4L1.G4L_FILIAL,G4L2.G4L_FILIAL) G4LFILIAL, 
	 				COALESCE(G4L1.G4L_CODIGO,G4L2.G4L_CODIGO) CODCMP,
	 				COALESCE(G4L1.G4L_CORP,G4L2.G4L_CORP) CORPOR,
	 				COALESCE(G4L1.G4L_EVENTO,G4L2.G4L_EVENTO) EVENTO, 
	 				COALESCE(G4L1.G4L_LAZER,G4L2.G4L_LAZER) LAZER,  
	 				COALESCE(G4L1.R_E_C_N_O_,G4L2.R_E_C_N_O_) G4LRECNO, 
					B1_DESC PRDDES, A1_NOME A1NOME, G8B_DESCRI CLADES, G3E_DESCR ENTDES, G3G_DESCR ITDESC, BM_DESC GRPDES, U5_CONTAT NOMSOL 
			FROM %Table:G4C% G4C
			INNER JOIN %Table:G3P% G3P ON G3P_FILIAL = G4C_FILIAL AND G3P_NUMID = G4C_NUMID AND G3P.%NotDel%
			LEFT JOIN %Table:SB1% SB1 ON
				%Exp:cExpSB1%
				G4C_CODPRO = SB1.B1_COD AND
	 			SB1.%NotDel%
	 		LEFT JOIN %Table:SA1% SA1 ON
				%Exp:cExpSA1%
				G4C_CODIGO = SA1.A1_COD AND
				G4C_LOJA = SA1.A1_LOJA AND 
	 			SA1.%NotDel%
	 		LEFT JOIN %Table:G8B% G8B ON
				%Exp:cExpG8B%
				G4C_CLASS = G8B.G8B_CODIGO AND
	 			G8B.%NotDel%
	 		LEFT JOIN %Table:G3E% G3E ON
				%Exp:cExpG3E%
				G4C_ENTAD = G3E.G3E_CODIGO AND
	 			G3E.%NotDel%
	 		LEFT JOIN %Table:G3G% G3G ON
				%Exp:cExpG3G%
				G4C_CODIGO = G3G.G3G_CLIENT AND
				G4C_LOJA = G3G.G3G_LOJA AND
				G4C_ENTAD = G3G.G3G_TIPO AND 
				G4C_ITRAT = G3G.G3G_ITEM AND
	 			G3G.%NotDel%
	 		LEFT JOIN %Table:SBM% SBM ON
				%Exp:cExpSBM%
				G4C_GRPPRD = SBM.BM_GRUPO AND
	 			SBM.%NotDel%
	 		LEFT JOIN %Table:SU5% SU5 ON
				%Exp:cExpSU5%
				G4C_SOLIC = SU5.U5_CODCONT AND
	 			SU5.%NotDel%
	 		LEFT JOIN  %Table:G4L% G4L1 ON
	 			G4C_CODIGO = G4L1.G4L_CLIENT AND
	 			G4C_LOJA = G4L1.G4L_LOJA AND
	 			%Exp:cExpG4L1%
	 			((G4C_SEGNEG = '1' AND G4L1.G4L_CORP = 'T') OR
	 			(G4C_SEGNEG = '2' AND G4L1.G4L_EVENTO = 'T') OR
	 			(G4C_SEGNEG = '3' AND G4L1.G4L_LAZER = 'T')) AND	
	 			G4L1.%NotDel%
	 		LEFT JOIN %Table:G4L% G4L2 ON
	 			G4C_CODIGO = G4L2.G4L_CLIENT AND
	 			G4L2.G4L_COMPAR = '1' AND
	 			%Exp:cExpG4L2%
	 			((G4C_SEGNEG = '1' AND G4L2.G4L_CORP = 'T') OR
	 			(G4C_SEGNEG = '2' AND G4L2.G4L_EVENTO = 'T') OR
	 			(G4C_SEGNEG = '3' AND G4L2.G4L_LAZER = 'T')) AND	
	 			G4L2.%NotDel%
	 		WHERE
	 			(G4L1.G4L_CODIGO IS NOT NULL OR G4L2.G4L_CODIGO IS NOT NULL) AND
	 			G4C_CLIFOR = '1' AND
	 			G4C_STATUS = '3' AND
	 			G4C_CONINU = %Exp:cConinu% AND
	 			G4C_CODIGO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR03% AND
	 			G4C_LOJA BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR04% AND
				%Exp:cWhere%
	 			G4C.%NotDel%
	 	)TMP1
	 	LEFT JOIN %Table:G4P% G4P ON
			G4P_FILIAL = G4LFILIAL AND 
	 		G4P_CODIGO = CODCMP AND
	 		G4P.%NotDel%
		
		ORDER BY SEGNEG, G4CFILIAL, CLIENTE, LOJA, CODCMP, NUMID, IDITEM, TPENT, ITENT, G4CRECNO
	 
	EndSql
	
	If UPPER(cUserName) $ UPPER(GetMV("MV_TURDBUG",,""))
		cNomeArq := "C:\TOTVS\SQL_FAT_VEN_"+cUserName+"_"+DtoS(dDatabase)+"_"+StrTran( Time(),":","" )+".TXT"
		If (nHandCre := FCREATE(cNomeArq , 0)) > 0
			FWRITE( nHandCre, GetLastQuery()[2])
			FCLOSE(nHandCre)
		EndIf
	EndIf
	
	
	oModelXXX:LoadValue("XXX_FECHA"	,DTOS(dDataBase)+StrTran(Time(),":",""))
	
	While (cAliasITF)->(!EOF())
		
		lFecha 	:= .T.
		cCondPg	:= (cAliasITF)->(CONDPG)
		cFilCond	:= (cAliasITF)->(G4CFILIAL)
		
		//+--------------------------------------------------------------------------
		//|	Avalia parametros de fechamento do Cliente - Utiliza cache no array
		//+--------------------------------------------------------------------------
		If _nTpFat == TP_VENDA 
		
			nPos := Ascan(aCmpDtFech, {|x| x[1]+x[2]+x[3] == (cAliasITF)->(G4PFILIAL)+(cAliasITF)->(CODCMP)+(cAliasITF)->(GRUPO)})
			If nPos > 0 
				cCondPg	:= aCmpDtFech[nPos][4]
				lFecha 	:= aCmpDtFech[nPos][5]
			Else
				aXFech := U_TurXFech((cAliasITF)->(G4PFILIAL),(cAliasITF)->(CODCMP),'1',(cAliasITF)->(GRUPO))
				
				If Empty(aXFech)
					lFecha 	:= IIf( MV_PAR05 == 1, .F., .T.)
					Aadd(aCmpDtFech, {(cAliasITF)->(G4PFILIAL),(cAliasITF)->(CODCMP),(cAliasITF)->(GRUPO),cCondPg, lFecha})
				Else 
					cCondPg	:= aXFech[5]
					lFecha 	:= IIf( MV_PAR05 == 1, U_TURAX03(aXFech[1],aXFech[2],aXFech[3],aXFech[4],dDataBase), .T.)
					Aadd(aCmpDtFech, {(cAliasITF)->(G4PFILIAL),(cAliasITF)->(CODCMP),(cAliasITF)->(GRUPO),cCondPg, lFecha})
				EndIf
			
			EndIf	
		
		EndIf
				
		If lFecha
		
			nOpc := 1
			lTravou := .F.
		
			DbSelectArea("G4C")
			G4C->(DbsetOrder(4))
			G4C->(DbSeek((cAliasITF)->(G4CFILIAL)+(cAliasITF)->(NUMID)+(cAliasITF)->(IDITEM)+(cAliasITF)->(NUMSEQ)+(cAliasITF)->(IDIF)+cConinu))
			While !lTravou .And. nOpc == 1 
			 	//Verifica se o item ainda continua aberto para faturamento, pode ter sido faturado em outra sessão
				If G4C->G4C_STATUS == '3'
					If !lMarcar .Or. G4C->(DbRLock(G4C->(Recno())))
					
						lTravou := .T.
		
						If oModelG84:SeekLine({{"G84_CLIENT",(cAliasITF)->(CLIENTE)},{"G84_LOJA",(cAliasITF)->(LOJA)},{"G84_FILCMP",(cAliasITF)->(G4LFILIAL)},{"G84_CMPCLI",(cAliasITF)->(CODCMP)},{"G84_MOEDA",(cAliasITF)->(MOEDA)},{"G84_CONDPG",cCondPg}})
							nItemG84 := oModelG84:GetLine()
						Else
							If (oModelG84:Length() == 1 .And. Empty(oModelG84:GetValue("G84_CMPCLI")))
								nItemG84 := 1	
							Else
								nItemG84 := oModelG84:AddLine()	
							EndIf
				
					   		oModelG84:GoLine(nItemG84)
						
							oModelG84:LoadValue("G84_OK"		,lMarcar					)
							oModelG84:LoadValue("G84_FECHA"		,DTOS(dDataBase)+StrTran(Time(),":",""))
							oModelG84:LoadValue("G84_TPFAT"		,AllTrim(Str(_nTpFat))	)
							oModelG84:LoadValue("G84_CLIENT"	,(cAliasITF)->(CLIENTE)	)
							oModelG84:LoadValue("G84_LOJA"		,(cAliasITF)->(LOJA)		)
							oModelG84:LoadValue("G84_NOME"		,(cAliasITF)->(A1NOME)	)
							oModelG84:LoadValue("G84_EMISS"		,dDataBase					)
							oModelG84:LoadValue("G84_CONDPG"	,cCondPg					)
							oModelG84:LoadValue("G84_CPDESC"	,GetAdvFVal("SE4","E4_DESCRI",xFilial("SE4",cFilCond)+cCondPg,1,"")	)
							oModelG84:LoadValue("G84_MOEDA"		,(cAliasITF)->(MOEDA)	)
							oModelG84:LoadValue("G84_ENVELE"	,'2'	)
							oModelG84:LoadValue("G84_FILCMP"	,(cAliasITF)->(G4LFILIAL))
							oModelG84:LoadValue("G84_CMPCLI"	,(cAliasITF)->(CODCMP)	)
							oModelG84:LoadValue("G84_CORP"		,U_TURCTOL((cAliasITF)->(CORPOR))	)
							oModelG84:LoadValue("G84_EVENT"		,U_TURCTOL((cAliasITF)->(EVENTO))	)
							oModelG84:LoadValue("G84_LAZER"		,U_TURCTOL((cAliasITF)->(LAZER))	)
							oModelG84:LoadValue("G84_STATUS"	,'1'						)	
							oModelG84:LoadValue("G84_ENVIA"		, Posicione('G4P', 1, (cAliasITF)->(G4LFILIAL) + (cAliasITF)->(CODCMP), 'G4P_ENVELE'))	
			
							If _nTpFat == TP_CREDITO
								oModelG84:LoadValue("G84_TIPOTI"	,CriaVar("G84_TIPOTI"))	
							EndIf
			
						EndIf
					
						If (oModelG85:Length() == 1 .And. Empty(oModelG85:GetValue("G85_IDIF")))
							nItemG85 := 1	
						Else
							nItemG85 := oModelG85:AddLine()	
						EndIf
					
						oModelG85:GoLine(nItemG85)
						oModelG85:LoadValue("G85_ITEM"		,StrZero(nItemG85,Len(oModelG85:GetValue("G85_ITEM")),0))
						oModelG85:LoadValue("G85_OK"		,lMarcar					)
						oModelG85:LoadValue("G85_TIPO"		,(cAliasITF)->(TIPO)		)
						oModelG85:LoadValue("G85_FILREF"	,(cAliasITF)->(FILREF)	)
						oModelG85:LoadValue("G85_IDIF"		,(cAliasITF)->(IDIF)		)
						oModelG85:LoadValue("G85_REGVEN"	,(cAliasITF)->(NUMID)	)
						oModelG85:LoadValue("G85_ITVEND"	,(cAliasITF)->(IDITEM)	)
						oModelG85:LoadValue("G85_SEQIV"		,(cAliasITF)->(NUMSEQ)	)
						oModelG85:LoadValue("G85_DOC"		,(cAliasITF)->(DOC)		)
						oModelG85:LoadValue("G85_CLASS"		,(cAliasITF)->(CLASSIF)	)
						oModelG85:LoadValue("G85_CLADES"	,(cAliasITF)->(CLADES)	)
						oModelG85:LoadValue("G85_SEGNEG"	,(cAliasITF)->(SEGNEG)	)
						oModelG85:LoadValue("G85_CODPRD"	,(cAliasITF)->(CODPRO)	)
						oModelG85:LoadValue("G85_PRDDES"	,(cAliasITF)->(PRDDES)	)
						oModelG85:LoadValue("G85_GRPPRD"	,(cAliasITF)->(GRUPO)	)
						oModelG85:LoadValue("G85_GRPDES"	,(cAliasITF)->(GRPDES)	)
						oModelG85:LoadValue("G85_MOEDA"		,(cAliasITF)->(MOEDA)	)
						oModelG85:LoadValue("G85_PAGREC"	,(cAliasITF)->(PAGREC)	)
						oModelG85:LoadValue("G85_EMISSA"	,STOD((cAliasITF)->(EMISSAO)))
						oModelG85:LoadValue("G85_SOLIC"		,(cAliasITF)->(SOLIC)	)
						oModelG85:LoadValue("G85_NOMSOL"	,(cAliasITF)->(NOMSOL)	)
						oModelG85:LoadValue("G85_TPENT"		,(cAliasITF)->(TPENT)	)
						oModelG85:LoadValue("G85_ENTDES"	,(cAliasITF)->(ENTDES)	)
						oModelG85:LoadValue("G85_ITENT"		,(cAliasITF)->(ITENT)	)
						oModelG85:LoadValue("G85_ITDESC"	,(cAliasITF)->(ITDESC)	)
						oModelG85:LoadValue("G85_VALOR"		,(cAliasITF)->(VALOR)	)
						oModelG85:LoadValue("G85_ACERTO"	,(cAliasITF)->(ACERTO)	)
						oModelG85:LoadValue("G85_VLRAUX"	,IIf(lMarcar,(cAliasITF)->(VALOR),0)	)
						If Empty((cAliasITF)->(NATURE))
							cNat := IIf(lExtTurNat, TURNAT((cAliasITF)->(FILREF),(cAliasITF)->(TIPO), (cAliasITF)->(CLASSIF) ,(cAliasITF)->(SEGNEG),(cAliasITF)->(CODPRO),'1',(cAliasITF)->(CLIENTE),(cAliasITF)->(LOJA)), "")
							If !Empty(cNat) .And. TurVldNat(cNat, .T., STR0050 + ": " + oModelG85:GetValue("G85_IDIF") + chr(10) + chr(13))
								oModelG85:LoadValue("G85_NATURE"	,cNat )	
							Else
								oModelG85:LoadValue("G85_NATURE"	,"" )	
							EndIf
						Else
							oModelG85:LoadValue("G85_NATURE"	,(cAliasITF)->(NATURE)	)
						EndIf
					
						//Fim da carga do Pai
						If oModelG85:VldLineData()			
				
							If lMarcar
												
								//Atualiza o total
								nTotal := nTotal + (oModelG85:GetValue("G85_VALOR")  * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))
				
								Do Case
									Case oModelG85:GetValue("G85_TIPO") == '1'
										nTOT_VENDA := nTOT_VENDA + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))
									Case oModelG85:GetValue("G85_TIPO") $ '2|5'
										nTOT_REEMB := nTOT_REEMB + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',1,-1))
									Case oModelG85:GetValue("G85_TIPO") == '3'
										nTOT_RECEIT := nTOT_RECEIT + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))
									Case oModelG85:GetValue("G85_TIPO") == '4'
										nTOT_ABATIM := nTOT_ABATIM + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',1,-1))
								EndCase
			
								oModelG84:LoadValue("G84_TOTAL"	,oModelG84:GetValue("G84_TOTAL") + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1)))
				
							EndIf
				
							cItemPrin := oModelG85:GetValue("G85_ITEM")
				
							//Adiciona os Filhos (Acordos cobrados Na Fatura)
							DbSelectArea("G4C")
							G4C->(DbsetOrder(3))
							G4C->(DbSeek((cAliasITF)->(G4CFILIAL)+(cAliasITF)->(IDIF)))
							While G4C->(!Eof()) .And. G4C->G4C_FILIAL+G4C->G4C_IFPRIN == (cAliasITF)->(G4CFILIAL)+(cAliasITF)->(IDIF)
						
								If G4C->(G4C_FILIAL+G4C_IFPRIN+G4C_NUMID+G4C_IDITEM+G4C_NUMSEQ) == (cAliasITF)->(G4CFILIAL+IDIF+NUMID+IDITEM+NUMSEQ) .And.;
									G4C->G4C_TIPO $ "3|4|5" .And. G4C->G4C_STATUS == '3' 
							
									nOpc := 1
									lTravou := .F.
								
									While !lTravou .And. nOpc == 1 
										If !lMarcar .Or. G4C->(DbRLock(G4C->(Recno())))
									
											lTravou := .T.
									
											nRecno := G4C->(Recno())
									
											If (oModelG85:Length() == 1 .And. Empty(oModelG85:GetValue("G85_IDIF")))
												nItemG85 := 1	
											Else
												nItemG85 := oModelG85:AddLine()	
											EndIf
								
											G4C->(DbGoTo(nRecno))
								
											oModelG85:GoLine(nItemG85)
											oModelG85:LoadValue("G85_ITEM"		,StrZero(nItemG85,Len(oModelG85:GetValue("G85_ITEM")),0))
											oModelG85:LoadValue("G85_OK"		,lMarcar			)
											oModelG85:LoadValue("G85_TIPO"		,G4C->G4C_TIPO	)
											oModelG85:LoadValue("G85_FILREF"	,G4C->G4C_FILREF	)
											oModelG85:LoadValue("G85_IDIF"		,G4C->G4C_IDIF	)
											oModelG85:LoadValue("G85_REGVEN"	,G4C->G4C_NUMID	)
											oModelG85:LoadValue("G85_ITVEND"	,G4C->G4C_IDITEM	)
											oModelG85:LoadValue("G85_SEQIV"		,G4C->G4C_NUMSEQ	)
											oModelG85:LoadValue("G85_DOC"		,G4C->G4C_DOC		)
											oModelG85:LoadValue("G85_CLASS"		,G4C->G4C_CLASS	)
											oModelG85:LoadValue("G85_CLADES"	,Posicione("G8B",1,xFilial("G8B")+G4C->G4C_CLASS,"G8B_DESCRI"))
											oModelG85:LoadValue("G85_SEGNEG"	,G4C->G4C_SEGNEG	)
											oModelG85:LoadValue("G85_CODPRD"	,G4C->G4C_CODPRO	)
											oModelG85:LoadValue("G85_PRDDES"	,Posicione("SB1",1,xFilial("SB1")+G4C->G4C_CODPRO,"B1_DESC"))
											oModelG85:LoadValue("G85_GRPPRD"	,G4C->G4C_GRPPRD	)
											oModelG85:LoadValue("G85_GRPDES"	,Posicione('SBM',1,xFilial('SBM')+G4C->G4C_GRPPRD, 'BM_DESC'))
											oModelG85:LoadValue("G85_MOEDA"		,G4C->G4C_MOEDA	)
											oModelG85:LoadValue("G85_PAGREC"	,G4C->G4C_PAGREC	)
											oModelG85:LoadValue("G85_EMISSA"	,G4C->G4C_EMISS	)
											oModelG85:LoadValue("G85_SOLIC"		,G4C->G4C_SOLIC	)
											oModelG85:LoadValue("G85_TPENT"		,G4C->G4C_ENTAD	)
											oModelG85:LoadValue("G85_ENTDES"	,Posicione("G3E",1,xFilial("G3E")+G4C->G4C_ENTAD, "G3E_DESCR"))
											oModelG85:LoadValue("G85_ITENT"		,G4C->G4C_ITRAT	)
											oModelG85:LoadValue("G85_ITDESC"	,Posicione("G3G",1,xFilial("G3G")+G4C->(G4C_CODIGO+G4C_LOJA+G4C_ENTAD+G4C_ITRAT),"G3G_DESCR"))
											oModelG85:LoadValue("G85_ITPRIN"	,cItemPrin			)
											oModelG85:LoadValue("G85_VALOR"		,G4C->G4C_VALOR	)
											oModelG85:LoadValue("G85_ACERTO"	,G4C->G4C_ACERTO)
											oModelG85:LoadValue("G85_VLRAUX"	,IIf(lMarcar,G4C->G4C_VALOR,0))
											If Empty(G4C->G4C_NATUR)
												cNat := IIf(lExtTurNat, TURNAT(G4C->G4C_FILREF,G4C->G4C_TIPO,G4C->G4C_CLASS,G4C->G4C_SEGNEG,G4C->G4C_CODPRO,'1',G4C->G4C_CODIGO,G4C->G4C_LOJA), "")
												If !Empty(cNat) .And. TurVldNat(cNat,.T., STR0050 + ": " + oModelG85:GetValue("G85_IDIF") + chr(10) + chr(13))
														oModelG85:LoadValue("G85_NATURE"	,cNat )	
													Else
														oModelG85:LoadValue("G85_NATURE"	,"" )	
												EndIf
											Else
													oModelG85:LoadValue("G85_NATURE"	,G4C->G4C_NATUR )	
											EndIf
									
											//Fim da carga do filhos (acordos)
											If oModelG85:VldLineData()	
											
												If lMarcar
													
													//Atualiza o total
													nTotal := nTotal + (oModelG85:GetValue("G85_VALOR")  * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))
									
													Do Case
														Case oModelG85:GetValue("G85_TIPO") == '1'
															nTOT_VENDA := nTOT_VENDA + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))
														Case oModelG85:GetValue("G85_TIPO") $ '2|5'
															nTOT_REEMB := nTOT_REEMB + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',1,-1))
														Case oModelG85:GetValue("G85_TIPO") == '3'
															nTOT_RECEIT := nTOT_RECEIT + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))
														Case oModelG85:GetValue("G85_TIPO") == '4'
															nTOT_ABATIM := nTOT_ABATIM + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',1,-1))
													EndCase
								
													oModelG84:LoadValue("G84_TOTAL"	,oModelG84:GetValue("G84_TOTAL") + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1)))
												
												EndIf
											Else
										
												TurHelp( "RV: "+G4C->G4C_NUMID+" Item: "+G4C->G4C_IDITEM+" Seq.: "+G4C->G4C_NUMSEQ+ STR0058 +G4C->G4C_NUMACD+ STR0059, STR0060, STR0061 )
											
											EndIf
										Else
											nOpc := AVISO(STR0033 ,STR0034 + STR0035 + TA44LogBlq("G4C"), { STR0036, STR0037, STR0038}, 2) //"Iten Financeiro em uso" //"Tentar Novamente"//"Pular Item"// "Abortar seleção"
										EndIf	
									EndDo
								
									If nOpc == 3
										Exit	
									EndIf
									
								EndIf
								G4C->(DbSkip())
							EndDo
						Else
							TurHelp( "RV: "+G4C->G4C_NUMID+" Item: "+G4C->G4C_IDITEM+" Seq.: "+G4C->G4C_NUMSEQ+ STR0062, STR0060, STR0061)
						EndIf
					Else
						nOpc := AVISO(STR0033 ,STR0034 + STR0035 + TA44LogBlq("G4C"), { STR0036, STR0037, STR0038}, 2) //"Iten Financeiro em uso" //"Tentar Novamente"//"Pular Item"// "Abortar seleção"
					EndIf
				Else
					Help(,,"TURA044_LOCK",,STR0056,1,0,,,,,,{STR0057})	//'Item financeiro com status diferente de liberado.'###'Outro processo alterou o item financeiro enquanto este não estava marcado, não será permitido faturar este item.'
					nOpc := 3
				EndIf	
			EndDo
				
			If nOpc == 3
				G4C->(DBUnlockAll())
				oModelG85:DelAllLine()
				oModelG85:ClearData()
				oModelG84:DelAllLine()
				oModelG84:ClearData()
				Exit	
			EndIf
				
		EndIf
			
		(cAliasITF)->(DbSkip())
	EndDo
	
	(cAliasITF)->(DbCloseArea())

/*
ElseIf _nOperFat == OPER_REFATU //candisani

	//+---------------------------------------------------
	//|	Carregar os dados da fatura cancelada posicionada
	//+--------------------------------------------------- 
	oModelG84:SetNoInsertLine(.F.)
	oModelG85:SetNoInsertLine(.F.) 
	
		
	oModelXXX:LoadValue("XXX_FECHA"	,DTOS(dDataBase)+StrTran(Time(),":",""))
	
	oModelG84:LoadValue("G84_OK"	, lMarcar)
	oModelG84:LoadValue("G84_FECHA"	, DTOS(dDataBase) + StrTran(Time(), ":", ""))
	oModelG84:LoadValue("G84_TPFAT"	, AllTrim(Str(_nTpFat)))
	oModelG84:LoadValue("G84_CLIENT", cClient)
	oModelG84:LoadValue("G84_LOJA"	, cLoja)
	oModelG84:LoadValue("G84_NOME"	, GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + cClient + cLoja, 1, ""))
	oModelG84:LoadValue("G84_EMISS"	, dDataBase)
	oModelG84:LoadValue("G84_CONDPG", cCondPg)
	oModelG84:LoadValue("G84_CPDESC", GetAdvFVal("SE4", "E4_DESCRI", xFilial("SE4") + cCondPg, 1, ""))
	oModelG84:LoadValue("G84_MOEDA"	, cMoeda)
	oModelG84:LoadValue("G84_ENVELE", "2")
	oModelG84:LoadValue("G84_FILCMP", cFilCmp)
	oModelG84:LoadValue("G84_CMPCLI", cCmpCli)
	oModelG84:LoadValue("G84_STATUS", "1")	
	oModelG84:LoadValue("G84_TPFAT" , cTpFat)	
	
	//verificar os itens já faturados na G85
	//verificar se os itens cancelados já foram faturados em outra nota
	
	G85->(DbSetOrder(1))
	If G85->(DbSeek(cFilialG84 + cPrefix + cNumFat))	
		While G85->(!EOF()) .AND. (G85->G85_FILREF == cFilialG84 .AND. G85->G85_PREFIX == cPrefix .AND. G85->G85_NUMFAT == cNumFat)	
			cNumFat := G85->G85_NUMFAT
			cIDIF   := G85->G85_IDIF
			cFilRef := G85->G85_FILREF
			cTipo   := G85->G85_TIPO
			cRegVen := G85->G85_REGVEN
			cItVend := G85->G85_ITVEND
			cSeqIv  := G85->G85_SEQIV
			cDoc    := G85->G85_DOC
			cClass  := G85->G85_CLASS
			cSeqNeg := G85->G85_SEGNEG
			cCodPrd := G85->G85_CODPRD
			cGrpPrd := G85->G85_GRPPRD
			cMoeda  := G85->G85_MOEDA
			cPagRec := G85->G85_PAGREC
			cSolic  := G85->G85_SOLIC
			cTpEnt  := G85->G85_TPENT
			cItEnt  := G85->G85_ITENT
			nValor  := G85->G85_VALOR
			cNature := G85->G85_NATURE
					
			aAdd(aItemG85, {lIncluiG85 	,; //aItemG85[nX][1]
							cNumFat   	,; //aItemG85[nX][2]
							cIDIF	  	,; //aItemG85[nX][3]
							cFilRef   	,; //aItemG85[nX][4]
							cTipo		,; //aItemG85[nX][5]
							cRegVen 	,; //aItemG85[nX][6]
							cItVend 	,; //aItemG85[nX][7] 
							cSeqIv 		,; //aItemG85[nX][8]
							cDoc 		,; //aItemG85[nX][9]
							cClass 		,; //aItemG85[nX][10]
							cClaDes 	,; //aItemG85[nX][11]
							cSeqNeg 	,; //aItemG85[nX][12]
							cCodPrd 	,; //aItemG85[nX][13]
							cPrdDes 	,; //aItemG85[nX][14]
							cGrpPrd 	,; //aItemG85[nX][15]
							cGrpDes 	,; //aItemG85[nX][16]
							cMoeda 		,; //aItemG85[nX][17]
							cPagRec 	,; //aItemG85[nX][18]
							cSolic 		,; //aItemG85[nX][19]
							cNumSol 	,; //aItemG85[nX][20]
							cTpEnt 		,; //aItemG85[nX][21]
							cEntDes 	,; //aItemG85[nX][22]
							cItEnt 		,; //aItemG85[nX][23]
							cItDesc 	,; //aItemG85[nX][24]
							nValor 		,; //aItemG85[nX][25]
							cAcerto 	,; //aItemG85[nX][26]
							cNature 	,; //aItemG85[nX][27]
							})
			G85->(DbSkip())
		Enddo
	EndIf

	//gravação do item G85 para os itens não faturados
	nItemG85 := 1	
	For nX:= 1 to len(aItemG85)
		//posicionar na GC4
		G4C->(DbsetOrder(2)) // FILIAL+IDIF
		If G4C->(DbSeek(aItemG85[nX][4] + aItemG85[nX][3]))
			If G4C->G4C_STATUS == '3' 
				oModelG85:SetNoInsertLine(.F.)
				If  nItemG85 <> 1		
					nItemG85 := oModelG85:AddLine()
				Endif	
				
				oModelG85:GoLine(nItemG85)
				oModelG85:LoadValue("G85_ITEM"	, StrZero(nItemG85, Len(oModelG85:GetValue("G85_ITEM")), 0))
				oModelG85:LoadValue("G85_OK"	, lMarcar)
				oModelG85:LoadValue("G85_TIPO"	, aItemG85[nX][5])
				oModelG85:LoadValue("G85_FILREF", aItemG85[nX][4])
				oModelG85:LoadValue("G85_IDIF"	, aItemG85[nX][3])
				oModelG85:LoadValue("G85_REGVEN", aItemG85[nX][6])
				oModelG85:LoadValue("G85_ITVEND", aItemG85[nX][7])
				oModelG85:LoadValue("G85_SEQIV"	, aItemG85[nX][8])
				oModelG85:LoadValue("G85_DOC"	, aItemG85[nX][9])
				oModelG85:LoadValue("G85_CLASS"	, aItemG85[nX][10])
				oModelG85:LoadValue("G85_SEGNEG", aItemG85[nX][12])
				oModelG85:LoadValue("G85_CODPRD", aItemG85[nX][13])
				oModelG85:LoadValue("G85_GRPPRD", aItemG85[nX][15])
				oModelG85:LoadValue("G85_MOEDA"	, aItemG85[nX][17])
				oModelG85:LoadValue("G85_PAGREC", aItemG85[nX][18])
				oModelG85:LoadValue("G85_EMISSA", dDataBase)
				oModelG85:LoadValue("G85_SOLIC"	, aItemG85[nX][19])
				oModelG85:LoadValue("G85_TPENT"	, aItemG85[nX][21])
				oModelG85:LoadValue("G85_ITENT"	, aItemG85[nX][23])
				oModelG85:LoadValue("G85_VALOR"	, aItemG85[nX][25])
				oModelG85:LoadValue("G85_VLRAUX", IIf(lMarcar, aItemG85[nX][25], 0))
				oModelG85:LoadValue("G85_NATURE", aItemG85[nX][27])	
				
				If nAuxRegVen == aItemG85[nX][6] //candisani
					oModelG85:LoadValue("G85_ITPRIN", nAuxItem)
				Else
					//item principal
					nAuxItem:= StrZero(nItemG85, Len(oModelG85:GetValue("G85_ITEM")), 0) 	
				Endif
				
				If oModelG85:VldLineData()			
					If lMarcar
												
						//Atualiza o total
						nTotal := nTotal + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', -1, 1))
						
						Do Case
							Case oModelG85:GetValue("G85_TIPO") == '1'
				 				nTOT_VENDA := nTOT_VENDA   + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', -1, 1))
							Case oModelG85:GetValue("G85_TIPO") $ '2|5'
								nTOT_REEMB := nTOT_REEMB   + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', 1, -1))
							Case oModelG85:GetValue("G85_TIPO") == '3'
								nTOT_RECEIT := nTOT_RECEIT + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', -1, 1))
							Case oModelG85:GetValue("G85_TIPO") == '4'
								nTOT_ABATIM := nTOT_ABATIM + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', 1, -1))
						EndCase
					
						oModelG84:LoadValue("G84_TOTAL", oModelG84:GetValue("G84_TOTAL") + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', -1, 1)))
					EndIf
				Endif

				If  nItemG85 == 1
					nItemG85++
				EndIf

				//guarda o numero do RegVen para marcar os filhos //candisani
				nAuxRegVen:= oModelG85:GetValue("G85_REGVEN")
			Endif	
		Endif
	Next nX
	

Endif
 */
If lMarcar
	oModelTot:LoadValue("TOT_MARCAD", nTotal)
	oModelTot:LoadValue("TOT_VENDA"	, nTOT_VENDA)
	oModelTot:LoadValue("TOT_REEMB"	, nTOT_REEMB)
	oModelTot:LoadValue("TOT_RECEIT", nTOT_RECEIT)
	oModelTot:LoadValue("TOT_ABATIM", nTOT_ABATIM)
EndIf
	
oModelG84:GoLine(1)
oModelG85:GoLine(1)

RestArea(aArea)
		
oModelG84:SetNoInsertLine(.T.)
oModelG85:SetNoInsertLine(.T.) 

Return 

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44SelApu
Função responsável pela seleção dos Clientes com Itens Financeiro liberado para Apuração

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function XSelApu(oModel,lTodasFil,cSelFil,cSegNeg,cMoeda)

Local aArea     := GetArea()
Local cAliasITF := GetNextAlias()
Local oModelXXX := oModel:GetModel("XXX_MASTER")
Local oModelG84 := oModel:GetModel("G84_DETAIL")
Local oModelG85 := oModel:GetModel("G85_DETAIL")
Local oModelTot := oModel:GetModel("TOT_CALC")
Local cWhere    := ""
Local cDtLibDe  := DTOS(MV_PAR07)
Local cDtLibAte := DTOS(MV_PAR08)
Local nPos      := 0
Local cItemG85  := 0	
Local nOpc		  := 1	
Local lTravou	  := .F.
Local cWhrApu   := ""
Local lExtTurNat:= FindFunction('TURNAT')
Local cNat		  := ""
Local aParFis   := {}
Local lMarcar   := MV_PAR15 == 1 //Define se os itens inicializam marcados
Local nTotal 		:= 0
Local nTOT_ABATIM	:= 0
Local nTOT_RECEIT	:= 0
Local nHandCre	:= 0
Local cNomeArq	:= ""
Local cExpSB1		:= U_cExpFil('SB1',,'G81')
Local cExpSA1		:= U_cExpFil('SA1',,'G81')
Local cExpSE4		:= U_cExpFil('SE4',,'G81')
Local cExpG3E		:= U_cExpFil('G3E',,'G81')
Local cExpG3G		:= U_cExpFil('G3G',,'G81')
Local cExpG4L1	:= U_cExpFil('G4L','G4L1','G81')
Local cExpG4L2	:= U_cExpFil('G4L','G4L2','G81')
Local cExpG8B		:= U_cExpFil('G8B',,'G81')
	
oModelG84:SetNoInsertLine(.F.)
oModelG85:SetNoInsertLine(.F.) 

oModelG84:SetNoDeleteLine(.F.)
oModelG85:SetNoDeleteLine(.F.)

//+---------------------------------------------------
//|	Tratamento do Where para parametros especificos
//+--------------------------------------------------- 
If MV_PAR12 == 1
	 cWhere += " G81.G81_MOEDA "+ cMoeda +" AND "
EndIf
If MV_PAR09 <> 1 .Or. MV_PAR10 <> 1 .Or.  MV_PAR11 <> 1
	 cWhere += " (G81.G81_SEGNEG = ' ' OR G81.G81_SEGNEG "+ cSegNeg +") AND"
EndIf 
If !lTodasFil
	 cWhere += " G81.G81_FILREF "+ cSelFil +" AND"
EndIf


If Empty(Alltrim(cWhere))
	cWhere := " SA1.A1_GRPVEN BETWEEN '"+ MV_PAR16 +"' AND '"+ MV_PAR17 +"' AND "
Else
	cWhere += " SA1.A1_GRPVEN BETWEEN '"+ MV_PAR16 +"' AND '"+ MV_PAR17 +"' AND "
Endif

cWhere:= '%'+ cWhere +'%'

If MV_PAR14 <> 4
	cWhrApu := " G6L_TPAPUR = '" + STR(MV_PAR14,1) + "' AND "
EndIf
    

cWhrApu:= '%'+ cWhrApu +'%'

//+--------------------------------------------------------------------------
//|	Query principal para tratamento dos itens financeiros de venda a faturar
//+--------------------------------------------------------------------------
BeginSql Alias cAliasITF
	
	SELECT  TMP1.*, G4P_FILIAL G4PFILIAL, G4P_ENVELE ENVELE, G4P.R_E_C_N_O_ G4PRECNO
	FROM (
 		SELECT G81_FILIAL G81FILIAL, G81_FILREF FILREF, G81_IDIFA IDIFA, G81_CLIENT CLIENTE, G81_LOJA LOJA, G81_SEGNEG SEGNEG, G81_EMISSA EMISSAO,
 				G81_CONDPG CONDPG, G81_MOEDA MOEDA, G81_VALOR VALOR, G81_TIPO TIPO, G81_CODAPU CODAPU,
 				G81_CODPRD CODPRO, G81_CLASS CLASSIF, G81_PAGREC PAGREC, G81_TPENT TPENT, G81_ITENT ITENT, G81_NATURE NATURE, G81.R_E_C_N_O_ G81RECNO, 
 				COALESCE(G4L1.G4L_FILIAL,G4L2.G4L_FILIAL) G4LFILIAL, 
 				COALESCE(G4L1.G4L_CODIGO,G4L2.G4L_CODIGO) CODCMP,
 				COALESCE(G4L1.G4L_CORP,G4L2.G4L_CORP) CORPOR,
 				COALESCE(G4L1.G4L_EVENTO,G4L2.G4L_EVENTO) EVENTO, 
 				COALESCE(G4L1.G4L_LAZER,G4L2.G4L_LAZER) LAZER,  
 				COALESCE(G4L1.R_E_C_N_O_,G4L2.R_E_C_N_O_) G4LRECNO,
 				B1_DESC PRDDES, A1_NOME A1NOME, E4_DESCRI CPDESC, G8B_DESCRI CLADES, G3E_DESCR ENTDES, G3G_DESCR ITDESC, G6L_TPAPUR
		FROM %Table:G81% G81
		INNER JOIN %Table:G6L% G6L ON
			G81_FILIAL = G6L_FILIAL AND
			G81_CODAPU = G6L_CODAPU AND
			%Exp:cWhrApu%
			G6L.%NotDel%
		LEFT JOIN %Table:SB1% SB1 ON
			%Exp:cExpSB1%
			G81_CODPRD = SB1.B1_COD AND
 			SB1.%NotDel%
 		LEFT JOIN %Table:SA1% SA1 ON
 			%Exp:cExpSA1%
			G81_CLIENT = SA1.A1_COD AND
			G81_LOJA = SA1.A1_LOJA AND 
 			SA1.%NotDel%
 		LEFT JOIN %Table:SE4% SE4 ON
			%Exp:cExpSE4%
			G81_CONDPG = SE4.E4_CODIGO AND
 			SE4.%NotDel%
 		LEFT JOIN %Table:G8B% G8B ON
			%Exp:cExpG8B%
			G81_CLASS = G8B.G8B_CODIGO AND
 			G8B.%NotDel%
 		LEFT JOIN %Table:G3E% G3E ON
			%Exp:cExpG3E%
			G81_TPENT = G3E.G3E_CODIGO AND
 			G3E.%NotDel%
 		LEFT JOIN %Table:G3G% G3G ON
			%Exp:cExpG3G%
			G81_CLIENT = G3G.G3G_CLIENT AND
			G81_LOJA = G3G.G3G_LOJA AND
			G81_TPENT = G3G.G3G_TIPO AND 
			G81_ITENT = G3G.G3G_ITEM AND
 			G3G.%NotDel%
 		LEFT JOIN  %Table:G4L% G4L1 ON
 			G81_CLIENT = G4L1.G4L_CLIENT AND
 			G81_LOJA = G4L1.G4L_LOJA AND
 			%Exp:cExpG4L1%
 			((G81_SEGNEG = '1' AND G4L1.G4L_CORP = 'T') OR
 			(G81_SEGNEG = '2' AND G4L1.G4L_EVENTO = 'T') OR
 			(G81_SEGNEG = '3' AND G4L1.G4L_LAZER = 'T') OR
 			(G81_SEGNEG = ' ' AND  G4L1.G4L_CORP = 'T' AND G4L1.G4L_EVENTO = 'T' AND G4L1.G4L_LAZER = 'T')) AND	
 			G4L1.%NotDel%
 		LEFT JOIN %Table:G4L% G4L2 ON
 			G81_CLIENT = G4L2.G4L_CLIENT AND
 			G4L2.G4L_COMPAR = '1' AND
 			%Exp:cExpG4L2%
 			((G81_SEGNEG = '1' AND G4L2.G4L_CORP = 'T') OR
 			(G81_SEGNEG = '2' AND G4L2.G4L_EVENTO = 'T') OR
 			(G81_SEGNEG = '3' AND G4L2.G4L_LAZER = 'T') OR
 			(G81_SEGNEG = ' ' AND  G4L1.G4L_CORP = 'T' AND G4L1.G4L_EVENTO = 'T' AND G4L1.G4L_LAZER = 'T')) AND	
 			G4L2.%NotDel%
 		WHERE
 			(G4L1.G4L_CODIGO IS NOT NULL OR G4L2.G4L_CODIGO IS NOT NULL) AND
 			G81_STATUS = '1' AND
 			G81_CLIENT BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR03% AND
 			G81_LOJA BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR04% AND
 			G81_CODAPU BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% AND
 			G81_DTLIB BETWEEN %Exp:cDtLibDe% AND %Exp:cDtLibAte% AND
			%Exp:cWhere%
 			G81.%NotDel%
 	)TMP1
 	LEFT JOIN %Table:G4P% G4P ON
		G4P_FILIAL = G4LFILIAL AND 
 		G4P_CODIGO = CODCMP AND
 		G4P.%NotDel%
 		
 	ORDER BY SEGNEG, G81FILIAL, CODAPU, CLASSIF 

EndSql

If UPPER(cUserName) $ UPPER(GetMV("MV_TURDBUG",,""))
	cNomeArq := "C:\TOTVS\SQL_FAT_APU_"+cUserName+"_"+DtoS(dDatabase)+"_"+StrTran( Time(),":","" )+".TXT"
	If (nHandCre := FCREATE(cNomeArq , 0)) > 0
		FWRITE( nHandCre, GetLastQuery()[2])
		FCLOSE(nHandCre)
	EndIf
EndIf

oModelXXX:LoadValue("XXX_FECHA"	,DTOS(dDataBase)+StrTran(Time(),":",""))

DbSelectArea("G6M")
G6M->(DbSetOrder(1)) //G6M_FILIAL+G6M_CODAPU+G6M_SEGNEG+G6M_TIPOAC

While (cAliasITF)->(!EOF())
	
	nOpc := 1
	lTravou := .F.
	
	DbSelectArea("G81")
	G81->(DbsetOrder(1))
	G81->(DbSeek((cAliasITF)->(G81FILIAL)+(cAliasITF)->(IDIFA)))
	While !lTravou .And. nOpc == 1 
		If G81->G81_STATUS == '1'
		If !lMarcar .Or. G81->(DbRLock(G81->(Recno())))
			
			lTravou := .T.
			
			If oModelG84:SeekLine({{"G84_CLIENT",(cAliasITF)->(CLIENTE)},{"G84_LOJA",(cAliasITF)->(LOJA)},{"G84_FILCMP",(cAliasITF)->(G4LFILIAL)},{"G84_CMPCLI",(cAliasITF)->(CODCMP)},{"G84_MOEDA",(cAliasITF)->(MOEDA)},{"G84_CONDPG",(cAliasITF)->(CONDPG)}})		
				nItem := oModelG84:GetLine()
			Else
				If (oModelG84:Length() == 1 .And. Empty(oModelG84:GetValue("G84_CMPCLI")))
					nItem := 1	
				Else
					nItem := oModelG84:AddLine()	
				EndIf
	
		   		oModelG84:GoLine(nItem)
				oModelG84:LoadValue("G84_OK"		,lMarcar					)
				oModelG84:LoadValue("G84_TPFAT"		,AllTrim(Str(_nTpFat))	)
				oModelG84:LoadValue("G84_CLIENT"	,(cAliasITF)->(CLIENTE)	)
				oModelG84:LoadValue("G84_LOJA"		,(cAliasITF)->(LOJA)		)
				oModelG84:LoadValue("G84_NOME"		,(cAliasITF)->(A1NOME)	)
				oModelG84:LoadValue("G84_EMISS"		,dDataBase					)
				oModelG84:LoadValue("G84_CONDPG"	,(cAliasITF)->(CONDPG)	)
				oModelG84:LoadValue("G84_CPDESC"	,(cAliasITF)->(CPDESC)	)
				oModelG84:LoadValue("G84_MOEDA"		,(cAliasITF)->(MOEDA)	)
				oModelG84:LoadValue("G84_ENVELE"	,'2'	)
				oModelG84:LoadValue("G84_FILCMP"	,(cAliasITF)->(G4LFILIAL))
				oModelG84:LoadValue("G84_CMPCLI"	,(cAliasITF)->(CODCMP)	)
				oModelG84:LoadValue("G84_CORP"		,U_TURCTOL((cAliasITF)->(CORPOR))	)
				oModelG84:LoadValue("G84_EVENT"		,U_TURCTOL((cAliasITF)->(EVENTO))	)
				oModelG84:LoadValue("G84_LAZER"		,U_TURCTOL((cAliasITF)->(LAZER))	)
				oModelG84:LoadValue("G84_STATUS"	,'1'						)	
				oModelG84:LoadValue("G84_ENVIA"		, Posicione('G4P', 1, (cAliasITF)->(G4LFILIAL) + (cAliasITF)->(CODCMP), 'G4P_ENVELE'))	
			EndIf
			
			If Empty(oModelG84:GetValue("G84_MSGOBS"))
				If G6M->(dbSeek(xFilial("G6M")+(cAliasITF)->(CODAPU)+(cAliasITF)->(SEGNEG)+(cAliasITF)->(CLASSIF)))
					oModelG84:LoadValue("G84_MSGOBS",G6M->G6M_MSGOBS)
				EndIf
			EndIf
			
			If (oModelG85:Length() == 1 .And. Empty(oModelG85:GetValue("G85_IDIFA")))
				nItem := 1	
			Else
				nItem := oModelG85:AddLine()	
			EndIf
			
			aParFis := U_T35PesqPFF(	(cAliasITF)->(FILREF),;
										(cAliasITF)->(CLASSIF),;
										(cAliasITF)->(SEGNEG),;
										IIf((cAliasITF)->(CLASSIF) <> "V01", "", (cAliasITF)->(CODPRO)),;
										'1',;
										oModelG84:GetValue( 'G84_CLIENT' ),;
										oModelG84:GetValue( 'G84_LOJA' ))

			oModelG85:GoLine(nItem)
			oModelG85:LoadValue("G85_ITEM"		,StrZero(nItem,Len(oModelG85:GetValue("G85_ITEM")),0))
			oModelG85:LoadValue("G85_OK"		,lMarcar					)
			Do Case
				Case (cAliasITF)->(TIPO) == '1'
					oModelG85:LoadValue("G85_TIPO"	,'3'		)
				Case (cAliasITF)->(TIPO) == '2'
					oModelG85:LoadValue("G85_TIPO"	,'4'		)
				OtherWise
					oModelG85:LoadValue("G85_TIPO"	,(cAliasITF)->(TIPO)	)
			EndCase
			oModelG85:LoadValue("G85_FILREF"	,(cAliasITF)->(FILREF)	)
			oModelG85:LoadValue("G85_IDIFA"		,(cAliasITF)->(IDIFA)	)
			oModelG85:LoadValue("G85_CODAPU"	,(cAliasITF)->(CODAPU)	)
			oModelG85:LoadValue("G85_CLASS"		,(cAliasITF)->(CLASSIF)	)
			oModelG85:LoadValue("G85_CLADES"	,(cAliasITF)->(CLADES)	)
			oModelG85:LoadValue("G85_SEGNEG"	,(cAliasITF)->(SEGNEG)	)
			oModelG85:LoadValue("G85_CODPRD"	, aParFis[4]				)
			oModelG85:LoadValue("G85_PRDDES"	,IIF(!Empty(aParFis[4]),Posicione("SB1",1,xFilial("SB1")+aParFis[4],"B1_DESC"),""))
			oModelG85:LoadValue("G85_MOEDA"		,(cAliasITF)->(MOEDA)	)
			oModelG85:LoadValue("G85_PAGREC"	,(cAliasITF)->(PAGREC)	)
			oModelG85:LoadValue("G85_EMISSA"	,STOD((cAliasITF)->(EMISSAO)))
			oModelG85:LoadValue("G85_TPENT"		,(cAliasITF)->(TPENT)	)
			oModelG85:LoadValue("G85_ENTDES"	,(cAliasITF)->(ENTDES)	)
			oModelG85:LoadValue("G85_ITENT"		,(cAliasITF)->(ITENT)	)
			oModelG85:LoadValue("G85_ITDESC"	,(cAliasITF)->(ITDESC)	)
			oModelG85:LoadValue("G85_VALOR"		,(cAliasITF)->(VALOR)	)
			oModelG85:LoadValue("G85_VLRAUX"	,Iif(lMarcar,(cAliasITF)->(VALOR),0))			
			If Empty((cAliasITF)->(NATURE))
				cNat := IIf(lExtTurNat, TURNAT((cAliasITF)->(FILREF),oModelG85:GetValue("G85_TIPO"),(cAliasITF)->(CLASSIF) ,(cAliasITF)->(SEGNEG),(cAliasITF)->(CODPRO),'1',(cAliasITF)->(CLIENTE),(cAliasITF)->(LOJA)), aParFis[1])
				If !Empty(cNat) .And. TurVldNat(cNat, .T., STR0050 + ": " + oModelG85:GetValue("G85_IDIFA") + chr(10) + chr(13))
					oModelG85:LoadValue("G85_NATURE"	,cNat )	
				EndIf
			Else
				oModelG85:LoadValue("G85_NATURE"	,(cAliasITF)->(NATURE)	)	
			EndIf
		
			//Fim da carga do item
			If oModelG85:VldLineData()			
		
			If lMarcar
				
					
					//Atualiza o total
					nTotal := nTotal + (oModelG85:GetValue("G85_VALOR")  * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))
	
					Do Case
						Case oModelG85:GetValue("G85_TIPO") == '3'
							nTOT_RECEIT := nTOT_RECEIT + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))
						Case oModelG85:GetValue("G85_TIPO") == '4'
							nTOT_ABATIM := nTOT_ABATIM + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',1,-1))
					EndCase

					oModelG84:LoadValue("G84_TOTAL"	,oModelG84:GetValue("G84_TOTAL") + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1)))
	
				EndIf
			Else
				U_TurHelp( "Apuração: "+(cAliasITF)->(CODAPU)+STR0062,;
						  STR0063, STR0061 )
			EndIf
			
		Else
			nOpc := AVISO(STR0033 ,STR0034 + STR0035 + TA44LogBlq("G81"), { STR0036, STR0037, STR0038}, 2) //"Iten Financeiro em uso" //"Tentar Novamente"//"Pular Item"// "Abortar seleção"
		EndIf
	
		Else
			Help(,,"TURA044_LOCK",,STR0056,1,0,,,,,,{STR0057})	//'Item financeiro com status diferente de liberado.'###'Outro processo alterou o item financeiro enquanto este não estava marcado, não será permitido faturar este item.'
			nOpc := 3
		EndIf
		
	EndDo
	
	If nOpc == 3
		G81->(DBUnlockAll())
		oModelG85:DelAllLine()
		oModelG85:ClearData()
		oModelG84:DelAllLine()
		oModelG84:ClearData()
		Exit	
	EndIf
	
	(cAliasITF)->(DbSkip())
EndDo

(cAliasITF)->(DbCloseArea())

If lMarcar
	oModelTot:LoadValue("TOT_MARCAD"		,nTotal)
	oModelTot:LoadValue("TOT_RECEIT"		,nTOT_RECEIT)
	oModelTot:LoadValue("TOT_ABATIM"		,nTOT_ABATIM)
EndIf

RestArea(aArea)

oModelG84:GoLine(1)
oModelG85:GoLine(1)

oModelG84:SetNoInsertLine(.T.)
oModelG85:SetNoInsertLine(.T.) 

oModelG84:SetNoDeleteLine(.T.)
oModelG85:SetNoDeleteLine(.T.)

Return 

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} T44StruXXX
Função responsável por criar a estrutura do cabeçalho do fechamento

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function XStruXXX(lModel)

Local oStruXXX := Nil

Default lModel := .T.

If lModel
	//Estrutra do modelo	
	oStruXXX := FWFormModelStruct():New()
	oStruXXX:AddTable("XXX",{},STR0010)
	oStruXXX:AddField(STR0010,;					// Titulo //"Faturamento"
						STR0010,;					// Descrição Tooltip 
						"XXX_FECHA",;				// Nome do Campo
						"C",;						// Tipo de dado do campo
						14,;						// Tamanho do campo
						0,;							// Tamanho das casas decimais
						{|| .T.},;					// Bloco de Validação do campo
						Nil,;						// Bloco de Edição do campo
						{},; 						// Opções do combo
						.F.,; 						// Obrigatório
						Nil,; 						// Bloco de Inicialização Padrão
						.F.,; 						// Campo é chave
						.F.,; 						// Atualiza?
						.T.) 						// Virtual?

	oStruXXX:AddField(STR0025,;				// Titulo //"Usuário"
						STR0025,;				// Descrição Tooltip 
						"XXX_USER",;				// Nome do Campo
						"C",;						// Tipo de dado do campo
						6,;							// Tamanho do campo
						0,;							// Tamanho das casas decimais
						{|| .T.},;					// Bloco de Validação do campo
						Nil,;						// Bloco de Edição do campo
						{},; 						// Opções do combo
						.F.,; 						// Obrigatório
						{|| __cUserId},; 				// Bloco de Inicialização Padrão
						.F.,; 						// Campo é chave
						.F.,; 						// Atualiza?
						.T.) 						// Virtual?
	
			
Else
	
	//Estrutura da View 
	oStruXXX := FWFormViewStruct():New()
	
	oStruXXX:AddField("XXX_FECHA",;				// [01] C Nome do Campo
					"01",;							// [02] C Ordem
					STR0010,; 						// [03] C Titulo do campo //Faturamento
					STR0010,; 						// [04] C Descrição do campo //Faturamento
					{STR0010} ,;					// [05] A Array com Help //Faturamento
					"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
					"@!",;							// [07] C Picture
					NIL,; 							// [08] B Bloco de Picture Var
					"",; 							// [09] C Consulta F3
					.F.,; 							// [10] L Indica se o campo é editável
					NIL, ; 						// [11] C Pasta do campo
					NIL,; 							// [12] C Agrupamento do campo
					{},; 							// [13] A Lista de valores permitido do campo (Combo)
					NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
					NIL,;	 						// [15] C Inicializador de Browse
					.T.) 							// [16] L Indica se o campo é virtual
					
	oStruXXX:AddField("XXX_USER",;				// [01] C Nome do Campo
					"02",;							// [02] C Ordem
					STR0025,; 						// [03] C Titulo do campo //Usuário
					STR0025,; 						// [04] C Descrição do campo //Usuário
					{STR0025} ,;					// [05] A Array com Help //Usuário
					"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
					"@!",;							// [07] C Picture
					NIL,; 							// [08] B Bloco de Picture Var
					"",; 							// [09] C Consulta F3
					.F.,; 							// [10] L Indica se o campo é editável
					NIL, ; 						// [11] C Pasta do campo
					NIL,; 							// [12] C Agrupamento do campo
					{},; 							// [13] A Lista de valores permitido do campo (Combo)
					NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
					NIL,;	 						// [15] C Inicializador de Browse
					.T.) 							// [16] L Indica se o campo é virtual
Endif

Return oStruXXX


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} T44StruG84
Função responsável por criar a estrutura da G84

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function XStruG84(lModel)

Local oStruG84 := Nil
Default lModel := .T.

If lModel
	//Estrutra do modelo	
	oStruG84 := FWFormStruct(1, 'G84', /*bAvalCampo*/, .F./*lViewUsado*/)
	oStruG84:AddField(	"",;					// Titulo
						STR0026,;					// Descrição Tooltip //"Check"
						"G84_OK",;					// Nome do Campo
						"L",;						// Tipo de dado do campo
						1,;							// Tamanho do campo
						0,;							// Tamanho das casas decimais
						{|| U_XChkAll()},;			// Bloco de Validação do campo
						{|| .T.},;					// Bloco de Edição do campo
						{},; 						// Opções do combo
						.F.,; 						// Obrigatório
						NIL,; 						// Bloco de Inicialização Padrão
						.F.,; 						// Campo é chave
						.F.,; 						// Atualiza?
						.T.) 						// Virtual?
	
	oStruG84:AddField(STR0027,;					// Titulo //"Corpor."
						STR0028,;					// Descrição Tooltip //"Corporativo"
						"G84_CORP",;				// Nome do Campo
						"L",;						// Tipo de dado do campo
						1,;							// Tamanho do campo
						0,;							// Tamanho das casas decimais
						{|| .T.},;					// Bloco de Validação do campo
						{|| .T.},;					// Bloco de Edição do campo
						{},; 						// Opções do combo
						.F.,; 						// Obrigatório
						NIL,; 						// Bloco de Inicialização Padrão
						.F.,; 						// Campo é chave
						.F.,; 						// Atualiza?
						.T.) 						// Virtual?
	
	oStruG84:AddField(STR0029,;					// Titulo //"Eventos"
						STR0029,;					// Descrição Tooltip  //"Eventos"
						"G84_EVENT",;				// Nome do Campo
						"L",;						// Tipo de dado do campo
						1,;							// Tamanho do campo
						0,;							// Tamanho das casas decimais
						{|| .T.},;					// Bloco de Validação do campo
						{|| .T.},;					// Bloco de Edição do campo
						{},; 						// Opções do combo
						.F.,; 						// Obrigatório
						NIL,; 						// Bloco de Inicialização Padrão
						.F.,; 						// Campo é chave
						.F.,; 						// Atualiza?
						.T.) 						// Virtual?
	
	oStruG84:AddField(STR0030,;					// Titulo //"Lazer"
						STR0030,;					// Descrição Tooltip //"Lazer"
						"G84_LAZER",;				// Nome do Campo
						"L",;						// Tipo de dado do campo
						1,;							// Tamanho do campo
						0,;							// Tamanho das casas decimais
						{|| .T.},;					// Bloco de Validação do campo
						{|| .T.},;					// Bloco de Edição do campo
						{},; 						// Opções do combo
						.F.,; 						// Obrigatório
						NIL,; 						// Bloco de Inicialização Padrão
						.F.,; 						// Campo é chave
						.F.,; 						// Atualiza?
						.T.) 						// Virtual?
			
Else
	//Estrutura da View
	oStruG84 := FWFormStruct(2, 'G84', /*bAvalCampo*/, .F./*lViewUsado*/) 
	oStruG84:AddField("G84_OK",;						// [01] C Nome do Campo
						"01",;							// [02] C Ordem
						"",; 							// [03] C Titulo do campo //"Check"
						STR0026,; 						// [04] C Descrição do campo //"Check"
						{STR0026} ,;					// [05] A Array com Help //"Check"
						"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;							// [07] C Picture
						NIL,; 							// [08] B Bloco de Picture Var
						"",; 							// [09] C Consulta F3
						.T.,; 							// [10] L Indica se o campo é editável
						NIL, ; 						// [11] C Pasta do campo
						NIL,; 							// [12] C Agrupamento do campo
						{},; 							// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 						// [15] C Inicializador de Browse
						.T.) 							// [16] L Indica se o campo é virtual
	
	oStruG84:AddField("G84_CORP",;					// [01] C Nome do Campo
						"97",;							// [02] C Ordem
						STR0027,; 						// [03] C Titulo do campo //"Corpor."
						STR0028,; 						// [04] C Descrição do campo //"Corporativo"
						{STR0028} ,;					// [05] A Array com Help //"Corporativo"
						"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;							// [07] C Picture
						NIL,; 							// [08] B Bloco de Picture Var
						"",; 							// [09] C Consulta F3
						.F.,; 							// [10] L Indica se o campo é editável
						NIL, ; 						// [11] C Pasta do campo
						NIL,; 							// [12] C Agrupamento do campo
						{},; 							// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 						// [15] C Inicializador de Browse
						.T.) 							// [16] L Indica se o campo é virtual
						
	oStruG84:AddField("G84_EVENT",;					// [01] C Nome do Campo
						"98",;							// [02] C Ordem
						STR0029,; 						// [03] C Titulo do campo //"Eventos"
						STR0029,; 						// [04] C Descrição do campo //"Eventos"
						{STR0029} ,;					// [05] A Array com Help //"Eventos"
						"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;							// [07] C Picture
						NIL,; 							// [08] B Bloco de Picture Var
						"",; 							// [09] C Consulta F3
						.F.,; 							// [10] L Indica se o campo é editável
						NIL, ; 						// [11] C Pasta do campo
						NIL,; 							// [12] C Agrupamento do campo
						{},; 							// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 						// [15] C Inicializador de Browse
						.T.) 							// [16] L Indica se o campo é virtual
						
	oStruG84:AddField("G84_LAZER",;					// [01] C Nome do Campo
						"99",;							// [02] C Ordem
						STR0030,; 						// [03] C Titulo do campo //"Lazer"
						STR0030,; 						// [04] C Descrição do campo //"Lazer"
						{STR0030} ,;					// [05] A Array com Help //"Lazer"
						"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;							// [07] C Picture
						NIL,; 							// [08] B Bloco de Picture Var
						"",; 							// [09] C Consulta F3
						.F.,; 							// [10] L Indica se o campo é editável
						NIL, ; 						// [11] C Pasta do campo
						NIL,; 							// [12] C Agrupamento do campo
						{},; 							// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 						// [15] C Inicializador de Browse
						.T.) 							// [16] L Indica se o campo é virtual
Endif

Return oStruG84


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} T44StruG85
Função responsável por criar a estrutura da G85

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function XStruG85(lModel)

Local oStruG85 := Nil
Default lModel := .T.

If lModel
	//Estrutra do modelo	
	oStruG85 := FWFormStruct(1, 'G85', /*bAvalCampo*/, .F./*lViewUsado*/)
	oStruG85:AddField("",;						// Titulo //"Check"
						STR0026,;					// Descrição Tooltip 
						"G85_OK",;					// Nome do Campo
						"L",;						// Tipo de dado do campo
						1,;							// Tamanho do campo
						0,;							// Tamanho das casas decimais
						{|| U_XChkFil()},;		// Bloco de Validação do campo
						{|| U_X44VldChk()},;		// Bloco de Edição do campo
						{},; 						// Opções do combo
						.F.,; 						// Obrigatório
						NIL,; 						// Bloco de Inicialização Padrão
						.F.,; 						// Campo é chave
						.F.,; 						// Atualiza?
						.T.) 						// Virtual?
	/*					
	oStruG85:AddField("",;						// Titulo //"Check"
						"Valor aux",;					// Descrição Tooltip 
						"G85_VLRAUX",;				// Nome do Campo
						"N",;						// Tipo de dado do campo
						16,;						// Tamanho do campo
						2,;							// Tamanho das casas decimais
						,;							// Bloco de Validação do campo
						,;							// Bloco de Edição do campo
						{},; 						// Opções do combo
						.F.,; 						// Obrigatório
						NIL,; 						// Bloco de Inicialização Padrão
						.F.,; 						// Campo é chave
						.F.,; 						// Atualiza?
						.T.) 						// Virtual?
	*/
Else
	//Estrutura da View
	oStruG85 := FWFormStruct(2, 'G85', /*bAvalCampo*/, .F./*lViewUsado*/) 
	oStruG85:AddField("G85_OK",;					// [01] C Nome do Campo
						"01",;							// [02] C Ordem
						"",; 							// [03] C Titulo do campo //
						STR0026,; 						// [04] C Descrição do campo //"Check"
						{STR0026} ,;					// [05] A Array com Help //"Check"
						"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;							// [07] C Picture
						NIL,; 							// [08] B Bloco de Picture Var
						"",; 							// [09] C Consulta F3
						.T.,; 							// [10] L Indica se o campo é editável
						NIL, ; 							// [11] C Pasta do campo
						NIL,; 							// [12] C Agrupamento do campo
						{},; 							// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 						// [15] C Inicializador de Browse
						.T.) 							// [16] L Indica se o campo é virtual
	/*
	oStruG85:AddField("G85_VLRAUX",;					// [01] C Nome do Campo
						"01",;							// [02] C Ordem
						"",; 							// [03] C Titulo do campo //
						"VLRAUX",; 						// [04] C Descrição do campo //"Check"
						"VLRAUX",;						// [05] A Array com Help //"Check"
						"GET",; 						// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@!",;							// [07] C Picture
						"@E 9,999,999,999,999.99",;		// [08] B Bloco de Picture Var
						"",; 							// [09] C Consulta F3
						.T.,; 							// [10] L Indica se o campo é editável
						NIL, ; 							// [11] C Pasta do campo
						NIL,; 							// [12] C Agrupamento do campo
						{},; 							// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 						// [15] C Inicializador de Browse
						.T.) 							// [16] L Indica se o campo é virtual
	*/

Endif

Return oStruG85

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44ChkFil
Função marcação dos itens da G85

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function XChkFil(lOk)

Local oModel		:= FWModelActive()
Local oView		:= FWViewActive()
Local oModelG84	:= oModel:GetModel('G84_DETAIL')
Local oModelG85	:= oModel:GetModel('G85_DETAIL')
Local cItPrin		:= oModelG85:GetValue("G85_ITEM")
Local cLineAtu	:= oModelG85:GetLine()
Local nX			:= 0
Local lAtualiz	:= .F.
Local lTemMarcado	:= .F.
Local lRet 		:= .T.
Local lExistRa		:= .F.

Default lOk := oModelG85:GetValue("G85_OK")

G4C->(DbsetOrder(4))
G81->(DbsetOrder(1))

If !lOk
	If _nTpFat == TP_VENDA .Or. _nTpFat == TP_BREAK .Or. _nTpFat == TP_CREDITO
		G4C->(DbSeek(xFilial("G4C",oModelG85:GetValue("G85_FILREF"))+oModelG85:GetValue("G85_REGVEN")+oModelG85:GetValue("G85_ITVEND")+oModelG85:GetValue("G85_SEQIV")+oModelG85:GetValue("G85_IDIF")))
		G4C->(DBRUnlock(G4C->(Recno())))
	Else
		G81->(DbSeek(xFilial("G81",oModelG85:GetValue("G85_FILREF"))+oModelG85:GetValue("G85_IDIFA")))
		G81->(DBRUnlock(G81->(Recno())))
	EndIf
Else 
	If !FwIsInCallStack('U_XMkAll')
		If _nTpFat == TP_VENDA .Or. _nTpFat == TP_BREAK .Or. _nTpFat == TP_CREDITO
			If G4C->(DbSeek(xFilial("G4C",oModelG85:GetValue("G85_FILREF"))+oModelG85:GetValue("G85_REGVEN")+oModelG85:GetValue("G85_ITVEND")+oModelG85:GetValue("G85_SEQIV")+oModelG85:GetValue("G85_IDIF")))
				If G4C->G4C_STATUS <> '3'
					lRet := .F.
					Help(,,"TURA044_LOCK",,STR0056,1,0,,,,,,{STR0057})	//'Item selecionado está com status diferente de liberado.'###'Outro processo alterou o item enquanto este não estava marcado, não será permitido faturar este item.'
				
				ElseIf !G4C->(DbRLock(G4C->(Recno())))
					lRet := .F.
					Help(,,"TURA044_LOCK",,STR0053,1,0,,,,,,{STR0054})		//"O item selecionado está sendo utilizado no momento"	"Aguarde a liberação"
				
				ElseIf TA44VldFA(oModelG85:GetValue("G85_REGVEN"))
					lRet := .F.
					Help(,,"TURA044_FAT_AD",,"Este item esta em Fatura de Adiantamento e não está liberado para faturamento.",1,0,,,,,,)	
				EndIf
			EndIf	
		Else
			If G81->(DbSeek(xFilial("G81",oModelG85:GetValue("G85_FILREF"))+oModelG85:GetValue("G85_IDIFA")))
				If G81->G81_STATUS <> '1'
					lRet := .F.
					Help(,,"TURA044_LOCK",,STR0056,1,0,,,,,,{STR0057})	//'Item selecionado está com status diferente de liberado.'###'Outro processo alterou o item enquanto este não estava marcado, não será permitido faturar este item.'
	
				ElseIf !G81->(DbRLock(G81->(Recno())))
					lRet := .F.
					Help(,,"TURA044_LOCK",,STR0053,1,0,,,,,,{STR0054})		//"O item selecionado está sendo utilizado no momento"	"Aguarde a liberação"
				
				ElseIf TA44VldFA(oModelG85:GetValue("G85_REGVEN"))
					lRet := .F.
					Help(,,"TURA044_FAT_AD",,"Este item esta em Fatura de Adiantamento e não está liberado para faturamento.",1,0,,,,,,)	
				EndIf
			EndIf
		EndIf
	EndIf
EndIf	
	
If lRet 

	// Pesquisa os filhos para atualizar conforme o pai, mas só avalia se o item não for filho.
	If Empty(oModelG85:GetValue("G85_ITPRIN"))

		//Atualiza enquanto tiver item filho diferente do pai
		While oModelG85:SeekLine({{"G85_REGVEN",oModelG85:GetValue("G85_REGVEN")},{"G85_ITVEND",oModelG85:GetValue("G85_ITVEND")},{"G85_SEQIV",oModelG85:GetValue("G85_SEQIV")},{"G85_ITPRIN",cItPrin},{"G85_OK",!lOk}})
			If !IsInCallStack('U_XChkAll')
				lAtualiz := oModelG85:SetValue("G85_OK", lOk)
			Else
				If U_XChkFil(lOk)
					oModelG85:LoadValue("G85_OK", lOk)
					lAtualiz := .T.
				EndIf
			EndIf
		EndDo
	
		//Restaura posição alterada pela Seekline
		oModelG85:GoLine(cLineAtu)
	
	EndIf
		
	//Não precisa fazer quando é para todos, pois é feito uma fez só na TA44ChkAll
	If !IsInCallStack('U_XChkAll')

		//Atualiza valor auxiliar que é usado no AddCalc
		If oModelG85:GetValue("G85_OK")
			oModelG85:SetValue("G85_VLRAUX",oModelG85:GetValue("G85_VALOR"))
		Else
			oModelG85:SetValue("G85_VLRAUX",0)
		EndIf

		//Atualiza o valor total na G84 //Deixar como ultimo ponta da validação
		If (lOk .And. oModelG85:GetValue("G85_PAGREC") == '1') .Or.;
			(!lOk .And. oModelG85:GetValue("G85_PAGREC") == '2')
			oModelG84:SetValue("G84_TOTAL"	,oModelG84:GetValue("G84_TOTAL") - oModelG85:GetValue("G85_VALOR"))
		Else
			oModelG84:SetValue("G84_TOTAL"	,oModelG84:GetValue("G84_TOTAL") + oModelG85:GetValue("G85_VALOR"))
		EndIf

		//Só atualiza G84_OK para o item Pai
		If Empty(oModelG85:GetValue("G85_ITPRIN"))
			lTemMarcado := oModelG85:SeekLine({{"G85_OK",.T.}})
		
			If lTemMarcado .And. oModelG84:GetValue("G84_OK") == .F.
				oModelG84:LoadValue("G84_OK", .T.)
			ElseIf !lTemMarcado .And. oModelG84:GetValue("G84_OK") == .T.
				oModelG84:LoadValue("G84_OK", .F.)
			EndIf
	
			oModelG85:GoLine(cLineAtu)	
		
			If lAtualiz .And. oView != Nil 
				FWMsgRun(,{|| oView:Refresh()},  , "Aguarde... atualizando marcação dos itens..." ) 
			EndIf
		EndIf

	EndIf
Else
	oModelG85:LoadValue("G85_OK",!lOk)
EndIf

Return .T.

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44LibReg
Função para liberar os registros bloqueados, caso seja cancelado

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function XLibReg()

If _nTpFat == TP_VENDA .Or. _nTpFat == TP_BREAK .Or. _nTpFat == TP_CREDITO
	G4C->(DBUnlockAll())
ElseIf _nTpFat == TP_APURA
	G81->(DBUnlockAll())
EndIf	

Return .T.



//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44VldChk
Função marcação dos itens da G85

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function X44VldChk()

Local oModel		:= FWModelActive()
Local oModelG85	:= oModel:GetModel('G85_DETAIL')
Local lRet			:= .T.

If !IsInCallStack('U_XChkFil') .And. !Empty(oModelG85:GetValue("G85_ITPRIN"))
	lRet := .F.
EndIf

Return lRet


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44Total
Função seleção de itens para totalização

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function TA44Total(oModel,cTipo)

Local lRet			:= .F.
Local oModelG85	:= oModel:GetModel('G85_DETAIL')

If oModelG85:GetValue("G85_OK")
	If cTipo = '0' .Or. oModelG85:GetValue("G85_TIPO") $ cTipo	
		lRet := .T.	
	EndIf
EndIf

If lRet .Or. IsInCallStack('U_XChkAll') .Or. IsInCallStack('U_XSelVen')
	lRet := .T.
EndIf

Return lRet


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44ChkAll
Função marcação dos itens da G85 conforme G84

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function XChkAll()

Local lRet := .F.

FWMsgRun(,{|| lRet := U_XMrkAll()},  , "Aguarde... atualizando marcação dos itens..." ) 

Return lRet

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44ChkAll
Função marcação dos itens da G85 conforme G84

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function XMrkAll()

Local oModel		:= FWModelActive()
Local oView		:= FWViewActive()
Local oModelG84	:= oModel:GetModel('G84_DETAIL')
Local oModelG85	:= oModel:GetModel('G85_DETAIL')
Local oModelTot	:= oModel:GetModel('TOT_CALC')
Local lOk			:= oModelG84:GetValue("G84_OK")
Local nX			:= 0
Local aSaveLines	:= {}
Local lTemMarcado	:= .F.
Local nTotal		:= 0
Local nAjuTotal 	:= 0
Local nAju_ABATIM	:= 0
Local nAju_RECEIT	:= 0
Local nAju_REEMB	:= 0
Local nAju_VENDA	:= 0
Local nLineAtu	:= oModelG85:GetLine()


For nX := 1 To oModelG85:Length()
	oModelG85:GoLine( nX )
	If Empty(oModelG85:GetValue("G85_ITPRIN"))
		If !TA44VldFA(oModelG85:GetValue("G85_REGVEN"))
			If TA44ChkFil(lOk)
				oModelG85:LoadValue("G85_OK", lOk)
			EndIf
		Else
			Help(,,"TURA044_FAT_AD",,"Este item esta em Fatura de Adiantamento e não está liberado para faturamento.",1,0,,,,,,)
		EndIf
	EndIf


	//Soma total para atualizar depois na G84
	If oModelG85:GetValue("G85_OK") 
		
		nTotal := nTotal + (oModelG85:GetValue("G85_VALOR")  * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))
		
		nAjuTotal := nAjuTotal + ((oModelG85:GetValue("G85_VALOR") - oModelG85:GetValue("G85_VLRAUX") ) * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))

		Do Case
			Case oModelG85:GetValue("G85_TIPO") == '1'
				nAju_VENDA := nAju_VENDA + ((oModelG85:GetValue("G85_VALOR") - oModelG85:GetValue("G85_VLRAUX")) * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))
			Case oModelG85:GetValue("G85_TIPO") $ '2|5'
				nAju_REEMB := nAju_REEMB + ((oModelG85:GetValue("G85_VALOR") - oModelG85:GetValue("G85_VLRAUX")) * IIf(oModelG85:GetValue("G85_PAGREC") == '1',1,-1))
			Case oModelG85:GetValue("G85_TIPO") == '3'
				nAju_RECEIT := nAju_RECEIT + ((oModelG85:GetValue("G85_VALOR") - oModelG85:GetValue("G85_VLRAUX")) * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))
			Case oModelG85:GetValue("G85_TIPO") == '4'
				nAju_ABATIM := nAju_ABATIM + ((oModelG85:GetValue("G85_VALOR") - oModelG85:GetValue("G85_VLRAUX")) * IIf(oModelG85:GetValue("G85_PAGREC") == '1',1,-1))
		EndCase
		
			
		//Atualiza valor auxiliar que é usado no AddCalc
		oModelG85:LoadValue("G85_VLRAUX",oModelG85:GetValue("G85_VALOR"))
	
	Else
		
		nAjuTotal := nAjuTotal - (oModelG85:GetValue("G85_VLRAUX") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1))

		Do Case
			Case oModelG85:GetValue("G85_TIPO") == '1'
				nAju_VENDA := nAju_VENDA  - (oModelG85:GetValue("G85_VLRAUX") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1) )
			Case oModelG85:GetValue("G85_TIPO") $ '2|5'
				nAju_REEMB := nAju_REEMB - (oModelG85:GetValue("G85_VLRAUX") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',1,-1) )
			Case oModelG85:GetValue("G85_TIPO") == '3'
				nAju_RECEIT := nAju_RECEIT - (oModelG85:GetValue("G85_VLRAUX") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',-1,1) )
			Case oModelG85:GetValue("G85_TIPO") == '4'
				nAju_ABATIM := nAju_ABATIM - (oModelG85:GetValue("G85_VLRAUX") * IIf(oModelG85:GetValue("G85_PAGREC") == '1',1,-1) )
		EndCase
		
		oModelG85:LoadValue("G85_VLRAUX",0)
	
	EndIf
	

Next

oModelG84:LoadValue("G84_TOTAL"		,nTotal)
oModelTot:LoadValue("TOT_MARCAD"	,nAjuTotal)
If _nTpFat == TP_VENDA .Or. _nTpFat == TP_BREAK .Or. _nTpFat == TP_CREDITO
oModelTot:LoadValue("TOT_VENDA"		,nAju_VENDA)
oModelTot:LoadValue("TOT_REEMB"		,nAju_REEMB)
EndIf
oModelTot:LoadValue("TOT_RECEIT"	,nAju_RECEIT)
oModelTot:LoadValue("TOT_ABATIM"	,nAju_ABATIM)

lTemMarcado := oModelG85:SeekLine({{"G85_OK",.T.}})

If lTemMarcado .And. oModelG84:GetValue("G84_OK") == .F.
	oModelG84:LoadValue("G84_OK", .T.)
ElseIf !lTemMarcado .And. oModelG84:GetValue("G84_OK") == .T.
	oModelG84:LoadValue("G84_OK", .F.)
EndIf

oModelG85:GoLine(nLineAtu)	

If oView != Nil
	oView:Refresh()
EndIf

Return .T.


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44Grava
Função de gravação do Model (Fatura)

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function X44Grava(oModel)

Local aFaturas	:= {}
Local oModelG84	:= oModel:GetModel('G84_DETAIL')
Local oView		:= FWViewActive()

If oModelG84:Length() == 1 .And. Empty(oModelG84:GetValue("G84_CLIENT"))
	
	Help(,,"TURA044_NOFAT",,STR0031,1,0) //"Não existem registros para faturamento."
	If oView != Nil
		oView:ShowInsertMsg(.F.)
	EndIf

Else
	SetFunName("U_UTUR044V")
	FWMsgRun(,{ || U_X44GerFat(oModel,@aFaturas)},  , STR0032 ) //"Aguarde... Gerando faturas..."

EndIf

Return .T.


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44GerFat
Função de Geração das Faturas conforme quebra do complemento do cliente
Esta função atualiza o NUMFAT da G84 conforme quebra e gera novas G84, se preciso
Após isto submete a Fatura à consolidação financeira
Após a consolidação grava (commit) o próprio Model 

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function X44GerFat( oModel, aFaturas )

Local oModelG84	:= oModel:GetModel('G84_DETAIL')
Local oModelG85	:= oModel:GetModel('G85_DETAIL')
Local oStruG85	:= oModelG85:GetStruct()
Local aCamposG85	:= oStruG85:GetFields()
Local cFilCmp 	:= ""
Local cCodCmp 	:= ""
Local cTpFat	 	:= ""
Local lQbrEnt		:= .F.
Local lQbrSol		:= .F.
Local lQbrGrp		:= .F.
Local lQbrFil		:= .F.
Local nQtdColuna	:= 0
Local nColSol		:= 0
Local nColGrp		:= 0
Local nColFil		:= 0
Local nColEnt		:= 0
Local nX	 		:= 0 	//Linha da G84
Local nY 			:= 0 	//Linha da G85
Local nZ 			:= 0 	
Local nK 			:= 0 	//Linhas de cópias
Local nW 			:= 0 
Local nJ 			:= 0 
Local nH 			:= 0 
Local aItem 		:= {}
Local aEntQbr 	:= {} 	//Entidades de quebra
Local aFatOrdem	:= {}	//Array com conteudo das entidades de quebra de cada item
Local cX			:= "" 	//Expressão com atributaos para ordenatr array 
Local cY			:= "" 	//Expressão com atributaos para ordenatr array 
Local bSortQrb	:= Nil	//Bloco de código para ordenação do array
Local lNovaFat	:= .F.	//Flag de controle de geração e novas Faturas 
Local lAddQbr 	:= .F.
Local nFatAtu		:= 0
Local nLinNova	:= 0	//Numeração da linha da nova Fatura (G84)
Local oModel045	:= Nil 
Local cFilialFat	:= ''
Local lG4MCompF	:= IIF( FWModeAccess("G4M",3) == 'C' , .T., .F.)     
Local cFilialRef	:= ''    
Local lFilDifer	:= .F. 
Local cBkpFilAnt	:= cFilAnt   
Local lQbrQtd		:= .F.
Local nQtdQbr		:= 0   
Local nColQbr		:= 0    
Local nItemQBR		:= 0 
Local nAuxQbr       := 0    
Local lQbrRV		:= .F. 
Local nColQRV		:= 0
Local cTamg85It		:= ALLTRIM( STR( Tamsx3("G85_ITEM")[1] ) )
Local aRVs          := {}
Local nG85          := 0

oModelG84:SetNoInsertLine(.F.)
oModelG85:SetNoInsertLine(.F.) 

oModelG84:SetNoDeleteLine(.F.)
oModelG85:SetNoDeleteLine(.F.)

If _nTpFat == TP_VENDA .Or. _nTpFat == TP_BREAK .Or. _nTpFat == TP_CREDITO
	G4C->(DbsetOrder(4))
Else
	G81->(DbsetOrder(1))
EndIf

//+--------------------------------------------------------------------------
//|	Varre todas as G84 que foram selecionadas para avaliar se gera Fatura
//+--------------------------------------------------------------------------
For nX := 1 To oModelG84:Length()
	oModelG84:GoLine(nX)
	If !oModelG84:GetValue("G84_OK") //Descarta os desmarcados
		
		For nY := 1 to oModelG85:Length()
			
			oModelG85:GoLine(nY)
				
			If _nTpFat == TP_VENDA .Or. _nTpFat == TP_BREAK .Or. _nTpFat == TP_CREDITO
				G4C->(DbSeek(xFilial("G4C",oModelG85:GetValue("G85_FILREF"))+oModelG85:GetValue("G85_REGVEN")+oModelG85:GetValue("G85_ITVEND")+oModelG85:GetValue("G85_SEQIV")+oModelG85:GetValue("G85_IDIF")))
				G4C->(DBRUnlock(G4C->(Recno())))
			Else
				G81->(DbSeek(xFilial("G81",oModelG85:GetValue("G85_FILREF"))+oModelG85:GetValue("G85_IDIFA")))
				G81->(DBRUnlock(G81->(Recno())))
			EndIf
		
		Next nY
		
		oModelG84:DeleteLine()
	Else
		
		//+--------------------------------------------------------------------------
		//|	Pesquisa as Quebras no complemento do cliente
		//+--------------------------------------------------------------------------
		
		cFilCmp := oModelG84:GetValue("G84_FILCMP")
		cCodCmp := oModelG84:GetValue("G84_CMPCLI") 
		cTpFat	 := oModelG84:GetValue("G84_TPFAT")	
		
		lQbrEnt	:= .F.
		lQbrSol	:= .F.
		lQbrGrp	:= .F.
		lQbrFil	:= .F.
		aEntQbr	:= {}
		aFatOrdem	:= {}
		lQbrQtd		:= .F.
		nQtdQbr		:= 0  
		nItemQBR	:= 0 
		nAuxQbr     := 0 
		lQbrRV		:= .F.
		nColQRV		:= 0
		aRVs        := {}
		//quebra por valor - candisani
		lQbrVlr		:= .F.
		nColVlr		:= 0
		nQbrVlr		:= 0
		nValor		:= 0
		nAuxValor   := 0
		nQtdeRVs    := 0
		cRvAux      := ""
		cChave      := ""
		lRVMaior	:= .F. //verifica se um unico RV é maior que a quebra por valor - candisani
		lContinua   := .T. //verifica se um unico RV é maior que a quebra por valor e continua a operação - candisani 
		
		DbselectArea("G67")
		G67->(DbSetOrder(2)) //Filial + Codigo + Tipo (1 - Venda, 2 - Apuracao) + TpAgru (1 - Quebra, 2 - Totaliza)
		G67->(DbSeek(cFilCmp+cCodCmp+cTpFat+"1"))
		While G67->(!Eof()) .And. cFilCmp+cCodCmp+cTpFat+"1" == G67->(G67_FILIAL+G67_CODIGO+G67_TIPO+G67_TPAGRU)
			Do Case
				Case G67->G67_BASE == "1"
					lQbrEnt := .T.
					Aadd(aEntQbr,G67->G67_CODEAD) //Armazena os Tipos de entidades de quebra
				Case G67->G67_BASE == "2"
					lQbrSol := .T.
				Case G67->G67_BASE == "3"	
					lQbrGrp := .T.
				Case G67->G67_BASE == "4"
					lQbrFil := .T.
				Case G67->G67_BASE == "5"	
					lQbrQtd	:= .T.
					nQtdQbr	:= G67->G67_QTDMAX  
				Case G67->G67_BASE == "6"	
					lQbrRV	:= .T.
				Case G67->G67_BASE == "7"
					nQbrVlr:= G67->G67_VLRMAX	
					lQbrVlr	:= .T.	
			EndCase
			
			G67->(DbSkip())
		EndDo
		
		//Consulta filial de faturamento quando o complemnto estiver compartilhado
		If lG4MCompF		
			DbselectArea("G4M")
			G4M->(DbSetOrder(1)) //Filial + Codigo 
			G4M->(DbSeek(cFilCmp+cCodCmp))
			cFilialFat := G4M->G4M_FILFAT		
		EndIf
		
				
		//+--------------------------------------------------------------------------------
		//|	Como o array aFatOrdem é dinamico abaixo é definido a referncia de cda coluna
		//|	conforme as quebras definidas no camplemento do cliente
		//+--------------------------------------------------------------------------------	
		
		nQtdColuna	:= 1 
		
		If lQbrSol 
			nQtdColuna++
			nColSol := nQtdColuna
		EndIf
		
		If lQbrGrp 
			nQtdColuna++
			nColGrp := nQtdColuna
		EndIf
		
		If lQbrFil 
			nQtdColuna++
			nColFil := nQtdColuna
		EndIf
		
		If lQbrEnt 
			nColEnt := nQtdColuna
			nQtdColuna += Len(aEntQbr)
		EndIf
		
		If lQbrRV
			nQtdColuna++
			nColQRV := nQtdColuna
		EndIf
		
		If lQbrQtd
			nQtdColuna++
			nColQbr := nQtdColuna
		EndIf
		
		//quebra por valor - candisani 
		If lQbrVlr
			nQtdColuna++
			nColVlr := nQtdColuna
			nQtdColuna++
		EndIf
		
		
		nFatAtu := Len(aFaturas)
		
		//+----------------------------------------------------------------------------------------
		//|	Se não quebra por nada, simplesmente atribui o numero da fatura e não cria o aFatOrdem 
		//+----------------------------------------------------------------------------------------
		If nQtdColuna <= 1 
			Aadd(aFaturas,{nX,{}}) 
		EndIf
		
		//+--------------------------------------------------------------------------
		//|	Varre toda a G85 para avaliar todos os itens que foram selecionados
		//+--------------------------------------------------------------------------
		cFilialRef	:= ''
		lFilDifer	:= .F.
		
		If !lQbrVlr
			For nY := 1 to oModelG85:Length()
				
				oModelG85:GoLine(nY)
				
				If !oModelG85:GetValue("G85_OK") //Descarta os desmarcados
						
					If _nTpFat == TP_VENDA .Or. _nTpFat == TP_BREAK .Or. _nTpFat == TP_CREDITO
						G4C->(DbSeek(xFilial("G4C",oModelG85:GetValue("G85_FILREF"))+oModelG85:GetValue("G85_REGVEN")+oModelG85:GetValue("G85_ITVEND")+oModelG85:GetValue("G85_SEQIV")+oModelG85:GetValue("G85_IDIF")))
						G4C->(DBRUnlock(G4C->(Recno())))
					Else
						G81->(DbSeek(xFilial("G81",oModelG85:GetValue("G85_FILREF"))+oModelG85:GetValue("G85_IDIFA")))
						G81->(DBRUnlock(G81->(Recno())))
					EndIf
					
					oModelG85:DeleteLine()
					
				Else
					nG85:= nY
					
					//Verifica se possui Filiais distintas para geração da fatura
					If Empty(cFilialRef)
						cFilialRef	:= oModelG85:GetValue("G85_FILREF")
					Else
						lFilDifer := IIF( cFilialRef <> oModelG85:GetValue("G85_FILREF"), .T., )	
					EndIf	
	
					If nQtdColuna > 1 //Testa se quebra por alguma coisa
						
						lAddQbr  := .F.
						aItem    := Array(nQtdColuna)
						aItem[1] := nY
						
						If lQbrSol //Se quebra por solicitante, grava o solicitante no array
							aItem[nColSol] := oModelG85:GetValue("G85_SOLIC") 
							lAddQbr := .T.
						EndIf
						
						If lQbrGrp //Se quebra por grupo, grava o grupo no array
							aItem[nColGrp] := oModelG85:GetValue("G85_GRPPRD")
							lAddQbr := .T.
						EndIf
						
						If lQbrFil //Se quebra por filial, grava no array
							aItem[nColFil] := oModelG85:GetValue("G85_FILREF")
							lAddQbr := .T.
						EndIf
						
						For nZ := 1 To Len(aEntQbr) //Se quebra por alguma entidade, grava no array
							If !Empty(oModelG85:GetValue("G85_TPENT")) .AND. aEntQbr[nZ] == oModelG85:GetValue("G85_TPENT")
								aItem[nColEnt + nZ] := oModelG85:GetValue("G85_ITENT")					
								lAddQbr := .T.	
							Else
								aItem[nColEnt + nZ] := Replicate( ' ', Tamsx3("G85_ITENT")[1] )			
							EndIf	
						Next nZ
						
						If lQbrRV																		
							aItem[nColQRV] := oModelG85:GetValue("G85_REGVEN")
							lAddQbr := .T.
						EndIf
						
						If lQbrQtd																		
							aItem[nColQbr] := STR(nQtdQbr)
							lAddQbr := .T.
						EndIf
		
						If lAddQbr
							AAdd(aFatOrdem,aItem) //Cria array com ID da linha da G85 e o conteudo das entidades de quebra	
						ElseIf Len( aEntQbr ) > 0
							aTail(aItem) := ''
							AAdd(aFatOrdem,aItem)	
						EndIf		
						
					EndIf
				EndIf  	
			Next nY
		Else
			If nQtdColuna > 1 //Testa se quebra por alguma coisa
						
				nY := 1
				nQtdeRVs := 0
				While nY <= oModelG85:Length()

					nQtdeRVs++
					lAddQbr  := .F.
					aItem    := Array(nQtdColuna)
					aItem[1] := nY
					nG85     := nY

					oModelG85:GoLine(nY)
					aItem[nColVlr + 1] := oModelG85:GetValue("G85_REGVEN")
					cChave := oModelG85:GetValue("G85_REGVEN") + oModelG85:GetValue("G85_ITVEND")
					aItem[nColVlr] := 0
					While nY <= oModelG85:Length() .And. cChave == oModelG85:GetValue("G85_REGVEN") + oModelG85:GetValue("G85_ITVEND")
						aItem[nColVlr] := aItem[nColVlr] + IIF(oModelG85:GetValue("G85_PAGREC") == "2", oModelG85:GetValue("G85_VALOR"), oModelG85:GetValue("G85_VALOR") * -1)
	
						nY++
						If nY <= oModelG85:Length()
							oModelG85:GoLine(nY)
						EndIF
					EndDo
					 			
					If nQtdeRVs == 1 .And. aItem[nColVlr] > nQbrVlr //RV maior que a quebra de valor
						lRVMaior := .T. //valor de um unico RV maior que a quebra
						If MsgYesNo("RV maior que o valor de quebra.", "Deseja continuar?")
							lAddQbr := .T.
							lContinua := .T.
						Else //não continua a geração de fatura e aborta 
							lAddQbr  := .F.
							lContinua := .F.
						Endif	
					Else
						lAddQbr := .T.
					Endif	
	
					If lAddQbr
						AAdd(aFatOrdem,aItem) //Cria array com ID da linha da G85 e o conteudo das entidades de quebra	
					ElseIf Len( aEntQbr ) > 0
						aTail(aItem) := ''
						AAdd(aFatOrdem,aItem)	
					EndIf	
				EndDo
			EndIf	
		EndIf

		//+------------------------------------------------------------------------------
		//|	Se quebra por alguma coisa, o array aFatOrdem terá conteudo, mas só justifica 
		//| avaliar geração de novas NF se tiver mais do que um item 
		//+------------------------------------------------------------------------------
		If Len(aFatOrdem) > 0

			//+--------------------------------------------------------------------------------------
			//|	Criar estrutura do bloco de código para ordenar array por todas colunas a partir da 2
			//+--------------------------------------------------------------------------------------
			cX := ""
			cY := ""
			For nW := 2 To nQtdColuna //Só cria aFatOrdem se nQtdColuna for maior que 1, portanto sempre entra no for
					cX += "x["+AllTrim(Str(nW))+"]+"
					cY += "y["+AllTrim(Str(nW))+"]+"
			Next nW	

			cX += "PADL(ALLTRIM(STR(x["+AllTrim(Str(1))+"])),"+cTamg85It+",'0')"
			cY += "PADL(ALLTRIM(STR(y["+AllTrim(Str(1))+"])),"+cTamg85It+",'0')"

			If !lQbrVlr //  se for por valor não ordena - candisani
				bSortQrb := &("{|x,y| "+ cX +" < "+ cY +"}")

				aSort(aFatOrdem,,,bSortQrb)
			Endif
			//+--------------------------------------------------------------------------
			//|	Avalia aFatOrdem para saber se deve gerar novas Faturas (G84) 
			//+--------------------------------------------------------------------------
			aItem := {}
			nValor := 0 // candisani	
			For nK := 1 To Len(aFatOrdem)

				lNovaFat := .F.
				If !lQbrVlr // candisani 
					//+--------------------------------------------------------------------------
					//|	Avalia se tem algum atributo diferente do registro anterior ou se é o primeiro
					//+--------------------------------------------------------------------------
					If nK > 1
						aItem := aFatOrdem[nK-1] //Atribui a linha anterior ao Aux1 para comparação
						nAuxQbr++
						If aScan(aRVs, {|x| x[1] == oModelG85:GetValue('G85_FILREF') .And. x[2] == oModelG85:GetValue('G85_REGVEN') .And. x[3] == oModelG85:GetValue('G85_ITVEND')}) == 0
							aAdd(aRVs, {oModelG85:GetValue('G85_FILREF'), oModelG85:GetValue('G85_REGVEN'), oModelG85:GetValue('G85_ITVEND')})
						EndIf
						For nJ := 2 To Len(aItem)
							If !(aItem[nJ] == aFatOrdem[nK][nJ]) .OR. IIf(lQbrQtd .And. nJ == nColQbr, TA044QbrQt(nQtdQbr,@nAuxQbr,aFatOrdem[nK][1],oModelG85,aRVs), .F.) //Testa se os conteudos são diferentes
								lNovaFat := .T. //Se diferente precisa gerar nova fatura
								nAuxQbr := 1
								aRVs    := {}
								Exit 
							EndIf
						Next nJ	
					Else
						lNovaFat := .T.
						nAuxQbr++ 
					EndIf
	
					//+--------------------------------------------------------------------------
					//| Gera novo item para geração de Fatura
					//+--------------------------------------------------------------------------
					If lNovaFat
						Aadd(aFaturas,{nX,{}}) //Se é novos itens, gera array para geração de novas G84 posteriormente			
					EndIf
					
					//+--------------------------------------------------------------------------
					//| Atualiza array com os numeros da G85 que fazem parte da fatura
					//+--------------------------------------------------------------------------
					Aadd(aFaturas[Len(aFaturas),2],aFatOrdem[nK][1])
					
				ElseIf lQbrVlr .AND. lContinua 

					//quebra por valor enquanto valor for menor ou igual ao valor maximo por fatura não gera uma nova fatura
					If lContinua .AND. !lRVMaior 
						
						nValor := nValor + aFatOrdem[nK][2]
						// verificar se passou o valor para gerar uma nova fatura
						If nK > 1
							If nK + 1 <= Len(aFatOrdem)
								nAuxValor := nValor + aFatOrdem[nK + 1][2]
								cRvAux    := aFatOrdem[nK - 1][3]
							EndIf
							
							If (nValor > nQbrVlr .Or. nAuxValor > nQbrVlr) .And. aFatOrdem[nK][3] <> cRvAux 
								Aadd(aFaturas[Len(aFaturas), 2], aFatOrdem[nK][1])
								lNovaFat := .T.
								nValor := 0
							Else
								If nK < Len(aFatOrdem)   
									lNovaFat := .F.
								Else
									Aadd(aFaturas[Len(aFaturas), 2], aFatOrdem[nK][1])
								EndIf
							EndIf
						Else
							lNovaFat := .T.
							If nK + 1 <= Len(aFatOrdem)
								nAuxValor := nValor + aFatOrdem[nK + 1][2]
							EndIf
						Endif
					ElseIf lContinua .AND. lRVMaior 
						//se RV maior que a quebra logo no primeiro item
						If nK == 1 
							lNovaFat := .T.
						Else
							lNovaFat := .F.	
						Endif	
					Endif	 
				
					If lContinua 
						If lNovaFat
							Aadd(aFaturas,{nX,{}}) //Se é novos itens, gera array para geração de novas G84 posteriormente
							
							If nK == 1
								Aadd(aFaturas[Len(aFaturas),2],aFatOrdem[nK][1])
							EndIf
						ElseIf nK < Len(aFatOrdem) 			
							Aadd(aFaturas[Len(aFaturas),2],aFatOrdem[nK][1])
						EndIf
					Else
						Exit
					EndIf
				Endif
			Next nK	
		
		EndIf
		
		//+--------------------------------------------------------------------------
		//| Envoca Rotina de Consolidação Financeira
		//| E copia G84 para geração da fatura através do TURA045
		//+--------------------------------------------------------------------------	
		If lContinua
			oModel045 := FwLoadModel("TURA045")
			oModel045:SetOperation(OPER_FATURA)
			For nH := (nFatAtu+1) To Len(aFaturas)
				
				FwModelActive(oModel)
				aCopyValues := U_TURxVls("G84_DETAIL", .T.,{},IIf(Len(aFaturas[nH,2])>0,{{"G85_DETAIL",aFaturas[nH,2]}},{}))
				
				//+--------------------------------------------------------------------------
				//| Verifica se o complemento esta compartilhado e não possuir quebra por    |
				//| Filial e possuir itens da fatura com diferentes filiais, neste caso será |
				//| utilizado G4M_FILFAT,caso contrário será utilizado a filial do item.     |
				//+--------------------------------------------------------------------------	
				If lG4MCompF .AND. !lQbrFil .AND. lFilDifer
					
					If !Empty(cFilialFat)
						cFilAnt := cFilialFat
						U_X44NewFa(oModel045,aCopyValues,aFaturas[nH],lQbrFil,lQbrGrp,lQbrSol,lQbrEnt,aEntQbr,lQbrRV,lQbrQtd,lQbrVlr)
					Else
						Help(,,"TURA044_FILFAT",,I18N(STR0055, {cCodCmp,oModel:GetModel("G84_DETAIL"):GetValue("G84_CLIENT",nH)+"/"+oModel:GetModel("G84_DETAIL"):GetValue("G84_LOJA",nH)+" - "+oModel:GetModel("G84_DETAIL"):GetValue("G84_NOME",nH) }),1,0) //"Complemento #1 do Cliente #2 está compartilhado, porém não possui Filial de Fatura preenchido.Não será gerada a fatura."
					EndIf
				Else
					//nG85 := oModel:GetModel("G85_DETAIL"):GetLine()		    
					cFilAnt := oModel:GetModel("G85_DETAIL"):GetValue("G85_FILREF",nG85)
					U_X44NewFa(oModel045,aCopyValues,aFaturas[nH],lQbrFil,lQbrGrp,lQbrSol,lQbrEnt,aEntQbr,lQbrRV,lQbrQtd,lQbrVlr)
				EndIf			
					
			Next nH
			
			oModel045:Destroy()	
				
			cFilAnt := cBkpFilAnt
		Endif		
	EndIf
Next nX

oModelG84:SetNoInsertLine(.T.)
oModelG85:SetNoInsertLine(.T.) 

oModelG84:SetNoDeleteLine(.T.)
oModelG85:SetNoDeleteLine(.T.)
		
Return


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44GerG86
Função para geração da G86 (Quebra de Fatura)

@type 		Function
@author 	Jose Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function XGerG86( oModel, cTpAgru, cCodEnt)

Local oModelG84	:= oModel:GetModel('G84_DETAIL')
Local oModelG86	:= oModel:GetModel('G86_DETAIL')
Local nItem		:= 0

Default cCodEnt := ""

If (oModelG86:Length() == 1 .And. Empty(oModelG86:GetValue("G86_TPAGRU")))
	nItem := 1	
Else
	nItem := oModelG86:AddLine()	
EndIf

oModelG86:GoLine(nItem)

oModelG86:LoadValue("G86_TPAGRU"		,cTpAgru								)
If cTpAgru == '1' 
	oModelG86:LoadValue("G86_CODEAD"	,cCodEnt								)
EndIf		

Return



//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44RTpFat
Retorna Tipo da fatura

@type 		Function
@author 	jose Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function X44RTpFat()

Return _nTpFat



//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44NewFat
Gera Fatura a partir do TURA045

@type 		Function
@author 	jose Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function X44NewFa(oModel045,aCopyValues,aFaturas,lQbrFil,lQbrGrp,lQbrSol,lQbrEnt,aEntQbr,lQbrRV,lQbrQtd,lQbrVlr)

Local nZ			:= 0
Local nX			:= 0
Local lRet			:= .F.
Local lCont			:= .T.
Local cNumFat		:= ""
Local nTotal		:= 0
Local aNoCampos		:= {}
Local cPrefix		:= ""

If oModel045:Activate()
	
	aCopyValues[1] := "G84_MASTER" //Alterado o nome do Model pois é diferente entre as rotinas
	
	//+--------------------------------------------------------------------------
	//|Copia todo o registro da fatura para o model do TURA045
	//+--------------------------------a------------------------------------------	
	If U_TURSetVs( aCopyValues, aNoCampos )			

		If _nTpFat == TP_VENDA
			cPrefix := SuperGetMV("MV_PFXFAT")
		ElseIf  _nTpFat == TP_APURA
			cPrefix := SuperGetMV("MV_PFXAPU")
		ElseIf _nTpFat == TP_BREAK
			cPrefix := SuperGetMV("MV_PFXBRK")
		ElseIf _nTpFat == TP_CREDITO
			If oModel045:GetModel("G84_MASTER"):GetValue('G84_TIPOTI') == '1' //Credito
				cPrefix := SuperGetMV("MV_PFXCRED")
			Else
				cPrefix := SuperGetMV("MV_PFXCPAG")
			EndIf	
		EndIf
		
		//+--------------------------------------------------------------------------
		//| Atualiza numero do Fatura
		//+--------------------------------------------------------------------------
		cNumFat := GetSXENum("G84","G84_NUMFAT", RetSqlName("G84")+xFilial("G84")+cPrefix)					
		oModel045:GetModel("G84_MASTER"):LoadValue('G84_NUMFAT', cNumFat)
		oModel045:GetModel("G84_MASTER"):LoadValue('G84_PREFIX',cPrefix)

		//+--------------------------------------------------------------------------
		//| Atualiza numero do Item
		//+--------------------------------------------------------------------------	
		nTotal := 0
		For nX := 1 To oModel045:GetModel("G85_DETAIL"):Length()
			oModel045:GetModel("G85_DETAIL"):GoLine(nX)
			oModel045:GetModel("G85_DETAIL"):LoadValue('G85_ITEM', StrZero(nX,Len(oModel045:GetModel("G85_DETAIL"):GetValue("G85_ITEM")),0))				
			If oModel045:GetModel("G85_DETAIL"):GetValue("G85_PAGREC") == "1"
				nTotal := nTotal - oModel045:GetModel("G85_DETAIL"):GetValue("G85_VALOR")
			Else
				nTotal := nTotal + oModel045:GetModel("G85_DETAIL"):GetValue("G85_VALOR")
			EndIf
		Next
		
		//+--------------------------------------------------------------------------
		//| Atualiza Total
		//+--------------------------------------------------------------------------		
		oModel045:GetModel("G84_MASTER"):LoadValue('G84_TOTAL', nTotal)
			
		//+--------------------------------------------------------------------------
		//| Grava G86 com as quebras efetuadas em cada fatura
		//+--------------------------------------------------------------------------				
		If lQbrVlr
			U_XGerG86(oModel045,'7')
		EndIf
		If lQbrRV
			U_XGerG86(oModel045,'6')
		EndIf
		
		If lQbrQtd
			U_XGerG86(oModel045,'5')
		EndIf
		
		If lQbrFil
			U_XGerG86(oModel045,'4')
		EndIf
		
		If lQbrGrp
			U_XGerG86(oModel045,'3')
		EndIf
		
		If lQbrSol
			U_XGerG86(oModel045,'2')
		EndIf
		
		If lQbrEnt
			For nZ := 1 To Len(aEntQbr)
				U_TA44GerG86(oModel045,'1',aEntQbr[nZ])
			Next nZ
		EndIf

		If oModel045:VldData() .And. oModel045:CommitData()
			lRet := .T.
		Else
			RollBackSXE()
		EndIf
	EndIf
EndIf

oModel045:Deactivate()

Return lRet


//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44LogBlq
Função para geração do Log de G4C bloqueada

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function XLogBlq(cTabela)

Local aArea	:= GetArea()
Local cLog		:= Chr(10) + Chr(10)

If cTabela == "G4C"
	cLog+= AllTrim(u_TURX3Title("G4C_IDIF"))+" : "+ G4C->G4C_IDIF + Chr(10)
	cLog+= AllTrim(u_TURX3Title("G4C_CODIGO"))+" : "+ G4C->G4C_CODIGO + Chr(10)
	cLog+= AllTrim(u_TURX3Title("G4C_LOJA"))+" : "+ G4C->G4C_LOJA + Chr(10)
	cLog+= AllTrim(u_TURX3Title("G84_NOME"))+" : "+ POSICIONE('SA1', 1, XFILIAL('SA1')+G4C->G4C_CODIGO+G4C->G4C_LOJA,'A1_NOME') + Chr(10)
	cLog+= AllTrim(u_TURX3Title("G4C_NUMID"))+" : "+ G4C->G4C_NUMID + Chr(10)
	cLog+= AllTrim(u_TURX3Title("G4C_IDITEM"))+" : "+ G4C->G4C_IDITEM + Chr(10)
	cLog+= AllTrim(u_TURX3Title("G4C_NUMSEQ"))+" : "+ G4C->G4C_NUMSEQ

ElseIf cTabela == "G81"
	cLog+= AllTrim(u_TURX3Title("G81_IDIFA"))+" : "+ G81->G81_IDIFA + Chr(10)
	cLog+= AllTrim(u_TURX3Title("G81_CLIENT"))+" : "+ G81->G81_CLIENT + Chr(10)
	cLog+= AllTrim(u_TURX3Title("G81_LOJA"))+" : "+ G81->G81_LOJA + Chr(10)
	cLog+= AllTrim(u_TURX3Title("G84_NOME"))+" : "+ POSICIONE('SA1', 1, XFILIAL('SA1')+G81->G81_CLIENT+G81->G81_LOJA,'A1_NOME') + Chr(10)
	cLog+= AllTrim(u_TURX3Title("G81_CODAPU"))+" : "+ G81->G81_CODAPU

EndIf


RestArea(aArea)

Return cLog

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44Calc
Função para calculo do total selecionado

@type 		Function
@author 	José Domingos Caldana Jr
@since 		30/11/2015
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
User Function X44Calc(oModel,nTotalAtual,xValor,lSomando,cTipo)

Local nRet 		:= 0
Local oModelG85	:= oModel:GetModel("G85_DETAIL")
Local lTpPositiv	:= cTipo $ "0|1|3"

If IsInCallStack('U_XSelVen') .Or. IsInCallStack('U_XSelApu')
	nRet := xValor 
ElseIf IsInCallStack('U_XChkAll')
	nRet := nTotalAtual + xValor 
Else
If	(lTpPositiv .And. oModelG85:GetValue("G85_PAGREC") == "2" .And. lSomando) .Or.;
	(lTpPositiv .And. oModelG85:GetValue("G85_PAGREC") == "1" .And. !lSomando) .Or.;
	(!lTpPositiv .And. oModelG85:GetValue("G85_PAGREC") == "2" .And. !lSomando) .Or.;
	(!lTpPositiv .And. oModelG85:GetValue("G85_PAGREC") == "1" .And. lSomando) 
	nRet := nTotalAtual + xValor 
Else
	nRet := nTotalAtual - xValor 
	EndIf
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TA44NoAlt() 
Rotina para inibir a pergunta se deseja salvar ou não 

@author José Domingos Caldana Jr
@since 21/10/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
User Function X44NoAlt(oModel)

Local oView 		:= FWViewActive()
Local oModelG84	:= oModel:GetModel("G84_DETAIL")
Local lRet 		:= .T.
	
If oModelG84:Length() <> 1 .Or. !Empty(oModelG84:GetValue("G84_CMPCLI"))
	lRet := FwAlertYesNo(STR0042,STR0043) //"Deseja realmente cancelar a geração das Faturas?"//"Cancelar Faturamento?"
EndIf 

If lRet
	oView:SetModified(.F.)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TA44ValFat() 
Rotina para validar geração das faturas

@author José Domingos Caldana Jr
@since 21/10/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
User Function XValFat(oModel)

Local aArea			:= GetArea()
Local aAreaSE4		:= SE4->(GetArea())
Local oModelG84 	:= oModel:GetModel("G84_DETAIL")
Local oModelG85 	:= oModel:GetModel("G85_DETAIL")
Local nX			:= 0
Local nY			:= 0
Local lRet			:= .T.
Local nLinG84		:= oModelG84:GetLine()
Local nLinG85		:= oModelG85:GetLine()
Local nTotal		:= 0
Local cAliasDupl	:= ""
Local nFatVlrMin	:= SuperGetMV("MV_FTVLMIN", .F., 0 )

DbSelectArea("SE4")
SE4->(DbSetOrder(1)) //E4_FILIAL+E4_CODIGO
For nX := 1 To oModelG84:Length()
	oModelG84:GoLine(nX)
	If oModelG84:GetValue("G84_OK") 
		If Empty(oModelG84:GetValue("G84_CONDPG"))
			Help(,,"TA44_SEMCP",,STR0044,1,0,,,,,,{STR0045}) //"Existem itens selecionados para faturamento sem condição de pagamento." //"Informe a condição de pagamento desejada."
			lRet := .F.
			Exit
		ElseIf !SE4->(DbSeek(xFilial("SE4") + oModelG84:GetValue("G84_CONDPG")))
			Help(,,"TA44_SEMCPFIL",,STR0046,1,0,,,,,,{STR0047}) //"Existem itens selecionados para faturamento que possuem a condição de pagamento inválida para a filial corrente." //"Informe uma condição de pagamento válida para a filial corrente e tente novamente."
			lRet := .F.
			Exit			
		ElseIf oModelG84:GetValue("G84_MOEDA") <> "01"
			U_TurHelp("Faturamento não habilitado para outras moedas.","Altere o RV para moeda 01.","TA44_MOEDA") //"Faturamento não habilitado para outras moedas." 
			lRet := .F.
			Exit	
		EndIf
		
		If lRet
			nTotal := 0
			For nY := 1 To oModelG85:Length()
				oModelG85:GoLine(nY)
				If oModelG85:GetValue("G85_OK") .And. Empty(oModelG85:GetValue("G85_NATURE"))  	
					Help(,,"TA44_SEM_NAT",,STR0048,1,0,,,,,,{STR0049}) //"Existem itens selecionados para faturamento que não possuem Natureza."//"Informe uma Natureza válida e tente novamente."         
					lRet := .F.
					Exit
				EndIf
			
				
				If oModelG85:GetValue("G85_OK") .And. (U_TA44RTpFat() == TP_VENDA .Or. U_TA44RTpFat() == TP_BREAK .Or. U_TA44RTpFat() == TP_CREDITO)
					cAliasDupl := GetNextAlias()
				
					BeginSql Alias cAliasDupl
						SELECT G85_FILIAL, G85_PREFIX, G85_NUMFAT FROM %Table:G85% G85
						INNER JOIN %Table:G84% G84 ON
						G84_FILIAL = G85_FILIAL AND
						G84_PREFIX = G85_PREFIX AND
						G84_NUMFAT = G85_NUMFAT AND
	 					G84.%NotDel%
						WHERE
						G85_FILREF = %exp:oModelG85:GetValue("G85_FILREF",nY)% AND
						G85_IDIF = %exp:oModelG85:GetValue("G85_IDIF",nY)% AND  
						G84_STATUS = '1' AND 
						G85.%NotDel%
					EndSql
					
					If (cAliasDupl)->(! EOF())
						lRet := .F.
						U_TurHelp(u_TURX3Title("G85_FILIAL")+": "+oModelG85:GetValue("G85_FILREF",nY)+u_TURX3Title("G85_IDIF")+": "+oModelG85:GetValue("G85_IDIF",nY),"Item não será faturado. Avaliar duplicidade.","Item Duplicado")
						Exit
					EndIf
					
					(cAliasDupl)->(DbCloseArea())
				EndIf
				
				If oModelG85:GetValue("G85_OK")
					If oModelG85:GetValue("G85_PAGREC") == '1'
						nTotal := nTotal - oModelG85:GetValue("G85_VALOR")
					Else
						nTotal := nTotal + oModelG85:GetValue("G85_VALOR")
					EndIf
				EndIf						
			Next nY
			
			// -- Valida valor mínimo para geração de fatura
			If nFatVlrMin > 0 .And. (U_TA44RTpFat() == TP_VENDA)
				If nTotal <= nFatVlrMin
					Help(,,"TA44_FATVLR",,STR0064,1,0,,,,,,{STR0065})
					lRet := .F.
				EndIf
			EndIf
		
		EndIf 
		
		If !lRet
			Exit
		EndIf
	EndIf	
Next
  
RestArea(aAreaSE4)
RestArea(aArea)

oModelG84:GoLine(nLinG84)
oModelG85:GoLine(nLinG85)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TA044MkAll 

Função para marcar/desmarcar todos os clientes para faturamento

@author Thiago Tavares
@since 17/11/2016
@version 12.1.13
/*/
//-------------------------------------------------------------------
User Function X44MkAll(oView)

Local aSaveRows := FwSaveRows()
Local oModel    := oView:GetModel()
Local nX        := 0
Local lMark     := .F.
Local lFirst    := .T.

Default oView  := FwViewActive()

For nX := 1 To oModel:GetModel("G84_DETAIL"):Length()
	If !oModel:GetModel("G84_DETAIL"):IsDeleted()
		oModel:GetModel("G84_DETAIL"):GoLine(nX)
		If lFirst 
			lMark  := !oModel:GetModel("G84_DETAIL"):GetValue("G84_OK") 
			lFirst := .F.
		EndIf
		oModel:SetValue("G84_DETAIL", "G84_OK", lMark)
	EndIf
Next nX 

oView:Refresh("G84_DETAIL")

FwRestRows(aSaveRows)

Return()

/*/{Protheus.doc} TA044QbrQt
(long_description)
@type function
@author osmar.junior
@since 09/03/2017
@version 1.0
@param nQtdQbr, numérico, Quantidade para quebra
@param nAuxQbr, numérico, Referencia do item
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function XTA044QbrQt(nQtdQbr,nAuxQbr,nItem,oModelG85,aRVs)
Local lRet	  := .F.
Local lAcerto := .F.
Local lRateio := .F.

oModelG85:GoLine(nItem)

lAcerto := oModelG85:HasField('G85_ACERTO') .And. oModelG85:GetValue('G85_ACERTO') == '1'
lRateio := !Empty(oModelG85:GetValue('G85_TPENT'))

If (nAuxQbr > nQtdQbr) .AND. (!lAcerto .And. Empty(oModelG85:GetValue('G85_ITPRIN')))
	lRet	:= .T.
	nAuxQbr := 1
ElseIf lAcerto .Or. !Empty(oModelG85:GetValue('G85_ITPRIN'))
	If !Empty(oModelG85:GetValue('G85_ITPRIN'))
		nAuxQbr--
	Else
		If !lRateio .Or. (lRateio .And. U_TA044VldEA(oModelG85))
			nAuxQbr--
		ElseIf (nAuxQbr > nQtdQbr)
			lRet	:= .T.
			nAuxQbr := 1
		EndIf
	EndIf
EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TA044VldEA 

Função que valida a entidade adicional do rateio de um IV de acerto 
com a entidade adicional do IV de origem

@author Thiago Tavares
@since 06/04/2016
@version 12.1.14
/*/
//-------------------------------------------------------------------
User Function X44VldEA(oModelG85)

Local aArea     := GetArea() 
Local cAliasG4C := GetNextAlias()
Local lRet      := .F.
Local cFilRef   := oModelG85:GetValue('G85_FILREF')
Local cNumId    := oModelG85:GetValue('G85_REGVEN')
Local cIdItem   := oModelG85:GetValue('G85_ITVEND')
Local cNumSeq   := oModelG85:GetValue('G85_SEQIV')
Local cTpEnt    := oModelG85:GetValue('G85_TPENT')
Local cEntAdc   := oModelG85:GetValue('G85_ITENT')
Local cConinu   := Space(TamSx3("G4C_CONINU")[1])
Local nX        := 0

If Val(cNumSeq) > 1
	BeginSql Alias cAliasG4C
		SELECT G4C_IDIF
		FROM %Table:G4C% G4C
		INNER JOIN %Table:G3Q% G3Q ON G3Q_FILIAL = G4C_FILIAL AND 
	                                  G3Q_NUMID  = G4C_NUMID  AND 
	                                  G3Q_IDITEM = G4C_IDITEM AND 
	                                  G3Q_TPDOC <> '4' AND
	                                  G3Q_ACERTO = '2' AND
	                                  G3Q.%NotDel%
	 	WHERE G4C_FILIAL = %Exp:cFilRef% AND 
	 	      G4C_NUMID  = %Exp:cNumID%  AND
	 		  G4C_IDITEM = %Exp:cIdItem% AND
	 		  G4C_ENTAD  = %Exp:cTpEnt%  AND
	 		  G4C_ITRAT  = %Exp:cEntAdc% AND
	 		  G4C_CLIFOR = '1' AND 
	 		  G4C_STATUS = '3' AND 
	 		  G4C_CONINU = %Exp:cConinu% AND 
	 		  G4C.%NotDel%
	EndSql
	
	If (cAliasG4C)->(!Eof())
		lRet := .T.
	EndIf

	(cAliasG4C)->(DbCloseArea())
EndIf

RestArea(aArea)

Return lRet


/*/{Protheus.doc} cExpFil
Retorna expressão para utilização na query de venda
@type function
@author osmar.junior
@since 27/04/2017
@version 1.0
@param cTabela, character, (Nome da tabela relacionada no Join)
@param cAliasTab, character, (Alias da tabela relacionada no Join, caso diferente do cTabela)
@param cTabBase, character, (Nome da tabela base do Join)
@return ${return}, ${return_description}
@example cExpFil('G4L','G4L1','G81')
@see (links_or_references)
/*/
User Function cExpFil(cTabela,cAliasTab,cTabBase)
Local cCompE		:= FWModeAccess(cTabela,1)
Local cCompU		:= FWModeAccess(cTabela,2)
Local cCompF		:= FWModeAccess(cTabela,3)
Local nTam			:= FWSizeFilial()
Local cRet			:= '%%'

Default cAliasTab := cTabela
Default cTabBase := 'G4C'

If cCompE=='C' //Empresa Compartilhada
	nTam -= Len(FWSM0Layout(,1))                                                                                                          
EndIf

If cCompU=='C' //Unidade Compartilhada
	nTam -= Len(FWSM0Layout(,2))
EndIf

If cCompF=='C' //Filial Compartilhada
	nTam -= Len(FWSM0Layout(,3))
EndIf

If nTam > 0
	cRet := "%SUBSTRING("+cAliasTab+"."+PrefixoCpo(cTabela)+"_FILIAL,1,"+ALLTRIM(STR(nTam))+") = SUBSTRING("+cTabBase+"_FILIAL,1,"+ALLTRIM(STR(nTam))+") AND%"
EndIf

Return cRet

//Retorna conteúdo do nTpfat 
User Function XT44SETTpFat(nTpfat)
_nTpFat     	:= nTpfat

Return

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44VldFA
Função para validar se o item esta em uma Fatura de Adiantamento com RA disponivel

/*/
//+----------------------------------------------------------------------------------------
User Function TA44VldFA(cNumid)

	Local lRetorno	:= .F.
	Local cAlias	:= GetNextAlias()

	BeginSql Alias cAlias
		SELECT G8G_FILIAL, G8G_FATADI, G8G_RAPREF, G8G_RA, G8G_RAPARC, G8H_FILIAL, G8H_NUMID
		FROM %Table:G8G% G8G
		INNER JOIN %Table:G8H% G8H 
		ON G8G_FILIAL = G8H_FILIAL 
		AND	G8G_FATADI = G8H_FATADI
		WHERE G8G.%notDel% 
		AND G8H_NUMID = %Exp:cNumid% 
		AND	G8H.%notDel%
	EndSql

	If (cAlias)->(EOF()) 
		lRetorno := .F.
	ElseIf (cAlias)->(!EOF()) .And. (cAlias)->G8G_RA = " "
		lRetorno := .T.
	EndIf
	
	(cAlias)->(dbCloseArea())

Return lRetorno

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44Refat
Função de chamada de refaturamento

@type 		Function
@author 	Rogerio O Candisani
@since 		29/11/2019
@version 	12.1.17
/*/
//+----------------------------------------------------------------------------------------

User Function X44Refat()

Local cTitulo 	:= ""
Local cPrograma	:= ""
Local aEnableBut 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,OemToAnsi(STR0008)},{.T.,OemToAnsi(STR0007)},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }//"Faturar" //"Cancelar"
Local nOperation	:= MODEL_OPERATION_INSERT
Local bCancel		:= {|oModel| U_X44NoAlt(oModel)}
Local nRet			:= 0		

_nOperFat      	:= OPER_REFATU
cTitulo 		:= STR0040
cPrograma    	:= 'UTUR044'
nRet         	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, aEnableBut, bCancel, /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
_nOperFat      	:= 0

If nRet == 1
	U_XLibReg()
EndIf

T35DelCache()

Return G84->(RecNo())

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TA44Refat
Função de refaturamento

@type 		Function
@author 	Rogerio O Candisani
@since 		29/11/2019
@version 	12.1.17
/*/
//+----------------------------------------------------------------------------------------

User Function XSelRef()

Local aArea       := GetArea()
Local oModelXXX   := oModel:GetModel("XXX_MASTER")
Local oModelG84   := oModel:GetModel("G84_DETAIL")
Local oModelG85   := oModel:GetModel("G85_DETAIL")
Local oModelTot   := oModel:GetModel("TOT_CALC")
Local aCmpDtFech  := {}
Local aXFech	  := {}
Local lIncluiG85  := .T.
Local lFecha      := .F.
Local lMarcar     := .F. //Define se inicializa marcado
Local lExtTurNat  := FindFunction('U_TURNAT')
Local cConinu     := Space(TamSx3("G4C_CONINU")[1])
Local cAliasITF   := ""
Local cWhere      := ""
Local cCondPg     := ""
Local cFilCond    := ""
Local cNat		  := ""
Local cNomeArq	  := ""
Local cExpSBM	  := cExpFil('SBM')
Local cExpSB1	  := cExpFil('SB1')
Local cExpSA1	  := cExpFil('SA1')
Local cExpSU5	  := cExpFil('SU5')
Local cExpG3E	  := cExpFil('G3E')
Local cExpG3G	  := cExpFil('G3G')
Local cExpG4L1    := cExpFil('G4L','G4L1')
Local cExpG4L2    := cExpFil('G4L','G4L2')
Local cExpG8B	  := cExpFil('G8B')
Local nItemG85    := 0
Local nItemG84    := 0
Local nTotal 	  := 0
Local nTOT_ABATIM := 0
Local nTOT_RECEIT := 0
Local nTOT_REEMB  := 0
Local nTOT_VENDA  := 0
Local nHandCre	  := 0
Local cItemG85    := 0	
Local nRecno	  := 0	
Local nPos        := 0
Local nX          := 0
Local nValor      := 0

//candisani //dados da fatura posicionada
Local aItemG85    := {}
Local cFilialG84  := G84->G84_FILIAL
Local cPrefix     := G84->G84_PREFIX
Local cNumFat     := G84->G84_NUMFAT
Local cClient     := G84->G84_CLIENT
Local cLoja       := G84->G84_LOJA
Local cCondPg     := G84->G84_CONDPG
Local cMoeda      := G84->G84_MOEDA
Local cFilCmp	  := G84->G84_FILCMP
Local cCmpCli     := G84->G84_CMPCLI
Local cTpFat      := G84->G84_TPFAT
Local cIDIF       := ""
Local cITPrin     := ""
Local cFilRef     := ""
Local cFilCond    := ""
Local cTipo       := ""
Local cRegVen     := ""
Local cItVend     := ""
Local cSeqIv      := ""
Local cDoc        := ""
Local cClass      := ""
Local cClaDes     := ""
Local cSeqNeg     := ""
Local cCodPrd     := ""
Local cPrdDes     := ""
Local cGrpPrd     := ""
Local cGrpDes     := ""
Local cPagRec     := ""
Local cSolic      := ""
Local cNumSol     := ""
Local cTpEnt      := ""
Local cEntDes     := ""
Local cItEnt      := ""
Local cItDesc     := ""
Local cAcerto     := ""
Local cNature     := ""
Local nAuxRegVen  := ""
Local nAuxItem	  := "" 

//+---------------------------------------------------
//|	Carregar os dados da fatura cancelada posicionada
//+--------------------------------------------------- 
oModelG84:SetNoInsertLine(.F.)
oModelG85:SetNoInsertLine(.F.) 
	
		
oModelXXX:LoadValue("XXX_FECHA"	,DTOS(dDataBase)+StrTran(Time(),":",""))
	
oModelG84:LoadValue("G84_OK"	, lMarcar)
oModelG84:LoadValue("G84_FECHA"	, DTOS(dDataBase) + StrTran(Time(), ":", ""))
oModelG84:LoadValue("G84_TPFAT"	, AllTrim(Str(_nTpFat)))
oModelG84:LoadValue("G84_CLIENT", cClient)
oModelG84:LoadValue("G84_LOJA"	, cLoja)
oModelG84:LoadValue("G84_NOME"	, GetAdvFVal("SA1", "A1_NOME", xFilial("SA1") + cClient + cLoja, 1, ""))
oModelG84:LoadValue("G84_EMISS"	, dDataBase)
oModelG84:LoadValue("G84_CONDPG", cCondPg)
oModelG84:LoadValue("G84_CPDESC", GetAdvFVal("SE4", "E4_DESCRI", xFilial("SE4") + cCondPg, 1, ""))
oModelG84:LoadValue("G84_MOEDA"	, cMoeda)
oModelG84:LoadValue("G84_ENVELE", "2")
oModelG84:LoadValue("G84_FILCMP", cFilCmp)
oModelG84:LoadValue("G84_CMPCLI", cCmpCli)
oModelG84:LoadValue("G84_STATUS", "1")	
oModelG84:LoadValue("G84_TPFAT" , cTpFat)	

//verificar os itens já faturados na G85
//verificar se os itens cancelados já foram faturados em outra nota
	
G85->(DbSetOrder(1))
If G85->(DbSeek(cFilialG84 + cPrefix + cNumFat))	
	While G85->(!EOF()) .AND. (G85->G85_FILREF == cFilialG84 .AND. G85->G85_PREFIX == cPrefix .AND. G85->G85_NUMFAT == cNumFat)	
		cNumFat := G85->G85_NUMFAT
		cIDIF   := G85->G85_IDIF
		cFilRef := G85->G85_FILREF
		cTipo   := G85->G85_TIPO
		cRegVen := G85->G85_REGVEN
		cItVend := G85->G85_ITVEND
		cSeqIv  := G85->G85_SEQIV
		cDoc    := G85->G85_DOC
		cClass  := G85->G85_CLASS
		cSeqNeg := G85->G85_SEGNEG
		cCodPrd := G85->G85_CODPRD
		cGrpPrd := G85->G85_GRPPRD
		cMoeda  := G85->G85_MOEDA
		cPagRec := G85->G85_PAGREC
		cSolic  := G85->G85_SOLIC
		cTpEnt  := G85->G85_TPENT
		cItEnt  := G85->G85_ITENT
		nValor  := G85->G85_VALOR
		cNature := G85->G85_NATURE
				
		aAdd(aItemG85, {lIncluiG85 	,; //aItemG85[nX][1]
						cNumFat   	,; //aItemG85[nX][2]
						cIDIF	  	,; //aItemG85[nX][3]
						cFilRef   	,; //aItemG85[nX][4]
						cTipo		,; //aItemG85[nX][5]
						cRegVen 	,; //aItemG85[nX][6]
						cItVend 	,; //aItemG85[nX][7] 
						cSeqIv 		,; //aItemG85[nX][8]
						cDoc 		,; //aItemG85[nX][9]
						cClass 		,; //aItemG85[nX][10]
						cClaDes 	,; //aItemG85[nX][11]
						cSeqNeg 	,; //aItemG85[nX][12]
						cCodPrd 	,; //aItemG85[nX][13]
						cPrdDes 	,; //aItemG85[nX][14]
						cGrpPrd 	,; //aItemG85[nX][15]
						cGrpDes 	,; //aItemG85[nX][16]
						cMoeda 		,; //aItemG85[nX][17]
						cPagRec 	,; //aItemG85[nX][18]
						cSolic 		,; //aItemG85[nX][19]
						cNumSol 	,; //aItemG85[nX][20]
						cTpEnt 		,; //aItemG85[nX][21]
						cEntDes 	,; //aItemG85[nX][22]
						cItEnt 		,; //aItemG85[nX][23]
						cItDesc 	,; //aItemG85[nX][24]
						nValor 		,; //aItemG85[nX][25]
						cAcerto 	,; //aItemG85[nX][26]
						cNature 	,; //aItemG85[nX][27]
						})
		G85->(DbSkip())
	Enddo
EndIf

//gravação do item G85 para os itens não faturados
nItemG85 := 1	

For nX:= 1 to len(aItemG85)
//posicionar na GC4
G4C->(DbsetOrder(2)) // FILIAL+IDIF
	If G4C->(DbSeek(aItemG85[nX][4] + aItemG85[nX][3]))
		If G4C->G4C_STATUS == '3' 
			oModelG85:SetNoInsertLine(.F.)
			If  nItemG85 <> 1		
				nItemG85 := oModelG85:AddLine()
			Endif	
			
			oModelG85:GoLine(nItemG85)
			oModelG85:LoadValue("G85_ITEM"	, StrZero(nItemG85, Len(oModelG85:GetValue("G85_ITEM")), 0))
			oModelG85:LoadValue("G85_OK"	, lMarcar)
			oModelG85:LoadValue("G85_TIPO"	, aItemG85[nX][5])
			oModelG85:LoadValue("G85_FILREF", aItemG85[nX][4])
			oModelG85:LoadValue("G85_IDIF"	, aItemG85[nX][3])
			oModelG85:LoadValue("G85_REGVEN", aItemG85[nX][6])
			oModelG85:LoadValue("G85_ITVEND", aItemG85[nX][7])
			oModelG85:LoadValue("G85_SEQIV"	, aItemG85[nX][8])
			oModelG85:LoadValue("G85_DOC"	, aItemG85[nX][9])
			oModelG85:LoadValue("G85_CLASS"	, aItemG85[nX][10])
			oModelG85:LoadValue("G85_SEGNEG", aItemG85[nX][12])
			oModelG85:LoadValue("G85_CODPRD", aItemG85[nX][13])
			oModelG85:LoadValue("G85_GRPPRD", aItemG85[nX][15])
			oModelG85:LoadValue("G85_MOEDA"	, aItemG85[nX][17])
			oModelG85:LoadValue("G85_PAGREC", aItemG85[nX][18])
			oModelG85:LoadValue("G85_EMISSA", dDataBase)
			oModelG85:LoadValue("G85_SOLIC"	, aItemG85[nX][19])
			oModelG85:LoadValue("G85_TPENT"	, aItemG85[nX][21])
			oModelG85:LoadValue("G85_ITENT"	, aItemG85[nX][23])
			oModelG85:LoadValue("G85_VALOR"	, aItemG85[nX][25])
			oModelG85:LoadValue("G85_VLRAUX", IIf(lMarcar, aItemG85[nX][25], 0))
			oModelG85:LoadValue("G85_NATURE", aItemG85[nX][27])	
			
			If nAuxRegVen == aItemG85[nX][6] //candisani
				oModelG85:LoadValue("G85_ITPRIN", nAuxItem)
			Else
				//item principal
				nAuxItem:= StrZero(nItemG85, Len(oModelG85:GetValue("G85_ITEM")), 0) 	
			Endif
			
			If oModelG85:VldLineData()			
				If lMarcar
											
					//Atualiza o total
					nTotal := nTotal + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', -1, 1))
					
					Do Case
						Case oModelG85:GetValue("G85_TIPO") == '1'
			 				nTOT_VENDA := nTOT_VENDA   + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', -1, 1))
						Case oModelG85:GetValue("G85_TIPO") $ '2|5'
							nTOT_REEMB := nTOT_REEMB   + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', 1, -1))
						Case oModelG85:GetValue("G85_TIPO") == '3'
							nTOT_RECEIT := nTOT_RECEIT + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', -1, 1))
						Case oModelG85:GetValue("G85_TIPO") == '4'
							nTOT_ABATIM := nTOT_ABATIM + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', 1, -1))
					EndCase
				
					oModelG84:LoadValue("G84_TOTAL", oModelG84:GetValue("G84_TOTAL") + (oModelG85:GetValue("G85_VALOR") * IIf(oModelG85:GetValue("G85_PAGREC") == '1', -1, 1)))
				EndIf
			Endif
				If  nItemG85 == 1
					nItemG85++
				EndIf
				//guarda o numero do RegVen para marcar os filhos //candisani
			nAuxRegVen:= oModelG85:GetValue("G85_REGVEN")
		Endif	
	Endif
Next nX

If lMarcar
	oModelTot:LoadValue("TOT_MARCAD", nTotal)
	oModelTot:LoadValue("TOT_VENDA"	, nTOT_VENDA)
	oModelTot:LoadValue("TOT_REEMB"	, nTOT_REEMB)
	oModelTot:LoadValue("TOT_RECEIT", nTOT_RECEIT)
	oModelTot:LoadValue("TOT_ABATIM", nTOT_ABATIM)
EndIf
	
oModelG84:GoLine(1)
oModelG85:GoLine(1)

RestArea(aArea)
		
oModelG84:SetNoInsertLine(.T.)
oModelG85:SetNoInsertLine(.T.) 

Return 