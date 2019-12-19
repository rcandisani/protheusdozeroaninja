#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'XMLXFUN.CH' 
#INCLUDE "RWMAKE.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "ApWebSrv.ch"
#INCLUDE "FWADAPTEREAI.ch"
#INCLUDE "FWMVCDEF.ch"

//------------------------------------------------------------------- 
/*/{Protheus.doc} WsImpXML 
Funcao para ler XML e importar 
@author Rogerio Onishi Candisani 

@version P12 
/*/ 
//------------------------------------------------------------------- 
User Function WsImpXML()
 

WSSTRUCT eIMPXML	// Declaração da(s) Estrututra(s) ( opcionais ) 
	WSData cXML	    As String
				
ENDWSSTRUCT

WSService Importar_XML Description "Webservice Importação de XML"
	WSData eIMPXML		As String
	WSData cRetorno     As String
	WSData cXML	    	As String
		
	WSMethod Ler_XML      Description "Ler XML Importar"
	WSMethod Grava_XML Description "Importa XML"

EndWSService                                                                                       

//wservice para leitura de XML ainda não definida a rotina
WSMethod Ler_XML WSReceive cXML WSSend eIMPXML  WSService Importar_XML


Return .T.	

WSMethod Grava_XML WSReceive eIMPXML WSSend cRetorno  WSService Importar_XML

Local cXML := ""
Local oXML
Local x
Local y
Local z
Local aNodes:={} //quantidade de nós
Local nItem:= 0
Local aXMLItens:= {}
Local aAuxItens:= {}
Local aItens:= {}
Local aCabec:= {}
Local aLinha:= {}

//Inf NFE
Local c_cUF:= ""
Local c_cNF:= ""
Local c_NatOP:= ""
Local c_Mod:= ""
Local c_Serie:= ""
Local c_nNF:= ""
Local c_dhEmi:= ""
Local c_dhSaiEnt:= ""
Local c_tpNF:= ""
Local c_IdDest:= ""
Local c_MunFG:= ""
Local c_TpEmis:=""
Local c_CNPJ:= ""
Local c_xNome:= ""
Local c_xLgr:= ""
Local c_nro:= ""
Local c_xCpl:= ""
Local c_xBairro:= ""
Local c_cMun:= ""
Local c_xMun:= ""
Local c_UF:= ""
Local c_CEP:= ""
Local c_cPais:= ""
Local c_xPais:= ""
Local c_fone:= ""

//Produto
Local c_Prod:= ""
Local c_EAN:= ""
Local c_xProd:= ""
Local c_NCM:= ""
Local c_CEST:= ""
Local c_indEscala:= ""
Local c_CFOP:= ""
Local c_uCOM:= ""
Local c_qCOM:= ""
Local c_vUnCom:= ""
Local c_vProd:= ""
Local c_cEANTrib:= ""
Local c_uTrib:= ""
Local c_qTrib:= ""
Local c_vUnTrib:= ""
Local c_vDesc:= ""
Local c_indTot:= ""
Local cXPath:= ""

//Imposto - ICMS 
Local c_vTotTrib:=0 
Local c_ICMorig:= 0
Local c_ICMCST:= 0
Local c_vBCSTRet:=0 
Local c_ICMpST:= 0
Local c_vICMSSTRet:=0 

//Imposto - PIS
Local c_PISCST:= 0
Local c_PISvBC:= 0
Local c_PISpPIS:=0
Local c_PISvPIS:=0 

//Imposto - COFINS
Local c_COFCST:= 0
Local c_COFvBC:= 0
Local c_COFpCOF:=0
Local c_COFvCOF:=0 

//Informação adicional do produto
Local c_infAdProd:=""

// Total da nota
Local c_TotvBC:= 0
Local c_TotvICMS:=0
Local c_vICMSDeson:= 0
Local c_TotvFCP:= 0
Local c_TotvBCST:= 0
Local c_TotvST:= 0
Local c_TotvFCPST:= 0
Local c_TotvFCPSTRet:= 0
Local c_TotvProd:= 0
Local c_TotvFrete:= 0
Local c_TotvSeg:= 0
Local c_TotvDesc:= 0
Local c_TotvII:= 0
Local c_TotvIPI:= 0
Local c_TotvIPIDevol:= 0
Local c_TotvPIS:= 0
Local c_TotvCOFINS:= 0
Local c_TotvOutro:= 0
Local c_TotvNF:= 0
Local c_TotvTotTrib:=0  

// Transportadora
Local c_modFrete:= ""
Local c_Tra_CNPJ:= ""
Local c_Tra_xNome:= ""
Local c_Tra_IE:= ""
Local c_Tra_xEnder:= ""
Local c_Tra_xMun:= ""
Local c_Tra_UF:= ""
Local c_Tra_qVol:= 0
Local c_Tra_nVol:= 0
Local c_Tra_pesoL:= 0
Local c_Tra_pesoB:= 0

// Pagamento
Local c_indPag:= ""
Local c_tPag:= ""
Local c_vPag:= 0

Local lMsErroAuto:= .T.
	
// Informações adicionais
Local c_infCpl:="" 

oXML := TXMLManager():New()
cXML := ::eIMPXML

//se for 8859
//-------------------------------------------------------------------
// Parseia o XML.  
//-------------------------------------------------------------------	
//If ( ! Empty( cXML ) .And. ( oXML:Read( cXML,,"ISO-8859-1" ) ) ) 
If !oXML:Parse(cXML)
    //conout( "Errors on Parse!" )
    ::cRetorno := "Errors on Parse!"
Else
	conout( "No Errors on Parse!" )
	//registar o namespace do site	 
	oXml:XPathRegisterNS( "ns", "http://www.portalfiscal.inf.br/nfe" )
	
	//pega a posição de cada tag da identificação da nota. Case sensitive
	c_cUF:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:cUF" )
	c_cNF:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:cNF" )
	c_NatOP:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:natOp" )
	c_Mod:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:mod" )
	c_Serie:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:serie" )
	c_nNF:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:nNF" )
	c_dhEmi:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:dhEmi" )
	//<dhEmi>2019-02-22T20:37:44-03:00</dhEmi>
	c_dhEmi:=SUBST(c_dhEmi,1,4)+SUBST(c_dhEmi,6,2)+SUBST(c_dhEmi,9,2) 
	c_dhSaiEnt:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:dhSaiEnt" )
	c_tpNF:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:tpNF" )
	c_IdDest:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:idDest" )
	c_MunFG:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:cMunFG" )
	c_TpEmis:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:ide/ns:tpEmis" )
	
	//pega a posição de cada tag do emitente. Case sensitive <emit>
	c_CNPJ:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:CNPJ" )
	c_xNome:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:xNome" )
	
	//pega a posição de cada tag do endereço do emitente <enderEmit>. Case sensitive
	c_xLgr:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:enderEmit/ns:xLgr" )
	c_nro:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:enderEmit/ns:nro" )
	c_xCpl:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:enderEmit/ns:xCpl" )
	c_xBairro:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:enderEmit/ns:xBairro" )
	c_cMun:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:enderEmit/ns:cMun" )
	c_xMun:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:enderEmit/ns:xMun" )
	c_UF:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:enderEmit/ns:UF" )
	c_CEP:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:enderEmit/ns:CEP" )
	c_cPais:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:enderEmit/ns:cPais" )
	c_xPais:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:enderEmit/ns:xPais" )
	c_fone:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:emit/ns:enderEmit/ns:fone" )
	
	//pega a quantidade de itens na nota
	aNodes:= oXML:XPathGetChildArray( "/ns:nfeProc/ns:NFe/ns:infNFe")
	nItem:= 0
	For x:= 1 to len(aNodes)
		If aNodes[x][1] =="det"
			nItem++ // quantidade de itens na nota 
		Endif
	Next x
	
	//detalhes dos itens 	
	For z:=1 to nItem
		//quando um grupo se repete no XML, ele é tratado como um array
		cXPath := "/ns:nfeProc/ns:NFe/ns:infNFe/ns:det[" + cValToChar(z) + "]"
		If oXML:XPathHasNode( cXPath )
			
			// Adiciona cada detalhe do produto em aXMLItens
				
			c_Prod:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:cProd")
			c_EAN:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:cEAN")
			c_xProd:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:xProd")
			c_NCM:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:NCM")
			c_CEST:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:CEST")
			c_indEscala:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:indEscala")
			c_CFOP:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:CFOP")
			c_uCOM:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:uCom")
			c_qCOM:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:qCom")
			c_vUnCom:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:vUnCom")
			c_vProd:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:vProd")
			c_cEANTrib:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:cEANTrib")
			c_uTrib:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:uTrib")
			c_qTrib:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:qTrib")
			c_vUnTrib:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:vUnTrib")
			c_vDesc:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:vDesc")
			c_indTot:= oXML:XPathGetNodeValue(cXPath + "/ns:prod/ns:indTot")
			
			//Imposto - ICMS
			c_vTotTrib:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:vTotTrib")
			c_ICMorig:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:ICMS/ns:ICMS60/ns:orig")
			c_ICMCST:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:ICMS/ns:ICMS60/ns:CST")
			c_vBCSTRet:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:ICMS/ns:ICMS60/ns:vBCSTRet")
			c_ICMpST:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:ICMS/ns:ICMS60/ns:pST")
			c_vICMSSTRet:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:ICMS/ns:ICMS60/ns:vICMSSTRet")
			
			//Imposto - PIS
			c_PISCST:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:PIS/ns:PISAliq/ns:CST")
			c_PISvBC:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:PIS/ns:PISAliq/ns:vBC")
			c_PISpPIS:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:PIS/ns:PISAliq/ns:pPIS")
			c_PISvPIS:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:PIS/ns:PISAliq/ns:vPIS")
			
			//Imposto - COFINS
			c_COFCST:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:COFINS/ns:COFINSAliq/ns:CST")
			c_COFvBC:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:COFINS/ns:COFINSAliq/ns:vBC")
			c_COFpCOF:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:COFINS/ns:COFINSAliq/ns:pCOFINS")
			c_COFvCOF:= oXML:XPathGetNodeValue(cXPath + "/ns:imposto/ns:COFINS/ns:COFINSAliq/ns:vCOFINS")
			
			//Informação adicional do produto
			c_infAdProd:= oXML:XPathGetNodeValue(cXPath + "/ns:infAdProd")
			
			//adiciona as variáveis na matriz
			aAuxItens	:={{"c_Prod" 		, c_Prod 		},;
							{"c_EAN" 		, c_EAN	  		},;
							{"c_xProd" 		, c_xProd		},;
							{"c_NCM" 		, c_NCM 		},;
							{"c_CEST" 		, c_CEST 		},;
							{"c_indEscala" 	,c_indEscala	},;
							{"c_CFOP" 		, c_CFOP 		},;
							{"c_uCOM" 		, c_uCOM 		},;
							{"c_qCOM" 		, c_qCOM		},;
							{"c_vUnCom" 	, c_vUnCom 		},;
							{"c_vProd" 		, c_vProd 		},;
							{"c_cEANTrib" 	, c_cEANTrib	},;
							{"c_uTrib" 		, c_uTrib 		},;
							{"c_qTrib" 		, c_qTrib		},;
							{"c_vUnTrib" 	, c_vUnTrib		},;
							{"c_vDesc" 		, c_vDesc		},;
							{"c_indTot" 	, c_indTot		},;
							{"c_vTotTrib" 	, c_vTotTrib	},;
							{"c_ICMorig" 	, c_ICMorig		},;	
							{"c_ICMCST" 	, c_ICMCST		},;
							{"c_vBCSTRet" 	, c_vBCSTRet	},;
							{"c_ICMpST" 	, c_ICMpST		},;
							{"c_vICMSSTRet" , c_vICMSSTRet	},;
							{"c_PISCST" 	, c_PISCST		},;
							{"c_PISvBC" 	, c_PISvBC		},; 
							{"c_PISpPIS" 	, c_PISpPIS		},;
							{"c_PISvPIS" 	, c_PISvPIS		},;
							{"c_COFCST" 	, c_COFCST		},;
							{"c_COFvBC" 	, c_COFvBC		},;
							{"c_COFpCOF"	, c_COFpCOF		},;
							{"c_COFvCOF" 	, c_COFvCOF		},;
							{"c_infAdProd"	, c_infAdProd	}}
			aAdd( aXMLItens, aAuxItens )			
			aAuxItens:={}
		Endif
	Next z
	
	// Total da nota
	//pega a posição de cada tag . Case sensitive
	c_TotvBC:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vBC" )
	c_TotvICMS:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vICMS" )
	c_vICMSDeson:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vICMSDeson" )
	c_TotvFCP:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vFCP" )
	c_TotvBCST:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vBCST" )
	c_TotvST:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vST" )
	c_TotvFCPST:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vFCPST" )
	c_TotvFCPSTRet:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vFCPSTRet" )
	c_TotvProd:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vProd" )
	c_TotvFrete:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vFrete" )
	c_TotvSeg:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vSeg" )
	c_TotvDesc:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vDesc" )
	c_TotvII:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vII" )
	c_TotvIPI:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vIPI" )
	c_TotvIPIDevol:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vIPIDevol" )
	c_TotvPIS:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vPIS" )
	c_TotvCOFINS:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vCOFINS" )
	c_TotvOutro:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vOutro" )
	c_TotvNF:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vNF" )
	c_TotvTotTrib:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:total/ns:ICMSTot/ns:vTotTrib" )
	
	// Transportadora
	//pega a posição de cada tag . Case sensitive
	c_modFrete:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:transp/ns:modFrete")
	c_Tra_CNPJ:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:transp/ns:transporta/ns:CNPJ")
	c_Tra_xNome:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:transp/ns:transporta/ns:xNome")
	c_Tra_IE:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:transp/ns:transporta/ns:IE")
	c_Tra_xEnder:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:transp/ns:transporta/ns:xEnder")
	c_Tra_xMun:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:transp/ns:transporta/ns:xMun")
	c_Tra_UF:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:transp/ns:transporta/ns:UF")
	c_Tra_qVol:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:transp/ns:vol/ns:qVol")
	c_Tra_nVol:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:transp/ns:vol/ns:nVol")
	c_Tra_pesoL:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:transp/ns:vol/ns:pesoL")
	c_Tra_pesoB:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:transp/ns:vol/ns:pesoB")
	
	// Pagamento
	//pega a posição de cada tag . Case sensitive
	c_indPag:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:pag/ns:detPag/ns:indPag")
	c_tPag:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:pag/ns:detPag/ns:tPag")
	c_vPag:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:pag/ns:detPag/ns:vPag")
	
	// Informações adicionais
	//pega a posição de cada tag . Case sensitive
	c_infCpl:= oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:infAdic/ns:infCpl")
	
	//-----------------------------------------------------------
	//gravação da nota fiscal de entrada
	//----------------------------------------------------------
	//dados do cabeçalho da nota
	aCabec	:={{ "F1_FILIAL"  ,	xFilial("SF1")    		,	NIL },;
				{ "F1_TIPO"   ,	"N"						,	NIL },;
				{ "F1_FORMUL" ,	"N"                		,  	NIL },;
				{ "F1_DOC"    ,	strZero(val(c_nNF),9) 	,	NIL },;
				{ "F1_SERIE"  ,	c_Serie            		,	NIL },;
				{ "F1_EMISSAO",	STOD(c_dhEmi)			,	NIL },;
				{ "F1_FORNECE",	"000001"				,	NIL },;
				{ "F1_LOJA"   ,	"01"		  			,	NIL },;
				{ "F1_COND"   ,	'BON' 					,	NIL },;
				{ "F1_EST"    ,	c_UF   					,	NIL },;
				{ "F1_ESPECIE",	"NFE"          			,	NIL }}
	
	//dados dos itens da nota
	For y:= 1 to len(aXMLItens)
		aLinha	:={{ "D1_FILIAL"	,xFilial("SD1")			 ,	NIL },;
					{ "D1_COD"		,aXMLItens[y][1][2]		 ,	NIL },;
					{ "D1_DOC"		,strZero(val(c_nNF),9)	 ,	NIL },;
					{ "D1_SERIE"	,c_Serie				 ,	NIL },;
					{ "D1_FORNECE"	,"000001"				 ,	NIL },;
					{ "D1_LOJA"		,"01"					 ,	NIL },;
					{ "D1_ITEM"		,StrZero(y,2)			 ,	NIL },;
					{ "D1_QUANT"	,Val(aXMLItens[y][9][2]) ,	NIL },;
					{ "D1_VUNIT"	,Val(aXMLItens[y][10][2]),	NIL },;
					{ "D1_TOTAL"	,Val(aXMLItens[y][9][2])*Val(aXMLItens[y][10][2]),	NIL },;
					{ "D1_CLASFIS"	,						 ,   NIL },;
					{ "D1_CONTA"	,						 ,   NIL },;
					{ "D1_CC"		,						 ,   NIL },;
					{ "D1_TES"		,						 ,	NIL } }
					aAdd( aItens, aLinha )
		aLinha:={}
	Next Y
	
	//-------------------------------------------------------------
	//execauto para gravar a nota fiscal de entrada
	//-------------------------------------------------------------
	Begin Transaction
	//MSExecAuto({|x, y, z| MATA103(x, y, z)}, aCabec, aItens, 3)
	MSExecAuto({|x, y, z| MATA140(x, y, z)}, aCabec, aItens, 3) //pré-nota de entrada
	If lMsErroAuto
		//DisarmTransaction()
		::cRetorno := "Importação finalizada:" + MostraErro()
		conout(MostraErro())
	Else
		::cRetorno := "SUCESSO ! Importação finalizada com sucesso !"
	EndIf

	End Transaction   
Endif

		 
Return .T.