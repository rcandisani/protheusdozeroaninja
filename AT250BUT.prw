#Include "rwmake.ch" 
#Include "totvs.ch"
#Include "topconn.ch"
#INCLUDE "FWMVCDEF.CH"

#Define CRLF	Chr(13)+Chr(10)


User Function AT250BUT()

Local aArea		:=GetArea()
Local aButtons 	:=  {} // PARAMIXB[1]

aAdd(aButtons , {"Aponta Período",{||U_ApontaPer()} , OemToAnsi("Aponta Período" ),OemToAnsi("Aponta Período")})
aAdd(aButtons , {"Consulta Saldos",{||U_ConsSaldo(AAM_CONTRT)} , OemToAnsi("Consulta Saldos" ),OemToAnsi("Consulta Saldos")})

RestArea(aArea)

Return(aButtons)


User function ConsSaldo(cConTrt)

Local lRet:= .F. 

//posicionar e pegar os dados da AAM
DbSelectArea("AAM")
AAM->(DbSetOrder(1))
If AAM->(DbSeek(xFilial("AAM")+cConTrt))
	lRet := .T.
    FWExecView("Contrato Servicos","GPO101P",MODEL_OPERATION_UPDATE,/*oDlg*/,{||.T.},/*bOk*/,0,/*aEnableButtons*/,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,/*oModelCal*/) //"Incluir Calendário MRP"
Endif

Return lRet
