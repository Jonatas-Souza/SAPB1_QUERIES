USE [SBO_MVTA_PRO]
GO
/****** Object:  StoredProcedure [dbo].[SBO_SP_TransactionNotification]    Script Date: 13/10/2017 15:57:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[SBO_SP_TransactionNotification] 

@object_type nvarchar(30), 				-- SBO Object Type
@transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
@num_of_cols_in_key int,
@list_of_key_cols_tab_del nvarchar(255),
@list_of_cols_val_tab_del nvarchar(255)

AS

begin

-- Return values
declare @error  int				-- Result (0 for no error)
declare @error_message nvarchar (200) 		-- Error string to be displayed
select @error = 0
select @error_message = N'Ok'

--------------------------------------------------------------------------------------------------------------------------------

--	ADD	YOUR	CODE	HERE

--------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------
--/*
--	-- DESCRIÇÃO: TRAVA QUE IMPEDE O SALVAMENTO DE PEDIDOS DE VENDAS QUANDO O TOTAL DE LOTES SELECIONADO FOR DIFERENTE DO TOTAL 
--				  DE ITENS COM CONTROLE DE LOTE
--	-- AUTOR: JÔNATAS SOUZA - RAMO BH
--	-- DATA: 28/10/2020
--*/
-----------------------------------------------------------------------------------------------------------------------------------

IF @object_type = '17' AND @transaction_type IN ('A','U')
BEGIN
	IF 
	(SELECT 
	SUM(T0.Quantity)
	FROM 
	RDR1 T0 INNER JOIN OITM T1 ON T1.ItemCode = T0.ItemCode
	WHERE
	T1.ManBtchNum = 'Y'
	AND T0.DocEntry = @list_of_cols_val_tab_del) >
	ISNULL((SELECT
	SUM(T0.Quantity)
	FROM
	IBT1 T0 WITH (NOLOCK)
	WHERE
	T0.BaseType = 17
	AND T0.Quantity <> 0
	AND BaseEntry = @list_of_cols_val_tab_del),0)
		BEGIN
			SET @error = 17
			SET @error_message = 'VOCÊ NÃO SELECIONOU LOTES PARA TODOS OS ITENS DO PEDIDO, REVISE A OPERAÇÃO!'
		END
END
---------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------
--/*
--	-- DESCRIÇÃO: TRAVA QUE IMPEDE O SALVAMENTO DE PEDIDOS DE VENDAS QUANDO O TOTAL DE SÉRIES SELECIONADAS FOR DIFERENTE DO TOTAL 
--				  DE ITENS COM CONTROLE DE SÉRIE
--	-- AUTOR: JÔNATAS SOUZA - RAMO BH
--	-- DATA: 28/10/2020
--*/
-------------------------------------------------------------------------------------------------------------------------------

IF @object_type = '17' AND @transaction_type IN ('A','U')
BEGIN
	IF 
	(SELECT 
	SUM(T0.Quantity)
	FROM 
	RDR1 T0 INNER JOIN OITM T1 ON T1.ItemCode = T0.ItemCode
	WHERE
	T1.ManSerNum = 'Y'
	AND T0.DocEntry = @list_of_cols_val_tab_del) >
	ISNULL((SELECT 
	SUM(T0.AllocQty)
	FROM
	ITL1 t0 inner join OITL t1 on  t0.LogEntry = t1.LogEntry 
	INNER JOIN OITM T3 ON T3.ItemCode = T0.ItemCode
	WHERE
	T3.ManSerNum = 'Y'
	AND T1.DocType = 17
	AND T1.DocEntry = @list_of_cols_val_tab_del),0)
	BEGIN
			SET @error = 17
			SET @error_message = 'VOCÊ NÃO SELECIONOU AS SÉRIES PARA TODOS OS ITENS DO PEDIDO, REVISE A OPERAÇÃO!'
		END
END
------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------
------ Rotina que bloqueios Fiscais                                                                    --                                                            --
---------------------------------------------------------------------------------------------------------
declare @CardCode nvarchar(15)
declare @Dias     int

---validações nf-e----

----- TELA DE NOTA FISCAL DE SAÍDA,DADOS PN(DESCONSIDERANDO EXPORTAÇÃO)---
declare @ERRO	AS int
set     @erro = 0001

if @list_of_cols_val_tab_del <> ''
	Begin
	
	if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN INV1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.StreetNoS IS NULL)
			  AND T2.Usage <> 20
			  
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: NÚMERO'
		End




		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN INV1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.StreetS IS NULL)
			  AND T2.Usage <> 20
			  
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: RUA'
		End
	
	   		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN INV1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.AddrTypeS IS NULL)
			  AND T2.Usage <> 20
			  
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: TIPO LOGRADOURO'
		End
	 		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN INV1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.ZipCodeS IS NULL)
			  AND T2.Usage <> 20
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: CEP'
		End
	  		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN INV1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.BlockS IS NULL)
			  AND T2.Usage <> 20
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: BAIRRO'
		End
	  		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN INV1 T2 ON T0.DocEntry = T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.CityS IS NULL)
			  AND T2.Usage <> 20			 
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: CIDADE'
		End
	  		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN INV1 T2 ON T0.DocEntry = T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.StateS IS NULL)
			  AND T2.Usage <> 20
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: ESTADO'
		End
	
		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
			IF exists (SELECT OINV.DocEntry 
						FROM [dbo].[OINV] 
						WHERE (OINV.U_U_natOpDesc is null OR OINV.U_U_natOpDesc = '') 
								AND OINV.SeqCode in ('-2','-1','27') and OINV.Model  in  ('19','6','8','22','1','39') 
								AND OINV.DocEntry = @list_of_cols_val_tab_del) 
		BEGIN
            SET @error = '13'
            SET @error_message = 'Campos de Usuário: Informe a Descrição do CFOP !' 
		END	 
	
--FIM DADOS DO PN---

---DADOS DO ITEM---
		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
			  WHERE (T1.unitMsr IS NULL OR T1.unitMsr='')
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR UNIDADE DE MEDIDA DO ITEM CÓDIGO: '+ CONVERT(VARCHAR(20),((SELECT TOP 1 T1.ItemCode
			  FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.unitMsr IS NULL OR T1.unitMsr=''))))
		End
		
		
			if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OITM T2 ON T1.ItemCode= T2.ItemCode
			  WHERE T2.ItemClass = 2 and T2.MatType = 0 and (T2.NCMCode IS NULL OR T2.NCMCode= -1)
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR NCM DO ITEM CÓDIGO: '+CONVERT(VARCHAR(20),( (SELECT TOP 1 T1.ItemCode
			  FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OITM T2 ON T1.ItemCode= T2.ItemCode
			  WHERE (T2.NCMCode IS NULL OR T2.NCMCode=-1))))
		End
--- FIM DADOS DO ITEM---


---DADOS FISCAIS NÃO OBRIGATÓRIOS SAP---	
---CTS'S E IDENTIFICAÇÕES FISCAIS---
		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
			IF (SELECT count(T0.DocEntry)
				  FROM OINV T0 INNER JOIN INV12 T1 ON T0.DocEntry=T1.DocEntry
				 INNER JOIN INV1 T2 ON T0.DocEntry=T2.DocEntry
				WHERE (T2.Usage IS NULL) AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
			Begin
				SET @error			= @erro
				SET @error_message	= 'Linha do Item: Informar a utilização'
		End

		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OITM T2 ON T1.ItemCode = T2.ItemCode
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE T2.Series <> 65 and (T1.CSTCode IS NULL OR T1.CSTCode='')
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR CST ICMS DO ITEM CÓDIGO: '+CONVERT(VARCHAR(20),( (SELECT T1.ItemCode
			  FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
			 WHERE (T1.CSTCode IS NULL OR T1.CSTCode=''))))
		End
		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.CSTfCOFINS IS NULL OR T1.CSTfCOFINS='')
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR CST COFINS DO ITEM CÓDIGO: '+CONVERT(VARCHAR(20),( (SELECT T1.ItemCode
			  FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
			 WHERE (T1.CSTfCOFINS IS NULL OR T1.CSTfCOFINS=''))))
		End
		if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OITM T2 ON T1.ItemCode = T2.ItemCode
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE T2.Series <> 65 and (T1.CSTfIPI IS NULL OR T1.CSTfIPI='')
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR CST IPI DO ITEM CÓDIGO: '+CONVERT(VARCHAR(20),( (SELECT T1.ItemCode
			  FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
			 WHERE (T1.CSTfIPI IS NULL OR T1.CSTfIPI=''))))
		End
				if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.CSTfPIS IS NULL OR T1.CSTfPIS='')
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR CST PIS DO ITEM CÓDIGO: '+CONVERT(VARCHAR(20),( (SELECT T1.ItemCode
			FROM OINV T0 INNER JOIN INV1 T1 ON T0.DocEntry=T1.DocEntry
		    WHERE (T1.CSTfPIS IS NULL OR T1.CSTfPIS=''))))
		End
		
		    if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
			IF (SELECT count(T0.DocEntry)
			FROM OINV T0 INNER JOIN INV12 T1 ON T0.DocEntry=T1.DocEntry
			INNER JOIN INV1 T2 ON T0.DocEntry=T2.DocEntry
			INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			WHERE (T1.TaxId0 IS NULL OR T1.TaxId0='')AND (T1.TaxId4 IS NULL OR T1.TaxId4 ='')
			AND T2.Usage <> 20
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR DADOS PN, FALTA PREENCHER CAMPO: CNPJ OU CPF'
		End
			if  @object_type = '13' and( @transaction_type = 'A' or @transaction_type ='U')
			IF (SELECT count(T0.DocEntry)
			FROM OINV T0 INNER JOIN INV12 T1 ON T0.DocEntry=T1.DocEntry
			INNER JOIN INV1 T2 ON T0.DocEntry=T2.DocEntry
			INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			WHERE (T1.TaxId1 IS NULL OR T1.TaxId1='')
			AND T2.Usage <> 20
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR DADOS PN, FALTA PREENCHER OU MARCAR COMO ISENTO CAMPO: INSCRIÇÃO ESTADUAL'
		End
--- fim validação nota fiscal de saída---

---Validações Tela de Entrega---

--- TELA DE ENTREGA,DADOS PN(DESCONSIDERANDO EXPORTAÇÃO)---
	
	if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN DLN1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.StreetNoS IS NULL or T1.StreetNoS ='')
			  AND T2.Usage <> 20
			  and T0.SeqCode = 27 -- SOMENTE SE NF FOR SEQUENCIA DE TRASNSMISSÃO P/ SEFAZ, ANALISAR CODIGO DA SEQUENCIA--
			  
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: NÚMERO'
		End
	
		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN DLN1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.StreetS IS NULL or t1.StreetNoS ='')
			  AND T2.Usage <> 20
			  AND T0.SeqCode= 27 --SOMENTE SE NF-e
			  
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: RUA'
		End
	
	   		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN DLN1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.AddrTypeS IS NULL or T1.AddrTypeS ='')
			  AND T2.Usage <> 20
			  AND T0.SeqCode= 27 --SOMENTE SE NF-e
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: TIPO LOGRADOURO'
		End
	 		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN DLN1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.ZipCodeS IS NULL or t1.ZipCodeS = '')
			  AND T2.Usage <> 20
			  AND T0.SeqCode= 27 --SOMENTE SE NF-e
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: CEP'
		End
	  		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN DLN1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.BlockS IS NULL or t1.BlockS ='')
			  AND T2.Usage <> 20
			  AND T0.SeqCode= 27 -- SOMENTE SE NF-e
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: BAIRRO'
		End
	  		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN DLN1 T2 ON T0.DocEntry = T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.CityS IS NULL or t1.CityS = '')
			  AND T2.Usage <> 20
			  AND T0.SeqCode = 27 -- somente se NF-e			 
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: CIDADE'
		End
	  		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN DLN1 T2 ON T0.DocEntry = T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.StateS IS NULL or t1.StateS = '')
			  AND T2.Usage <> 20
			  AND T0.SeqCode = 27 -- SOMENTE SE NF-e
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: ESTADO'
		End

		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
			IF exists (SELECT ODLN.DocEntry 
						FROM [dbo].[ODLN] 
						WHERE (ODLN.U_U_natOpDesc is null OR ODLN.U_U_natOpDesc = '') 
								AND ODLN.SeqCode in ('-2','-1','27') and ODLN.Model  in  ('19','6','8','22','1','39') 
								AND ODLN.DocEntry = @list_of_cols_val_tab_del) 
		BEGIN
            SET @error = '13'
            SET @error_message = 'Campos de Usuário: Informe a Descrição do CFOP !' 
		END	 
	 
	
--FIM DADOS DO PN---

---DADOS DO ITEM---
		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
			  WHERE (T1.unitMsr IS NULL OR T1.unitMsr='')
			--  AND T0.SeqCode = 27 --SOMENE SE NF-e
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
			  
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR UNIDADE DE MEDIDA DO ITEM CÓDIGO: '+ CONVERT(VARCHAR(20),((SELECT TOP 1 T1.ItemCode
			  FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
			  WHERE (T1.unitMsr IS NULL OR T1.unitMsr='')
			  --AND T0.SeqCode = 27 --SOMENTE SE NF-e
			  )))
		End
		
		
			if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OITM T2 ON T1.ItemCode= T2.ItemCode
			  WHERE T2.ItemClass = 2 and T2.MatType = 0 and (T2.NCMCode IS NULL OR T2.NCMCode= -1)
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR NCM DO ITEM CÓDIGO: '+CONVERT(VARCHAR(20),( (SELECT TOP 1 T1.ItemCode
			  FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OITM T2 ON T1.ItemCode= T2.ItemCode
			  WHERE (T2.NCMCode IS NULL OR T2.NCMCode=-1))))
		End
--- FIM DADOS DO ITEM---


---DADOS FISCAIS NÃO OBRIGATÓRIOS SAP---	
---CTS'S E IDENTIFICAÇÕES FISCAIS---
		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
			IF (SELECT count(T0.DocEntry)
				  FROM ODLN T0 INNER JOIN DLN12 T1 ON T0.DocEntry=T1.DocEntry
				 INNER JOIN DLN1 T2 ON T0.DocEntry=T2.DocEntry
				WHERE (T2.Usage IS NULL) AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
			Begin
				SET @error			= @erro
				SET @error_message	= 'Linha do Item: Informar a utilização'
		End

		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OITM T2 ON T1.ItemCode = T2.ItemCode
			  WHERE T2.Series <> 65 and (T1.CSTCode IS NULL OR T1.CSTCode='')
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR CST ICMS DO ITEM CÓDIGO: '+CONVERT(VARCHAR(20),( (SELECT T1.ItemCode
			  FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
			 WHERE (T1.CSTCode IS NULL OR T1.CSTCode=''))))
		End
		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
			  WHERE (T1.CSTfCOFINS IS NULL OR T1.CSTfCOFINS='')
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR CST COFINS DO ITEM CÓDIGO: '+CONVERT(VARCHAR(20),( (SELECT T1.ItemCode
			  FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
			 WHERE (T1.CSTfCOFINS IS NULL OR T1.CSTfCOFINS=''))))
		End
		if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
			  WHERE (T1.CSTfIPI IS NULL OR T1.CSTfIPI='')
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR CST IPI DO ITEM CÓDIGO: '+CONVERT(VARCHAR(20),( (SELECT T1.ItemCode
			  FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OITM T2 ON T1.ItemCode = T2.ItemCode
			  WHERE T2.Series <> 65 and (T1.CSTfIPI IS NULL OR T1.CSTfIPI=''))))
		End
				if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
			  WHERE (T1.CSTfPIS IS NULL OR T1.CSTfPIS='')
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR CST PIS DO ITEM CÓDIGO: '+CONVERT(VARCHAR(20),( (SELECT T1.ItemCode
			FROM ODLN T0 INNER JOIN DLN1 T1 ON T0.DocEntry=T1.DocEntry
		    WHERE (T1.CSTfPIS IS NULL OR T1.CSTfPIS=''))))
		End
		
		    if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
			IF (SELECT count(T0.DocEntry)
			FROM ODLN T0 INNER JOIN DLN12 T1 ON T0.DocEntry=T1.DocEntry
			INNER JOIN DLN1 T2 ON T0.DocEntry=T2.DocEntry
			INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			WHERE (T1.TaxId0 IS NULL OR T1.TaxId0='')AND (T1.TaxId4 IS NULL OR T1.TaxId4 ='')
			AND T2.Usage <> 20
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR DADOS PN, FALTA PREENCHER CAMPO: CNPJ OU CPF'
		End
			if  @object_type = '15' and( @transaction_type = 'A' or @transaction_type ='U')
			IF (SELECT count(T0.DocEntry)
			FROM ODLN T0 INNER JOIN DLN12 T1 ON T0.DocEntry=T1.DocEntry
			INNER JOIN DLN1 T2 ON T0.DocEntry=T2.DocEntry
			INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			WHERE (T1.TaxId1 IS NULL OR T1.TaxId1='')
			AND T2.Usage <> 20
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR DADOS PN, FALTA PREENCHER OU MARCAR COMO ISENTO CAMPO: INSCRIÇÃO ESTADUAL'
		End
---- fim validação entrega---		

----VALIDAÇÕES PEDIDOS DE VENDA----

	
	if  @object_type = '17' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ORDR T0 INNER JOIN RDR12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN RDR1 T2 ON T0.DocEntry = T2.DocEntry
			  WHERE (T1.StreetNoS IS NULL)
			  AND T2.Usage <> 20
			  
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: NÚMERO'
		End
	
		if  @object_type = '17' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ORDR T0 INNER JOIN RDR12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN RDR1 T2 ON T0.DocEntry=T2.DocEntry
			  WHERE (T1.StreetS IS NULL)
			  AND T2.Usage <> 20
			  
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: RUA'
		End
	
	   		if  @object_type = '17' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ORDR T0 INNER JOIN RDR12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN RDR1 T2 ON T0.DocEntry=T2.DocEntry
			  WHERE (T1.AddrTypeS IS NULL)
			  AND T2.Usage <> 20
			  
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: TIPO LOGRADOURO'
		End
	 		if  @object_type = '17' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ORDR T0 INNER JOIN RDR12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN RDR1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.ZipCodeS IS NULL)
			  AND T2.Usage <> 20
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: CEP'
		End
	  		if  @object_type = '17' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ORDR T0 INNER JOIN RDR12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN RDR1 T2 ON T0.DocEntry=T2.DocEntry
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.BlockS IS NULL)
			  AND T2.Usage <> 20
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: BAIRRO'
		End
	  		if  @object_type = '17' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ORDR T0 INNER JOIN RDR12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN RDR1 T2 ON T0.DocEntry = T2.DocEntry 
			  INNER JOIN OCRD T3 ON T3.CardCode = T0.CardCode and T3.GroupCode != 103 and T3.GroupCode != 104
			  WHERE (T1.CityS IS NULL)
			  AND T2.Usage <> 20			 
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: CIDADE'
		End
	  		if  @object_type = '17' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ORDR T0 INNER JOIN RDR12 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN RDR1 T2 ON T0.DocEntry = T2.DocEntry
			  WHERE (T1.StateS IS NULL)
			  AND T2.Usage <> 20
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR ENDEREÇO PN, FALTA PREENCHER CAMPO: ESTADO'
		End
	 
	
--FIM DADOS DO PN---

---DADOS DO ITEM---
		if  @object_type = '17' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ORDR T0 INNER JOIN RDR1 T1 ON T0.DocEntry=T1.DocEntry
			  WHERE (T1.unitMsr IS NULL OR T1.unitMsr='')
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR UNIDADE DE MEDIDA DO ITEM CÓDIGO: '+ CONVERT(VARCHAR(20),((SELECT TOP 1 T1.ItemCode
			  FROM ORDR T0 INNER JOIN RDR1 T1 ON T0.DocEntry=T1.DocEntry
			  WHERE (T1.unitMsr IS NULL OR T1.unitMsr=''))))
		End
		
		
			if  @object_type = '17' and( @transaction_type = 'A' or @transaction_type ='U')
		IF (SELECT count(T0.DocEntry)
			  FROM ORDR T0 INNER JOIN RDR1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OITM T2 ON T1.ItemCode= T2.ItemCode
			  WHERE T2.ItemClass = 2 and T2.Mattype = 0 and (T2.NCMCode IS NULL OR T2.NCMCode= -1)
			  AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR NCM DO ITEM CÓDIGO: '+CONVERT(VARCHAR(20),( (SELECT TOP 1 T1.ItemCode
			  FROM ORDR T0 INNER JOIN RDR1 T1 ON T0.DocEntry=T1.DocEntry
			  INNER JOIN OITM T2 ON T1.ItemCode= T2.ItemCode
			  WHERE T2.ItemClass = 2 and T2.Mattype = 0 and (T2.NCMCode IS NULL OR T2.NCMCode=-1))))
		End

			if  @object_type = '17' and( @transaction_type = 'A' or @transaction_type ='U')
			IF (SELECT count(T0.DocEntry)
			FROM ORDR T0 INNER JOIN RDR12 T1 ON T0.DocEntry=T1.DocEntry
			INNER JOIN RDR1 T2 ON T0.DocEntry=T2.DocEntry
			WHERE (T1.TaxId1 IS NULL OR T1.TaxId1='')
			AND T2.Usage <> 20
			  			   AND T0.DocEntry = @list_of_cols_val_tab_del) > 0
		Begin
			SET @error			= @erro
			SET @error_message	= 'VERIFICAR DADOS PN, FALTA PREENCHER OU MARCAR COMO ISENTO CAMPO: INSCRIÇÃO ESTADUAL'
		End
		
		--- FIM VALIDAÇÕES PEDIDOS DE VENDA---


END
	
---FIM VALIDAÇÃO FISCAIS---

 ---------------------------------------------------------------------------------------------------- 
   /* BLoqueio ao Inserir NF de Entrada com um número de nota ja existente */ 
 ----------------------------------------------------------------------------------------------------  


Declare @Serial as INT
Declare @PN1 as nvarchar(100)
Declare @docdestino as INT

IF @object_type = '18' AND @transaction_type in ('A')

BEGIN

SET @Serial = (select serial from OPCH where OPCH.DocEntry = @list_of_cols_val_tab_del)
SET @PN1 = (select CardCode from OPCH where OPCH.DocEntry = @list_of_cols_val_tab_del)
SET @docdestino = (select Top 1 PCH1.BaseType from PCH1 where PCH1.DocEntry = @list_of_cols_val_tab_del)

IF exists(select '1' from OPCH T0 where T0.Serial = @Serial and T0.CardCode = @PN1 and T0.DocEntry <> @list_of_cols_val_tab_del) and @docdestino <> 18 and @Serial not in ( select Serial from OPCH where OPCH.CANCELED = 'Y')

      BEGIN
            SET @error = '0114'
            SET @error_message = 'Número de Nota Fiscal ja existe !' 
      END
END

--------------------------------------------------------------------------------------------------------
/* Bloqueio ao inserir um Parceiro de negíocio sem DDD, Telefone, CNPJ , IE e E-mail */

--------------------------------------------------------------------------------------------------------
declare @indIEDest nvarchar (100)
declare @DDD nvarchar (20)
declare @tel nvarchar (20)
declare @CNPJ nvarchar (100)
declare @IE nvarchar (100)
--declare @email nvarchar (100)
declare @Password nvarchar (100)
declare @cardtype nvarchar (5)

IF @object_type = '2' AND ( @transaction_type = 'A' or @transaction_type ='U')



BEGIN

--set @indIEDest = (select CRD1.U_Skill_indIEDest from CRD1 where CRD1.LineNum = 0 and CRD1.U_Skill_indIEDest is null and CRD1.CardCode = @list_of_cols_val_tab_del)
set @DDD = (select OCRD.Phone2 from OCRD where OCRD.CardCode = @list_of_cols_val_tab_del)
set @tel = (select OCRD.Phone1 from OCRD where OCRD.CardCode = @list_of_cols_val_tab_del)
set @CNPJ = (select case when ocrd.GroupCode in (103,104) then '1' else (case when OCRD.CmpPrivate = 'C' then  CRD7.TaxId0 else CRD7.TaxId4 end) end  from CRD7 inner join OCRD on CRD7.CardCode = OCRD.cardCode and CRD7.Address = ''  where OCRD.CardCode = @list_of_cols_val_tab_del)
set @IE = (select CRD7.TaxId1 from CRD7 inner join OCRD on CRD7.CardCode = OCRD.cardCode   and CRD7.Address = ''  where  OCRD.CardCode = @list_of_cols_val_tab_del)
--set @email = (select OCRD.E_Mail from OCRD where OCRD.CardCode = @list_of_cols_val_tab_del)
set @Password = (select OCRD.Password from OCRD where OCRD.CardCode = @list_of_cols_val_tab_del)
set @cardtype = (select OCRD.CardType from ocrd where ocrd.CardType = @list_of_cols_val_tab_del)

IF exists (SELECT OCRD.CardCode 
      FROM [dbo].[OCRD] 
      WHERE (( @DDD = '' OR @DDD is null) OR (@tel = '' OR @tel is null) OR (@CNPJ is null) OR (@IE = '' OR @IE is null) OR (@Password = '' OR @Password is null) --OR (@indIEDest = '' OR @indIEDest is null) 
              AND OCRD.CardCode = @list_of_cols_val_tab_del and @cardtype <> 'L' ))
               

      BEGIN
            SET @error = '0011'
            SET @error_message = 'Campos Obrigatórios: ' + (select (case WHEN (@DDD = '' OR @DDD is null) then 'DDD, ' else '' END)) + (select (case WHEN (@tel = '' OR @tel is null) then 'Telefone, ' else '' END)) + (select (case WHEN (@CNPJ = '' OR @CNPJ is null) then 'CNPJ/CPF, ' else '' END)) + (select (case WHEN (@IE = '' OR @IE is null) then 'Inscrição Estadual, ' else '' END)) + (select (case WHEN (@Password = '' OR @Password is null) then 'CNPJ' else '' END)) --+ (select (case WHEN (@indIEDest = '' OR @indIEDest is null) then 'e Indicador de IE' else '' END))
      END
END

IF((@object_type = '2') AND (@transaction_type = 'A' OR @transaction_type = 'U'))
BEGIN

/**** NOME DO PN ************************************************************************************/                     
  IF (SELECT CardName FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del) IS NULL 
  BEGIN
  SET @error = 1;
  SET @error_message = 'Preencher o campo NOME.'
  END
  
/**** Endereço DE COBRANÇA (Cliente) ****************************************************************/                     
  IF ((SELECT Count(Address) FROM crd1 WHERE CardCode = @list_of_cols_val_tab_del AND AdresType = 'B') = 0
  AND
  (SELECT CardType FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del) = 'C')
  BEGIN
  SET @error = 25;
  SET @error_message = 'Preencher ao menos um campo de Endereço DE COBRANÇA.'
  END

  /**** ESTADO (Endereço Cliente) *********************************************************************/                     
  IF ((SELECT Count(Address) FROM crd1 WHERE CardCode = @list_of_cols_val_tab_del) >
  (SELECT Count(State) FROM CRD1 WHERE CardCode = @list_of_cols_val_tab_del AND State <> ''))
  AND
  ((SELECT CardType FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del) = 'C')
  BEGIN
  SET @error = 31
  SET @error_message = 'Endereços: Preencher o campo ESTADO.'
  END
/****** Inscrição INSS */
   IF ((SELECT Count(TaxId4) FROM crd7 WHERE CardCode = @list_of_cols_val_tab_del and TaxId4 <> '') <> 0 ) and 
  (SELECT Count(TaxId7) FROM CRD7 WHERE CardCode = @list_of_cols_val_tab_del AND TaxId7 <> '') = 0
  --AND
  --((SELECT CardType FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del) = 'C')
  BEGIN
  SET @error = 32
  SET @error_message = 'Dados Fiscais: Preencher o campo Inscrição INSS.'
  END

/**** MUNICÍPIO (Endereço Cobrança Cliente)**********************************************************/                     
  IF ((SELECT Count(Address) FROM crd1 WHERE CardCode = @list_of_cols_val_tab_del) >
  (SELECT Count(County) FROM CRD1 WHERE CardCode = @list_of_cols_val_tab_del AND County <> ''))
  AND((SELECT CardType FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del) = 'C'
    AND (SELECT TOP 1 CRD1.Country FROM CRD1 WHERE CardCode = @list_of_cols_val_tab_del AND AdresType = 'B') = 'BR')
  BEGIN
  SET @error = 33;
  SET @error_message = 'Endereços: Preencher o campo MUNICIPIO.'
  END
/*****    *****/

  IF ((SELECT Count(TaxId3) FROM crd7 WHERE CardCode = @list_of_cols_val_tab_del and TaxId3 <> '') = 0 )
  AND ((Select count(GroupCode) from OCRD where  CardCode = @list_of_cols_val_tab_del and GroupCode != 103 and GroupCode != 104) > 0)
  BEGIN
  SET @error = 33
  SET @error_message = 'Dados Fiscais: Preencher o campo Inscrição Municipal.'
  END


/**** Indicador da IE (Aba Endereço)**********************************************************/                     
  IF ((SELECT Count(Address) FROM crd1 WHERE CardCode = @list_of_cols_val_tab_del) >
  (SELECT Count(U_SKILL_indIEDest) FROM CRD1 WHERE CardCode = @list_of_cols_val_tab_del AND U_SKILL_indIEDest <> ''))
  AND((SELECT CardType FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del) = 'C'
    AND ISNULL((SELECT TOP 1 CRD1.U_SKILL_indIEDest FROM CRD1 WHERE CardCode = @list_of_cols_val_tab_del AND AdresType = 'B'),'') = '')
  BEGIN
  SET @error = 34;
  SET @error_message = 'Endereços: Preencher o campo Indicador da IE.'
  END

/**** DESTINATÁRIO (Cliente)*************************************************************************/                     
  IF ((SELECT Count(Address) FROM crd1 WHERE CardCode = @list_of_cols_val_tab_del AND AdresType = 'S') = 0
  AND
  (SELECT CardType FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del) = 'C')
  BEGIN
  SET @error = 35;
  SET @error_message = 'SAP - Endereços: Preencher ao menos um campo de DESTINATÁRIO.'
  END

/**** PAGAMENTO ÚNICO (Cliente) ***********************************************************************/                     
  IF ((SELECT SinglePaym FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del) = 'N'
  AND
  (SELECT CardType FROM OCRD WHERE CardCode = @list_of_cols_val_tab_del) = 'C')
  BEGIN
  SET @error = 51;
  SET @error_message = 'SAP - Execução do pagamento: Selecionar o campo PAGAMENTO ÚNICO.'
  END
END

--Cadastro de Item 

IF((@object_type = '4') AND (@transaction_type = 'A' OR @transaction_type = 'U'))
BEGIN
/**** Código CEST **********************************************************/                     
  --IF (select count(ItemCode) from oitm where ItemCode = @list_of_cols_val_tab_del and ItemClass = 2 and Mattype = 0 and U_SKILL_CEST is null) > 0
  --BEGIN
  --SET @error = 33;
  --SET @error_message = 'Campos de Usuário: Preencher o campo Código CEST.'
  --END

/**** Código NCM **********************************************************/      
	IF (SELECT count(OITM.ItemCode) FROM OITM WHERE ItemCode = @list_of_cols_val_tab_del and ItemClass = 2 and Mattype = 0 and NCMCode = '-1') > 0
	BEGIN
	SET @error = 34;
	SET @error_message = 'Geral: Preencher o campo Código NCM.'
	END
END

/********* Obrigatório informar a chave de acesso na Nota Fiscal de Entrada ******/

IF (@object_type = '18') AND (@transaction_type in ('A','U'))
BEGIN
IF exists (SELECT OPCH.DocEntry 
      FROM [dbo].[OPCH]
      WHERE (OPCH.U_chaveacesso is null OR OPCH.U_chaveacesso = '') AND OPCH.SeqCode = '-2' and OPCH.Model  in  ('39','44')
              AND OPCH.DocEntry = @list_of_cols_val_tab_del) 

      BEGIN
            SET @error = '12'
            SET @error_message = 'Campos de Usuário: Informe a Chave de Acesso !' 
      END
END

/*********************** Centro de Custo  NF e LCM ***********************************/
	--Nota Fiscal de Vendas
	IF (@object_type in ('13')  AND @transaction_type  in ('A','U'))
		BEGIN
		 Declare @TransId int =(Select TransId from OINV where DocEntry=@list_of_cols_val_tab_del);
		 IF (SELECT COUNT(*) FROM  JDT1 
		                     WHERE JDT1.TransId =  @TransId 
		                           AND Account IN (select Code from [@TABELA_CENTROCUSTO]) AND (JDT1.ProfitCode = ' ' or JDT1.ProfitCode is Null)) > 0
		 BEGIN 
		 SET @error = '0099'
		 SET @error_message = 'Regra de Distribuição - Linha: Informar Centro de Custo !'
		 End
	End
	-- Nota Fiscal de Entrada
	IF (@object_type in ('18')  AND @transaction_type  in ('A','U'))
		BEGIN
		 Set @TransId =(Select TransId from OPCH where DocEntry=@list_of_cols_val_tab_del);
		 IF (SELECT COUNT(*) FROM  JDT1 
		                     WHERE JDT1.TransId =  @TransId 
		                           AND Account IN (select Code from [@TABELA_CENTROCUSTO]) AND (JDT1.ProfitCode = ' ' or JDT1.ProfitCode is Null)) > 0
		 BEGIN 
		 SET @error = '0099'
		 SET @error_message = 'Regra de Distribuição - Linha: Informar Centro de Custo !'
		 End
	End
	-- Entrega
	IF (@object_type in ('15')  AND @transaction_type  in ('A','U'))
		BEGIN
		 Set @TransId =(Select TransId from ODLN where DocEntry=@list_of_cols_val_tab_del);
		 IF (SELECT COUNT(*) FROM  JDT1 
		                     WHERE JDT1.TransId =  @TransId 
		                           AND Account IN (select Code from [@TABELA_CENTROCUSTO]) AND (JDT1.ProfitCode = ' ' or JDT1.ProfitCode is Null)) > 0
		 BEGIN 
		 SET @error = '0099'
		 SET @error_message = 'Regra de Distribuição - Linha: Informar Centro de Custo !'
		 End
	End
	-- Recebimento de Mercadoria
	IF (@object_type in ('20')  AND @transaction_type  in ('A','U'))
		BEGIN
		 Set @TransId =(Select TransId from OPDN where DocEntry=@list_of_cols_val_tab_del);
		 IF (SELECT COUNT(*) FROM  JDT1 
		                     WHERE JDT1.TransId =  @TransId 
		                           AND Account IN (select Code from [@TABELA_CENTROCUSTO]) AND (JDT1.ProfitCode = ' ' or JDT1.ProfitCode is Null)) > 0
		 BEGIN 
		 SET @error = '0099'
		 SET @error_message = 'Regra de Distribuição - Linha: Informar Centro de Custo !'
		 End
	End
	-- Adiantamento a fornecedor
	IF (@object_type in ('204')  AND @transaction_type  in ('A','U'))
		BEGIN
		 Set @TransId =(Select TransId from ODPO where DocEntry=@list_of_cols_val_tab_del);
		 IF (SELECT COUNT(*) FROM  JDT1 
		                     WHERE JDT1.TransId =  @TransId 
		                           AND Account IN (select Code from [@TABELA_CENTROCUSTO]) AND (JDT1.ProfitCode = ' ' or JDT1.ProfitCode is Null)) > 0
		 BEGIN 
		 SET @error = '0099'
		 SET @error_message = 'Regra de Distribuição - Linha: Informar Centro de Custo !'
		 End
	End
	-- Depreciação - Ativo Fixo

	IF (@object_type in ('30')  AND @transaction_type  in ('A','U'))
		BEGIN
		 IF (SELECT COUNT(*) FROM  JDT1 
		                     WHERE JDT1.TransId =  @list_of_cols_val_tab_del AND 
			                       JDT1.TransType =1470000071
		                           AND Account IN (select Code from [@TABELA_CENTROCUSTO]) AND (JDT1.ProfitCode = ' ' or JDT1.ProfitCode is Null)) > 0
		 BEGIN 
		 SET @error = '0099'
		 SET @error_message = 'Regra de Distribuição - Linha: Informar Centro de Custo !'
		 End
	End

		-- Contas a Pagar
--IF (@object_type in ('46')  AND @transaction_type  in ('A','U'))
--		BEGIN
--		 Set @TransId =(Select TransId from OVPM where DocEntry=@list_of_cols_val_tab_del);
--		 IF (SELECT COUNT(*) FROM  JDT1 
--		                     WHERE JDT1.TransId =  @TransId 
--		                           AND Account IN (select Code from [@TABELA_CENTROCUSTO]) AND (JDT1.ProfitCode = ' ' or JDT1.ProfitCode is Null)) > 0
--		 BEGIN 
--		 SET @error = '0099'
--		 SET @error_message = 'Regra de Distribuição - Linha: Informar Centro de Custo !'
--		 End
--	End
	--IF (@object_type in ('30')  AND @transaction_type  in ('A','U'))
	--	BEGIN
	--	 IF (SELECT COUNT(*) FROM  JDT1 
	--	                     WHERE JDT1.TransId =  @list_of_cols_val_tab_del AND 
	--		                       JDT1.TransType =46
	--	                           AND Account IN (select Code from [@TABELA_CENTROCUSTO]) AND (JDT1.ProfitCode = ' ' or JDT1.ProfitCode is Null)) > 0
	--	 BEGIN 
	--	 SET @error = '0099'
	--	 SET @error_message = 'Regra de Distribuição - Linha: Informar Centro de Custo !'
	--	 End
	--End
	-- Conta a Receber
	--IF (@object_type in ('24')  AND @transaction_type  in ('A','U'))
	--	BEGIN
	--	 Set @TransId =(Select TransId from ORCT where DocEntry=@list_of_cols_val_tab_del);
	--	 IF (SELECT COUNT(*) FROM  JDT1 
	--	                     WHERE JDT1.TransId =  @TransId 
	--	                           AND Account IN (select Code from [@TABELA_CENTROCUSTO]) AND (JDT1.ProfitCode = ' ' or JDT1.ProfitCode is Null)) > 0
	--	 BEGIN 
	--	 SET @error = '0099'
	--	 SET @error_message = 'Regra de Distribuição - Linha: Informar Centro de Custo !'
	--	 End
	--End

	--	IF (@object_type in ('30')  AND @transaction_type  in ('A','U'))
	--	BEGIN
	--	 IF (SELECT COUNT(*) FROM  JDT1 
	--	                     WHERE JDT1.TransId =  @list_of_cols_val_tab_del AND 
	--		                       JDT1.TransType =24
	--	                           AND Account IN (select Code from [@TABELA_CENTROCUSTO]) AND (JDT1.ProfitCode = ' ' or JDT1.ProfitCode is Null)) > 0
	--	 BEGIN 
	--	 SET @error = '0099'
	--	 SET @error_message = 'Regra de Distribuição - Linha: Informar Centro de Custo !'
	--	 End
	--End
	-- Lançamento contábil manual
	IF (@object_type in ('30')  AND @transaction_type  in ('A','U'))
		BEGIN
		 IF (SELECT COUNT(*) FROM  JDT1 
		                     WHERE JDT1.TransId =  @list_of_cols_val_tab_del AND 
			                       JDT1.TransType =30
		                           AND Account IN (select Code from [@TABELA_CENTROCUSTO]) AND (JDT1.ProfitCode = ' ' or JDT1.ProfitCode is Null)) > 0
		 BEGIN 
		 SET @error = '0099'
		 SET @error_message = 'Regra de Distribuição - Linha: Informar Centro de Custo !'
		 End
	End

	
/*********************** Centro de Custo  e nº da OS pedido de venda ***********************************/
	IF (@object_type in ('17')  AND @transaction_type  in ('A','U'))
		BEGIN
		  IF ( select U_VerificarOS from ORDR where DocEntry = @list_of_cols_val_tab_del ) = 'NÃO'
		 BEGIN 
		 SET @error = ('0100')
		 SET @error_message = 'Campo de usuário/ nº da OS - Linha: Informa nº de OS se houver e atualizar Verificar nº OS = SIM !'
		 End
	End
		IF (@object_type in ('17')  AND @transaction_type  in ('A','U'))
		BEGIN
		  IF ( select U_verificarCC from ORDR where DocEntry = @list_of_cols_val_tab_del ) = 'NÃO'
		 BEGIN 
		 SET @error = ('0101')
		 SET @error_message = 'Campo de usuário/ nº da OS - Linha: Informa Centro de Custo se houver e atualizar Verificar Centro de Custo = SIM !'
		 End
	End

/*********************** Centro de Custo  e nº da OS pedido de Compra ***********************************/
	IF (@object_type in ('22')  AND @transaction_type  in ('A','U'))
		BEGIN
		  IF ( select U_VerificarOS from OPOR where DocEntry = @list_of_cols_val_tab_del ) = 'NÃO'
		 BEGIN 
		 SET @error = ('0100')
		 SET @error_message = 'Campo de usuário/ nº da OS - Linha: Informa nº de OS se houver e atualizar Verificar nº OS = SIM !'
		 End
	End
		IF (@object_type in ('22')  AND @transaction_type  in ('A','U'))
		BEGIN
		  IF ( select U_verificarCC from OPOR where DocEntry = @list_of_cols_val_tab_del ) = 'NÃO'
		 BEGIN 
		 SET @error = ('0101')
		 SET @error_message = 'Campo de usuário/ nº da OS - Linha: Informa Centro de Custo se houver e atualizar Verificar Centro de Custo = SIM !'
		 End
	End


/*********************** Centro de Custo  e nº da OS Entrega ***********************************/
	IF (@object_type in ('15')  AND @transaction_type  in ('A','U'))
		BEGIN
		  IF ( select U_VerificarOS from ODLN where DocEntry = @list_of_cols_val_tab_del ) = 'NÃO'
		 BEGIN 
		 SET @error = ('0100')
		 SET @error_message = 'Campo de usuário/ nº da OS - Linha: Informa nº de OS se houver e atualizar Verificar nº OS = SIM !'
		 End
	End
		IF (@object_type in ('15')  AND @transaction_type  in ('A','U'))
		BEGIN
		  IF ( select U_verificarCC from ODLN where DocEntry = @list_of_cols_val_tab_del ) = 'NÃO'
		 BEGIN 
		 SET @error = ('0101')
		 SET @error_message = 'Campo de usuário/ nº da OS - Linha: Informa Centro de Custo se houver e atualizar Verificar Centro de Custo = SIM !'
		 End
	End

/*********************** Centro de Custo  e nº da OS Recebimento de mercadoria ***********************************/
	IF (@object_type in ('20')  AND @transaction_type  in ('A','U'))
		BEGIN
		  IF ( select U_VerificarOS from OPDN where DocEntry = @list_of_cols_val_tab_del ) = 'NÃO'
		 BEGIN 
		 SET @error = ('0100')
		 SET @error_message = 'Campo de usuário/ nº da OS - Linha: Informa nº de OS se houver e atualizar Verificar nº OS = SIM !'
		 End
	End
		IF (@object_type in ('20')  AND @transaction_type  in ('A','U'))
		BEGIN
		  IF ( select U_verificarCC from OPDN where DocEntry = @list_of_cols_val_tab_del ) = 'NÃO'
		 BEGIN 
		 SET @error = ('0101')
		 SET @error_message = 'Campo de usuário/ nº da OS - Linha: Informa Centro de Custo se houver e atualizar Verificar Centro de Custo = SIM !'
		 End
	End

--SET @error = '1'
--SET @error_message = 'obj ' + @object_type
--SET @error_message = 'id ' + @list_of_cols_val_tab_del

-- Select the return values
select @error, @error_message

end