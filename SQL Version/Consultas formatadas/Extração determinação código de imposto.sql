select 
	CASE WHEN T0.TcdId = 1 THEN 'Material'
		 WHEN T0.TcdId = 2 THEN 'Serviço'
		 WHEN T0.TcdId = 3 THEN 'Documento de serviço'
		 WHEN T0.TcdId = 4 THEN 'Impostos retidos' end 'Tipo de determinação',
	Descr 'Descrição da determinação',
	CASE WHEN T0.KeyFld_1 = 1 THEN 'Parceiro de negócios'	
		 WHEN T0.KeyFld_1 = 2 THEN 'Item'
		 WHEN T0.KeyFld_1 = 3 THEN 'Grupo de materiais'
		 WHEN T0.KeyFld_1 = 4 THEN 'Grupo de serviço'
		 WHEN T0.KeyFld_1 = 5 THEN 'Código NCM'
		 WHEN T0.KeyFld_1 = 6 THEN 'Estado'
		 WHEN T0.KeyFld_1 = 7 THEN 'Município'
		 WHEN T0.KeyFld_1 = 8 THEN 'Código do serviço'
		 WHEN T0.KeyFld_1 = 9 THEN 'Grupo de itens'
		 WHEN T0.KeyFld_1 = 10 THEN 'Conta contábil'
		 WHEN T0.KeyFld_1 = 11 THEN 'Grupo cliente'
		 WHEN T0.KeyFld_1 = 16 THEN 'Filial'
		 WHEN T0.KeyFld_1 = 17 THEN t0.UDFAlias_1
		 WHEN T0.KeyFld_1 = 25 THEN 'Tipo tributário da empresa'
		 WHEN T0.KeyFld_1 = 26 THEN 'Tipo tributário do PN'
		 WHEN T0.KeyFld_1 = 27 THEN 'Grupo de estado'
		 WHEN T0.KeyFld_1 = 28 THEN 'Grupo de código de origem do produto'
		 WHEN T0.KeyFld_1 = 29 THEN 'Grupo de código NCM'  END 'Campo-chave 1',
	CASE WHEN T0.KeyFld_1 IN (1,2,6,10,17) THEN T1.KeyFld_1_V
		 WHEN T0.KeyFld_1 = 3 THEN (SELECT TA.MatGrp FROM OMGP TA WHERE TA.AbsEntry =  T1.KeyFld_1_V)
		 WHEN T0.KeyFld_1 = 4 THEN (SELECT TA.ServiceGrp FROM OSGP TA WHERE TA.AbsEntry = T1.KeyFld_1_V)
		 WHEN T0.KeyFld_1 = 5 THEN (SELECT TA.NcmCode FROM ONCM TA WHERE TA.AbsEntry = T1.KeyFld_1_V)
		 WHEN T0.KeyFld_1 = 7 THEN (SELECT TA.Name FROM OCNT TA WHERE TA.Code = T1.KeyFld_1_V)
		 WHEN T0.KeyFld_1 = 8 THEN (SELECT TA.ServiceCD FROM OSCD TA WHERE TA.AbsEntry = T1.KeyFld_1_V)
		 WHEN T0.KeyFld_1 = 9 THEN (SELECT TA.ItmsGrpNam FROM OITB TA WHERE TA.ItmsGrpCod = T1.KeyFld_1_V)
		 WHEN T0.KeyFld_1 = 11 THEN (SELECT TA.GroupName FROM OCRG TA WHERE TA.GroupCode = T1.KeyFld_1_V)
		 WHEN T0.KeyFld_1 = 16 THEN (select ta.BPLName from OBPL ta where ta.BPLId = t1.KeyFld_1_V)
		 WHEN T0.KeyFld_1 IN (25,26) THEN (SELECT TA.Descr FROM OBNI TA WHERE TA.ID = T1.KeyFld_1_V)
		 WHEN T0.KeyFld_1 = 27 THEN (SELECT TA.GroupName FROM OSTG TA WHERE TA.GroupCode = T1.KeyFld_1_V)
		 WHEN T0.KeyFld_1 = 28 THEN (SELECT TA.GroupName FROM OPSG TA WHERE TA.GroupCode = T1.KeyFld_1_V)
		 WHEN T0.KeyFld_1 = 29 THEN (SELECT TA.GroupName FROM ONCG TA WHERE TA.GroupCode = T1.KeyFld_1_V)  END 'Valor do campo-chave 1',
	CASE WHEN T0.KeyFld_2 = 1 THEN 'Parceiro de negócios'	
		 WHEN T0.KeyFld_2 = 2 THEN 'Item'
		 WHEN T0.KeyFld_2 = 3 THEN 'Grupo de materiais'
		 WHEN T0.KeyFld_2 = 4 THEN 'Grupo de serviço'
		 WHEN T0.KeyFld_2 = 5 THEN 'Código NCM'
		 WHEN T0.KeyFld_2 = 6 THEN 'Estado'
		 WHEN T0.KeyFld_2 = 7 THEN 'Município'
		 WHEN T0.KeyFld_2 = 8 THEN 'Código do serviço'
		 WHEN T0.KeyFld_2 = 9 THEN 'Grupo de itens'
		 WHEN T0.KeyFld_2 = 10 THEN 'Conta contábil'
		 WHEN T0.KeyFld_2 = 11 THEN 'Grupo cliente'
		 WHEN T0.KeyFld_2 = 16 THEN 'Filial'
		 WHEN T0.KeyFld_2 = 17 THEN t0.UDFAlias_2
		 WHEN T0.KeyFld_2 = 25 THEN 'Tipo tributário da empresa'
		 WHEN T0.KeyFld_2 = 26 THEN 'Tipo tributário do PN'
		 WHEN T0.KeyFld_2 = 27 THEN 'Grupo de estado'
		 WHEN T0.KeyFld_2 = 28 THEN 'Grupo de código de origem do produto'
		 WHEN T0.KeyFld_2 = 29 THEN 'Grupo de código NCM'  END 'Campo-chave 2',
	CASE WHEN T0.KeyFld_2 IN (1,2,6,10,17) THEN T1.KeyFld_2_V
		 WHEN T0.KeyFld_2 = 3 THEN (SELECT TA.MatGrp FROM OMGP TA WHERE TA.AbsEntry =  T1.KeyFld_2_V)
		 WHEN T0.KeyFld_2 = 4 THEN (SELECT TA.ServiceGrp FROM OSGP TA WHERE TA.AbsEntry = T1.KeyFld_2_V)
		 WHEN T0.KeyFld_2 = 5 THEN (SELECT TA.NcmCode FROM ONCM TA WHERE TA.AbsEntry = T1.KeyFld_2_V)
		 WHEN T0.KeyFld_2 = 7 THEN (SELECT TA.Name FROM OCNT TA WHERE TA.Code = T1.KeyFld_2_V)
		 WHEN T0.KeyFld_2 = 8 THEN (SELECT TA.ServiceCD FROM OSCD TA WHERE TA.AbsEntry = T1.KeyFld_2_V)
		 WHEN T0.KeyFld_2 = 9 THEN (SELECT TA.ItmsGrpNam FROM OITB TA WHERE TA.ItmsGrpCod = T1.KeyFld_2_V)
		 WHEN T0.KeyFld_2 = 11 THEN (SELECT TA.GroupName FROM OCRG TA WHERE TA.GroupCode = T1.KeyFld_2_V)
		 WHEN T0.KeyFld_2 = 16 THEN (select ta.BPLName from OBPL ta where ta.BPLId = t1.KeyFld_2_V)
		 WHEN T0.KeyFld_2 IN (25,26) THEN (SELECT TA.Descr FROM OBNI TA WHERE TA.ID = T1.KeyFld_2_V)
		 WHEN T0.KeyFld_2 = 27 THEN (SELECT TA.GroupName FROM OSTG TA WHERE TA.GroupCode = T1.KeyFld_2_V)
		 WHEN T0.KeyFld_2 = 28 THEN (SELECT TA.GroupName FROM OPSG TA WHERE TA.GroupCode = T1.KeyFld_2_V)
		 WHEN T0.KeyFld_2 = 29 THEN (SELECT TA.GroupName FROM ONCG TA WHERE TA.GroupCode = T1.KeyFld_2_V)  END 'Valor do campo-chave 2',
	CASE WHEN T0.KeyFld_3 = 1 THEN 'Parceiro de negócios'	
		 WHEN T0.KeyFld_3 = 2 THEN 'Item'
		 WHEN T0.KeyFld_3 = 3 THEN 'Grupo de materiais'
		 WHEN T0.KeyFld_3 = 4 THEN 'Grupo de serviço'
		 WHEN T0.KeyFld_3 = 5 THEN 'Código NCM'
		 WHEN T0.KeyFld_3 = 6 THEN 'Estado'
		 WHEN T0.KeyFld_3 = 7 THEN 'Município'
		 WHEN T0.KeyFld_3 = 8 THEN 'Código do serviço'
		 WHEN T0.KeyFld_3 = 9 THEN 'Grupo de itens'
		 WHEN T0.KeyFld_3 = 10 THEN 'Conta contábil'
		 WHEN T0.KeyFld_3 = 11 THEN 'Grupo cliente'
		 WHEN T0.KeyFld_3 = 16 THEN 'Filial'
		 WHEN T0.KeyFld_3 = 17 THEN t0.UDFAlias_3
		 WHEN T0.KeyFld_3 = 25 THEN 'Tipo tributário da empresa'
		 WHEN T0.KeyFld_3 = 26 THEN 'Tipo tributário do PN'
		 WHEN T0.KeyFld_3 = 27 THEN 'Grupo de estado'
		 WHEN T0.KeyFld_3 = 28 THEN 'Grupo de código de origem do produto'
		 WHEN T0.KeyFld_3 = 29 THEN 'Grupo de código NCM'  END 'Campo-chave 3',
	CASE WHEN T0.KeyFld_3 IN (1,2,6,10,17) THEN T1.KeyFld_3_V
		 WHEN T0.KeyFld_3 = 3 THEN (SELECT TA.MatGrp FROM OMGP TA WHERE TA.AbsEntry =  T1.KeyFld_3_V)
		 WHEN T0.KeyFld_3 = 4 THEN (SELECT TA.ServiceGrp FROM OSGP TA WHERE TA.AbsEntry = T1.KeyFld_3_V)
		 WHEN T0.KeyFld_3 = 5 THEN (SELECT TA.NcmCode FROM ONCM TA WHERE TA.AbsEntry = T1.KeyFld_3_V)
		 WHEN T0.KeyFld_3 = 7 THEN (SELECT TA.Name FROM OCNT TA WHERE TA.Code = T1.KeyFld_3_V)
		 WHEN T0.KeyFld_3 = 8 THEN (SELECT TA.ServiceCD FROM OSCD TA WHERE TA.AbsEntry = T1.KeyFld_3_V)
		 WHEN T0.KeyFld_3 = 9 THEN (SELECT TA.ItmsGrpNam FROM OITB TA WHERE TA.ItmsGrpCod = T1.KeyFld_3_V)
		 WHEN T0.KeyFld_3 = 11 THEN (SELECT TA.GroupName FROM OCRG TA WHERE TA.GroupCode = T1.KeyFld_3_V)
		 WHEN T0.KeyFld_3 = 16 THEN (select ta.BPLName from OBPL ta where ta.BPLId = t1.KeyFld_3_V)
		 WHEN T0.KeyFld_3 IN (25,26) THEN (SELECT TA.Descr FROM OBNI TA WHERE TA.ID = T1.KeyFld_3_V)
		 WHEN T0.KeyFld_3 = 27 THEN (SELECT TA.GroupName FROM OSTG TA WHERE TA.GroupCode = T1.KeyFld_3_V)
		 WHEN T0.KeyFld_3 = 28 THEN (SELECT TA.GroupName FROM OPSG TA WHERE TA.GroupCode = T1.KeyFld_3_V)
		 WHEN T0.KeyFld_3 = 29 THEN (SELECT TA.GroupName FROM ONCG TA WHERE TA.GroupCode = T1.KeyFld_3_V)  END 'Valor do campo-chave 3',
	CASE WHEN T0.KeyFld_4 = 1 THEN 'Parceiro de negócios'	
		 WHEN T0.KeyFld_4 = 2 THEN 'Item'
		 WHEN T0.KeyFld_4 = 3 THEN 'Grupo de materiais'
		 WHEN T0.KeyFld_4 = 4 THEN 'Grupo de serviço'
		 WHEN T0.KeyFld_4 = 5 THEN 'Código NCM'
		 WHEN T0.KeyFld_4 = 6 THEN 'Estado'
		 WHEN T0.KeyFld_4 = 7 THEN 'Município'
		 WHEN T0.KeyFld_4 = 8 THEN 'Código do serviço'
		 WHEN T0.KeyFld_4 = 9 THEN 'Grupo de itens'
		 WHEN T0.KeyFld_4 = 10 THEN 'Conta contábil'
		 WHEN T0.KeyFld_4 = 11 THEN 'Grupo cliente'
		 WHEN T0.KeyFld_4 = 16 THEN 'Filial'
		 WHEN T0.KeyFld_4 = 17 THEN t0.UDFAlias_4
		 WHEN T0.KeyFld_4 = 25 THEN 'Tipo tributário da empresa'
		 WHEN T0.KeyFld_4 = 26 THEN 'Tipo tributário do PN'
		 WHEN T0.KeyFld_4 = 27 THEN 'Grupo de estado'
		 WHEN T0.KeyFld_4 = 28 THEN 'Grupo de código de origem do produto'
		 WHEN T0.KeyFld_4 = 29 THEN 'Grupo de código NCM'  END 'Campo-chave 4',
	CASE WHEN T0.KeyFld_4 IN (1,2,6,10,17) THEN T1.KeyFld_4_V
		 WHEN T0.KeyFld_4 = 3 THEN (SELECT TA.MatGrp FROM OMGP TA WHERE TA.AbsEntry =  T1.KeyFld_4_V)
		 WHEN T0.KeyFld_4 = 4 THEN (SELECT TA.ServiceGrp FROM OSGP TA WHERE TA.AbsEntry = T1.KeyFld_4_V)
		 WHEN T0.KeyFld_4 = 5 THEN (SELECT TA.NcmCode FROM ONCM TA WHERE TA.AbsEntry = T1.KeyFld_4_V)
		 WHEN T0.KeyFld_4 = 7 THEN (SELECT TA.Name FROM OCNT TA WHERE TA.Code = T1.KeyFld_4_V)
		 WHEN T0.KeyFld_4 = 8 THEN (SELECT TA.ServiceCD FROM OSCD TA WHERE TA.AbsEntry = T1.KeyFld_4_V)
		 WHEN T0.KeyFld_4 = 9 THEN (SELECT TA.ItmsGrpNam FROM OITB TA WHERE TA.ItmsGrpCod = T1.KeyFld_4_V)
		 WHEN T0.KeyFld_4 = 11 THEN (SELECT TA.GroupName FROM OCRG TA WHERE TA.GroupCode = T1.KeyFld_4_V)
		 WHEN T0.KeyFld_4 = 16 THEN (select ta.BPLName from OBPL ta where ta.BPLId = t1.KeyFld_4_V)
		 WHEN T0.KeyFld_4 IN (25,26) THEN (SELECT TA.Descr FROM OBNI TA WHERE TA.ID = T1.KeyFld_4_V)
		 WHEN T0.KeyFld_4 = 27 THEN (SELECT TA.GroupName FROM OSTG TA WHERE TA.GroupCode = T1.KeyFld_4_V)
		 WHEN T0.KeyFld_4 = 28 THEN (SELECT TA.GroupName FROM OPSG TA WHERE TA.GroupCode = T1.KeyFld_4_V)
		 WHEN T0.KeyFld_4 = 29 THEN (SELECT TA.GroupName FROM ONCG TA WHERE TA.GroupCode = T1.KeyFld_4_V)  END 'Valor do campo-chave 4',	
	CASE WHEN T0.KeyFld_5 = 1 THEN 'Parceiro de negócios'	
		 WHEN T0.KeyFld_5 = 2 THEN 'Item'
		 WHEN T0.KeyFld_5 = 3 THEN 'Grupo de materiais'
		 WHEN T0.KeyFld_5 = 4 THEN 'Grupo de serviço'
		 WHEN T0.KeyFld_5 = 5 THEN 'Código NCM'
		 WHEN T0.KeyFld_5 = 6 THEN 'Estado'
		 WHEN T0.KeyFld_5 = 7 THEN 'Município'
		 WHEN T0.KeyFld_5 = 8 THEN 'Código do serviço'
		 WHEN T0.KeyFld_5 = 9 THEN 'Grupo de itens'
		 WHEN T0.KeyFld_5 = 10 THEN 'Conta contábil'
		 WHEN T0.KeyFld_5 = 11 THEN 'Grupo cliente'
		 WHEN T0.KeyFld_5 = 16 THEN 'Filial'
		 WHEN T0.KeyFld_5 = 17 THEN t0.UDFAlias_5
		 WHEN T0.KeyFld_5 = 25 THEN 'Tipo tributário da empresa'
		 WHEN T0.KeyFld_5 = 26 THEN 'Tipo tributário do PN'
		 WHEN T0.KeyFld_5 = 27 THEN 'Grupo de estado'
		 WHEN T0.KeyFld_5 = 28 THEN 'Grupo de código de origem do produto'
		 WHEN T0.KeyFld_5 = 29 THEN 'Grupo de código NCM'  END 'Campo-chave 5',
	CASE WHEN T0.KeyFld_5 IN (1,2,6,10,17) THEN T1.KeyFld_5_V
		 WHEN T0.KeyFld_5 = 3 THEN (SELECT TA.MatGrp FROM OMGP TA WHERE TA.AbsEntry =  T1.KeyFld_5_V)
		 WHEN T0.KeyFld_5 = 4 THEN (SELECT TA.ServiceGrp FROM OSGP TA WHERE TA.AbsEntry = T1.KeyFld_5_V)
		 WHEN T0.KeyFld_5 = 5 THEN (SELECT TA.NcmCode FROM ONCM TA WHERE TA.AbsEntry = T1.KeyFld_5_V)
		 WHEN T0.KeyFld_5 = 7 THEN (SELECT TA.Name FROM OCNT TA WHERE TA.Code = T1.KeyFld_5_V)
		 WHEN T0.KeyFld_5 = 8 THEN (SELECT TA.ServiceCD FROM OSCD TA WHERE TA.AbsEntry = T1.KeyFld_5_V)
		 WHEN T0.KeyFld_5 = 9 THEN (SELECT TA.ItmsGrpNam FROM OITB TA WHERE TA.ItmsGrpCod = T1.KeyFld_5_V)
		 WHEN T0.KeyFld_5 = 11 THEN (SELECT TA.GroupName FROM OCRG TA WHERE TA.GroupCode = T1.KeyFld_5_V)
		 WHEN T0.KeyFld_5 = 16 THEN (select ta.BPLName from OBPL ta where ta.BPLId = t1.KeyFld_5_V)
		 WHEN T0.KeyFld_5 IN (25,26) THEN (SELECT TA.Descr FROM OBNI TA WHERE TA.ID = T1.KeyFld_5_V)
		 WHEN T0.KeyFld_5 = 27 THEN (SELECT TA.GroupName FROM OSTG TA WHERE TA.GroupCode = T1.KeyFld_5_V)
		 WHEN T0.KeyFld_5 = 28 THEN (SELECT TA.GroupName FROM OPSG TA WHERE TA.GroupCode = T1.KeyFld_5_V)
		 WHEN T0.KeyFld_5 = 29 THEN (SELECT TA.GroupName FROM ONCG TA WHERE TA.GroupCode = T1.KeyFld_5_V)  END 'Valor do campo-chave 5',
	t2.EfctFrom 'Efetivo desde',
	T2.EfctTo 'Efetivo até',
	t2.TaxCode 'Cód. Imposto p/ det. item de serviço e doc. serviço',
	(select ta.Name from OSTC ta where ta.Code = t2.TaxCode) 'Descrição cód. Imposto p/ det. item de serviço e doc. serviço',
	t3.WTCode 'Código do IRF',
	(select ta.WTName from owht ta where ta.WTCode = t3.WTCode ) 'Descrição código do IRF',
	(select ta.Usage from ousg ta where ta.ID = t4.UsageCode)	'Utilização',
	t4.TaxCode 'Código de imposto',
	(select ta.Name from OSTC ta where ta.Code = t4.TaxCode) 'Descrição do código de imposto',
	t4.ExpTaxCode 'Código de imposto sobre despesas adicionais',
	(select ta.Name from OSTC ta where ta.Code = t4.ExpTaxCode) 'Descrição do código de imposto sobre despesas adicionais',
	t4.PurTaxCode 'Código de imposto sobre compras',
	(select ta.Name from OSTC ta where ta.Code = t4.PurTaxCode) 'Descrição do código de imposto sobre compras'

from 
	tcd1 t0 left join TCD2 t1 on t1.Tcd1Id = t0.AbsId
	left join TCD3 t2 on t2.Tcd2Id = t1.AbsId
	left join TCD4 t3 on t3.Tcd2Id = t1.AbsId
	left join TCD5 t4 on t4.Tcd3Id = t2.AbsId
	