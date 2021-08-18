#Include "rwmake.ch" 
#Include "totvs.ch"
#Include "topconn.ch"
#INCLUDE "FWMVCDEF.CH"

User Function A103CLAS()

Local aArea		:=GetArea()

//projeto compras - candisani - 28/04/21
Local nPosProd  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD" })
Local nPosQtde  := aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_QUANT" })
Local nPosPc    := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_PEDIDO"})
Local nPosItPc  := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_ITEMPC"})
Local nPosD1It  := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_ITEM"})
Local nPosDoc   := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_DOC"})
Local nPosSer   := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_SERIE"})
Local nPosTES   := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_TES"})
Local nPosVUnit := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_VUNIT"})
Local nPosTotal := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_TOTAL"})
Local x         := 0
Local cD1Prod   := ""
Local nD1Quant  := 0 // quantidade pre nota
Local cPedCom   := "" // numero do pedido de compra
Local cItemPC   := "" // item do pedido de compra
Local cFornece  := "" 
Local cLoja     := "" 
Local tmpPedCom := ""
Local nC7Quant  := 0
Local nC7QuJe   := 0
Local cD1Item   := ""
Local cDocSD1   := ""
Local cSerSD1   := ""
Local nResult   := 0
Local cRaizCod  := "" //raiz código do produto Trocafone
Local lTrocaCod := .F.
Local aTemp     := {}
Local nSaldoSD1 := 0 
Local nY        := 0
Local nCont     := 0
Local nX        := 0

cFornece := SF1->F1_FORNECE 
cLoja    := SF1->F1_LOJA 

		//verificar se cada item da pre nota tem um pedido de compra amarrado
		    	
	For X := 1 To Len(aCols)
		If !aCols[X,Len(aHeader)+1]
			cD1Prod  := aCols[X,nPosProd]
			cD1Item  := aCols[X,nPosD1It]
			nD1Quant := aCols[X,nPosQtde]
			cPedCom  := aCols[X,nPosPc]
			cItemPC  := aCols[X,nPosItPc]
			cDocSD1  := aCols[X,nPosDoc]
			cSerSD1  := aCols[X,nPosSer]

            nSaldoSD1 := nD1Quant
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
				//adicionar no array até completar o saldo do item
				DbSelectArea(tmpPedCom)
				nCont    := X
				While (tmpPedCom)->(!EOF())
					  
					nResult  := nResult + 1
					nC7Quant := (tmpPedCom)->C7_QUANT 
					nC7QuJe  :=  (tmpPedCom)->C7_QUJE
					nSaldoSC7:= nC7Quant - nC7QuJe
					If nSaldoSC7 > 0 
						cPedCom := (tmpPedCom)->C7_NUM
						cItemPC := (tmpPedCom)->C7_ITEM
						
						//atualiza o Acols
						If nSaldoSC7 > nSaldoSD1
							aCols[nCont,nPosQtde]:= nSaldoSD1
						Else	
							aCols[nCont,nPosQtde]:= nSaldoSC7
						Endif
						
						aCols[nCont,nPosD1It] := StrZero(nCont,Len(SD1->D1_ITEM)) 
						aCols[nCont,nPosPc]   := cPedCom
						aCols[nCont,nPosItPc] := cItemPC
						aCols[nCont,nPosTotal]:= aCols[nCont,nPosQtde] * aCols[nCont,nPosVUnit] 
															
						//verifica se existe ainda Saldo do item a Classificar	
						If nSaldoSD1 - nSaldoSC7 <= 0
							Exit
						Else
							// Duplica aCols
							aTemp := aClone(aCols)
							aAdd(aCols, aTemp[x])
							aCols[Len(aCols),1] := StrZero(Len(aCols),2)

						Endif
						
					Else
						cPedCom := ""
						cItemPC := ""		
					Endif
				nSaldoSD1 := nSaldoSD1 - nSaldoSC7
				nCont    := nCont + 1
				(tmpPedCom)->(DbSkip())
			Enddo
			//zera as variáveis
			nCont := 0
			cPedCom := ""
			cItemPC := ""
            Endif     
        Endif
	Next X

For nX := 1 to Len(aCols) // Roda todos os Itens do Pedido de Compras 
	MaFisIniLoad(nX,,.T.)  // nX representa o Item do aCols lido dentro do laço e acrescenta o item em branco no aNFItem MATXFIS.
	For nY := 1 To Len(aHeader) // Roda todos os campos do aCols através do aHeader para carregar cada um para o aNFItem
		cValid:= AllTrim(UPPER(aHeader[nY][6]))
		cRefCols := MaFisGetRf(cValid)[1] // Armazena a referencia fiscal do campo na variavel cRefCols
		If !Empty(cRefCols) .And. MaFisFound("IT",nX) // Verificaa existência do Item no aNFItem da MATXFIS
			MaFisLoad(cRefCols,aCols[nX][nY],nX) // Carrega o valor do campo do aCols para a referencia no aNfItem da MATXFIS
		EndIf
	Next nY
	MaFisEndLoad( nX , 2 )  //  Encerra a carga do Item
Next nX
//Atualiza os campos fiscais
MaFisLoad("IT_TES",aCols[Len(aCols)][nPosTES],Len(aCols))
MaFisAlt("IT_TES",aCols[Len(aCols)][nPosTES],Len(aCols))
MaFisToCols(aHeader,aCols,Len(aCols),"MT100")
If ExistTrigger("D1_TES")
	RunTrigger(2,Len(aCols),,"D1_TES")
EndIf

Return
