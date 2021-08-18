
#include 'protheus.ch'
#include 'parmtype.ch'

User Function MT103FIM()
Local aAreaSF1   := SF1->(GetArea())
Local aAreaSA2   := SA2->(GetArea())
Local aAreaSA1   := SA1->(GetArea())
Local cFilOrig	 := SuperGetMV("TR_FILORIG",,'02')
Local _nOpcao 	 := PARAMIXB[1]
Local _nConfirma := PARAMIXB[2]
Local cAliasTRB	 := ''

//projeto compras - candisani - 28/04/21
Local nPosProd  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD" })
Local nPosQtde  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_QUANT" })
Local nPosPc    := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_PEDIDO"})
Local nPosItPc  := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_ITEMPC"})
Local nPosD1It  := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_ITEM"})
Local nPosDoc   := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_DOC"})
Local nPosSer   := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_SERIE"})
Local n := 0
Local cD1Prod:= ""
Local nD1Quant := 0 // quantidade pre nota
Local cPedCom  := "" // numero do pedido de compra
Local cItemPC  := "" // item do pedido de compra
Local cFornece := "" 
Local cLoja    := "" 
Local tmpPedCom:= ""
Local nC7Quant := 0
Local nC7QuJe  :=  0
Local cD1Item  := ""
Local cDocSD1  := ""
Local cSerSD1  := ""
Local nResult  := 0
Local cRaizCod := "" //raiz código do produto Trocafone
Local lTrocaCod:= .F.
Local aSC7Ped  := {}

If (_nOpcao == 3 .Or. _nOpcao == 4) .And. IsInCallStack("MATA103") .And. !Empty(SF1->F1_XNUMPED) .And. _nConfirma == 1

		If IsInCallStack("U_WSNFTRANSF")
			dbSelectArea("ZF3")
			ZF3->(dbSetOrder(1))				
			If ZF3->(dbSeek(cFilOrig+SF1->F1_XNUMPED))
				RecLock("ZF3",.F.)
				ZF3->ZF3_LOGERR  := ""
				ZF3->ZF3_STATUS := "C"
				ZF3->(MsUnlock())
			EndIf 

		ElseIf IsInCallStack("U_XFAT001") .Or. IsInCallStack("U_XFAT011") .Or. IsInCallStack("U_XFAT002")

			cAliasTRB := GetNextAlias()

			cQuery := " SELECT R_E_C_N_O_ RECSE2 FROM " + RetSqlName("SE2")
			cQuery += " WHERE E2_FILIAL	 = '" + xFilial("SE2") +"' "
			cQuery += " AND	  E2_NUM     = '" + SF1->F1_DOC + "' "
			cQuery += " AND	  E2_PREFIXO = '" + SF1->F1_SERIE + "' "
			cQuery += " AND	  E2_FORNECE = '" + SF1->F1_FORNECE + "' "
			cQuery += " AND	  E2_LOJA	 = '" + SF1->F1_LOJA + "' AND E2_BAIXA = '' "
			cQuery += " AND	  D_E_L_E_T_ = '' "
			DBUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), (cAliasTRB), .F., .T.)

			(cAliasTRB)->(DBSelectArea(cAliasTRB))
			(cAliasTRB)->(DBGoTop())
			While !(cAliasTRB)->(EOF())

				dbSelectArea("SE2")
				dbGoto((cAliasTRB)->RECSE2)			

				RecLock("SE2",.F.)
				SE2->E2_XNUMPED := SF1->F1_XNUMPED
				MsUnlock()

				(cAliasTRB)->(dbSkip())
			Enddo

			If !Empty(ZF2->ZF2_CGCLOJ)

				(cAliasTRB)->(dbGoTop())


				While !(cAliasTRB)->(Eof())

					dbSelectArea("SE2")
					dbGoto((cAliasTRB)->RECSE2)			

					dbSelectArea("ZF2")
					ZF2->(dbSetOrder(1))
					If ZF2->(dbSeek(xFilial("ZF2")+SF1->F1_XNUMPED))

						//--> Essa tabela relaciona o CNPJ que está na planilha 8 digitos e 
						//--> disponibilza o cnpj que será gerado os títulos
						dbSelectArea("ZF4")
						ZF4->(dbSetOrder(1))
						If ZF4->(dbSeek(xFilial("ZF4")+SubStr(ZF2->ZF2_CGCLOJ,1,8)))

							dbSelectArea("SA2")
							SA2->(dbSetOrder(3))
							If SA2->(dbSeek(xFilial("SA2")+ZF4->ZF4_MCNPJ))

								aBaixa := {}
								AADD(aBaixa, {"E2_FILIAL" 	, SE2->E2_FILIAL 			, 	Nil})
								AADD(aBaixa, {"E2_PREFIXO" 	, SE2->E2_PREFIXO 			, 	Nil})
								AADD(aBaixa, {"E2_NUM" 		, SE2->E2_NUM 				, 	Nil})
								AADD(aBaixa, {"E2_PARCELA" 	, SE2->E2_PARCELA			, 	Nil})
								AADD(aBaixa, {"E2_TIPO" 	, SE2->E2_TIPO 				, 	Nil})
								AADD(aBaixa, {"E2_FORNECE" 	, SE2->E2_FORNECE 			, 	Nil})
								AADD(aBaixa, {"E2_LOJA" 	, SE2->E2_LOJA 				, 	Nil}) 
								AADD(aBaixa, {"AUTMOTBX" 	, "LIQ"						, 	Nil})
								AADD(aBaixa, {"AUTBANCO"    , "." 	             		,	Nil})
								AADD(aBaixa, {"AUTAGENCIA"  , "." 	             		,	Nil})
								AADD(aBaixa, {"AUTCONTA"   	, "." 	             		,	Nil})
								AADD(aBaixa, {"AUTDTBAIXA" 	, dDataBase 				, 	Nil}) 
								AADD(aBaixa, {"AUTDTCREDITO", dDataBase 				, 	Nil})
								AADD(aBaixa, {"AUTHIST" 	, 0		 					, 	Nil})
								AADD(aBaixa, {"AUTVLRPG" 	, SE2->E2_SALDO 			, 	Nil})

								lMsErroAuto := .F.

								MSExecAuto({|x,y| FINA080(x,y)}, aBaixa, 3)

								If lMsErroAuto

									cMsg := ""

									If file(GetSrvProfString("Startpath","")+cArqErro)
										Ferase(GetSrvProfString("Startpath","")+cArqErro)
									EndIf	

									MostraErro( GetSrvProfString("Startpath","") , cArqErro )
									cMsg := MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro )

									If file(GetSrvProfString("Startpath","")+cArqErro)
										Ferase(GetSrvProfString("Startpath","")+cArqErro)
									EndIf	

									dbSelectArea("ZF2")
									ZF2->(dbSetOrder(1))
									If ZF2->(dbSeek(xFilial("ZF2")+SF1->F1_XNUMPED))
										RecLock("ZF2",.F.)
										ZF2->ZF2_LOGERR  := cMsg
										ZF2->ZF2_STATUS := "B"
										ZF2->(MsUnlock())
									EndIf 

									Exit													

								Else

									ConOut(OEMToANSI("Titulo Baixado : "+SE2->E2_NUM+" Prefixo "+SE2->E2_PREFIXO+" PARCELA "+ SE2->E2_PARCELA ))

									//-> Necessário reposicionar pois na operação anterior desposicionou o fornecedor
									dbSelectArea("SA2")
									SA2->(dbSetOrder(3))
									If SA2->(dbSeek(xFilial("SA2")+ZF4->ZF4_MCNPJ))

										aDados   := {	{"E2_PREFIXO"	,SE2->E2_PREFIXO	,	Nil}	,;
										{"E2_NUM"		,SE2->E2_NUM		,	Nil}	,;
										{"E2_PARCELA"	,SE2->E2_PARCELA	,	Nil}	,;
										{"E2_TIPO"		,SE2->E2_TIPO		,	Nil}	,;			
										{"E2_NATUREZ"	,SE2->E2_NATUREZ	,	Nil}	,;
										{"E2_FORNECE"	,SA2->A2_COD		,	Nil}	,; 
										{"E2_LOJA"		,SA2->A2_LOJA		,	Nil}	,;      
										{"E2_EMISSAO"	,SE2->E2_EMISSAO	,	Nil}	,;
										{"E2_VENCTO"	,SE2->E2_VENCTO		,	Nil}	,;					 
										{"E2_VENCREA"	,SE2->E2_VENCREA	,	Nil}	,;					 					
										{"E2_XNUMPED"	,SE2->E2_XNUMPED	,	Nil}	,;					 														
										{"E2_VALOR"		,SE2->E2_VALOR		,	Nil}}					

										//{"E2_FORNECE"	,cFornNovo			,	Nil}	,; 
										//{"E2_LOJA"		,cLojaNovo			,	Nil}	,;      

										lMsErroAuto := .F.

										MSExecAuto({|x,y,z| Fina050(x,y,z)},aDados,,3) //Inclusao

										If lMsErroAuto

											cMensagem := "Erro ao Criar Título a Pagar."
											cMensagem += MostraErro()

										Else

											ConOut(OEMToANSI("Titulo Criado : "+SE2->E2_NUM+" Prefixo "+SE2->E2_PREFIXO+" PARCELA "+ SE2->E2_PARCELA ))

										Endif

									Endif

								Endif
							
							Endif
						
						Else
                                dbSelectArea("ZF2")
								ZF2->(dbSetOrder(1))
								If ZF2->(dbSeek(xFilial("ZF2")+SF1->F1_XNUMPED))
									RecLock("ZF2",.F.)
									ZF2->ZF2_LOGERR  := "CNPJ do Parceiro Não Preenchido no De x Para. Favor Revisar a planilha. CNPJ Preenchido : "+ ZF2->ZF2_CGCLOJ
									ZF2->ZF2_STATUS := "B"
									ZF2->(MsUnlock())
								EndIf                                          
                        Endif
						
					EndIF				
					(cAliasTRB)->(dbSkip())
				Enddo 
			Endif
			(cAliasTRB)->(dbCloseArea())
		Endif			

ElseIf _nOpcao == 5  .And. IsInCallStack("MATA140") .And. !Empty(SF1->F1_XNUMPED) .And. _nConfirma == 1

	// Se Remover a Classificação, volto o Status no monitor para Pendente de Classificação

	dbSelectArea("ZF2")
	ZF2->(dbSetOrder(1))				
	If ZF2->(dbSeek(cFilOrig+SF1->F1_XNUMPED))
		RecLock("ZF2",.F.)
		ZF2->ZF2_LOGERR  := ""
		ZF2->ZF2_STATUS := "I"
		ZF2->(MsUnlock())
	EndIf
ElseIf _nOpcao == 4  .And. IsInCallStack("MATA103") .And. _nConfirma == 1 //candisani - projeto compras - 28/04/21
		cFornece := SF1->F1_FORNECE 
		cLoja    := SF1->F1_LOJA 

		//verificar se cada item da pre nota tem um pedido de compra amarrado
		LjMsgRun("Atualizando pedidos de compras...Aguarde...")
		
	For n := 1 To Len(aCols)
		If !aCols[n,Len(aHeader)+1]
			cD1Prod  := aCols[n,nPosProd]
			cD1Item  := aCols[n,nPosD1It]
			nD1Quant := aCols[n,nPosQtde]
			cPedCom  := aCols[n,nPosPc]
			cItemPC  := aCols[n,nPosItPc]
			cDocSD1  := aCols[n,nPosDoc]
			cSerSD1  := aCols[n,nPosSer]

			If Empty(cPedCom) //por enquanto somente para itens sem pedidos de compra amarrados - candisani - 28/04/21  
				//verificar amarracao produto X fornecedor

				//se existir o codigo 
				
				// buscar os pedidos de compras em aberto por ordem de abertura 
				tmpPedCom:= GetNextAlias()	
				BeginSql Alias tmpPedCom 
					SELECT *  
					FROM %table:SC7% SC7
					Where SC7.C7_FILIAL = %xFilial:SC7% AND
						SC7.C7_PRODUTO = %Exp:cD1Prod% AND
						SC7.C7_FORNECE = %Exp:cFornece% AND
						SC7.C7_LOJA = %Exp:cLoja% AND
						SC7.C7_QUANT <> SC7.C7_QUJE AND 
						SC7.%NotDel% 
					Order By C7_DINICOM,C7_PRODUTO
				EndSql 

				//getlastquery()
				DbSelectArea(tmpPedCom)
				While (tmpPedCom)->(!EOF())
					nResult = nResult + 1
					nC7Quant := (tmpPedCom)->C7_QUANT
					nC7QuJe :=  (tmpPedCom)->C7_QUJE
					If (nC7Quant - nC7QuJe ) >=  nD1Quant 
						cPedCom := (tmpPedCom)->C7_NUM
						cItemPC := (tmpPedCom)->C7_ITEM
						Exit
					Else
						cPedCom := ""
						cItemPC := ""		
					Endif
					(tmpPedCom)->(DbSkip())
				Enddo

				// se nao existir o codigo verificar a raiz do codigo nAT(-) - candisani
				If nResult = 0
				    //SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1)
					cRaizCod := SubStr(cD1Prod,1,AT("-",cD1Prod)-1)
					//alert(cRaizCod)
					tmpPedCom:= GetNextAlias()	
					BeginSql Alias tmpPedCom 
						SELECT *  
						FROM %table:SC7% SC7
						Where SC7.C7_FILIAL = %xFilial:SC7% AND
							SC7.C7_PRODUTO = %Exp:cRaizCod% AND
							SC7.C7_FORNECE = %Exp:cFornece% AND
							SC7.C7_LOJA = %Exp:cLoja% AND
							SC7.C7_QUANT <> SC7.C7_QUJE AND
							SC7.%NotDel% 
						Order By C7_DINICOM,C7_PRODUTO
					EndSql 


					//getlastquery()
					DbSelectArea(tmpPedCom)
					While (tmpPedCom)->(!EOF())
						nC7Quant := (tmpPedCom)->C7_QUANT
						nC7QuJe :=  (tmpPedCom)->C7_QUJE
						If (nC7Quant - nC7QuJe ) >=  nD1Quant 
							cPedCom := (tmpPedCom)->C7_NUM
							cItemPC := (tmpPedCom)->C7_ITEM
							lTrocaCod := .T.
							Exit
						Else
							cPedCom := ""
							cItemPC := ""		
						Endif
						(tmpPedCom)->(DbSkip())
					Enddo
				Endif

				If !Empty(cPedCom)
					//alert(cPedCom)
					DbSelectArea("SD1")
					SD1->(DbSetOrder(1)) //FILIAL+DOC+SERIE+FORNECE+LOJA+COD+ITEM
					//If lTrocaCod
					If SD1->(dbSeek(xFilial("SD1")+cDocSD1+cSerSD1+cFornece+cLoja+cD1Prod+cD1Item))
						Reclock("SD1",.F.)
						Replace SD1->D1_PEDIDO with cPedCom
						Replace SD1->D1_ITEMPC with cItemPC
						SD1->(MsUnlock())
					Endif	
					//atualizar pedido de compras
					DbSelectArea("SC7")
					SC7->(DbSetOrder(1))
					If SC7->(dbSeek(xFilial("SC7")+cPedCom+cItemPC))
						nC7QuJe:= SC7->C7_QUJE
						Reclock("SC7",.F.)
						If lTrocaCod
							Replace SC7->C7_PRODUTO with cD1Prod
						Endif	
							Replace SC7->C7_QUJE with nC7QuJe + nD1Quant 
							SC7->(MsUnlock())
						Endif
				Endif	
			Endif
		Endif
		//zera as variaveis
		nC7Quant := 0
		nC7QuJe  := 0
		nResult  := 0
	Next n
Endif
	
	If(_nOpcao == 3 .Or. _nOpcao == 4)
		IF  SF1->F1_TIPO $ "D.B"
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
				RecLock("SF1",.F.)
				SF1->F1_XNOME := SA1->A1_NOME
				SF1->(MsUnlock())
			EndIf
		else
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
				RecLock("SF1",.F.)
				SF1->F1_XNOME := SA2->A2_NOME
				SF1->(MsUnlock())
			EndIf
		EndIf
		
	EndIf

	RestArea(aAreaSF1)
	RestArea(aAreaSA2)
	RestArea(aAreaSA1)

Return
