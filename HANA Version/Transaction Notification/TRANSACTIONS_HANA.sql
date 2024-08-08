CREATE PROCEDURE SBO_SP_TransactionNotification
(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255)
)
LANGUAGE SQLSCRIPT
AS
-- Return values
error  int;				-- Result (0 for no error)
error_message nvarchar (200); 		-- Error string to be displayed
cnt int;				-- Count Variable
txt nvarchar(30);			-- Text Variable
companyDbIntBank nvarchar(128);
currDbNameForTaxOne nvarchar(128);
begin

error := 0;
error_message := N'Ok';

--------------------------------------------------------------------------------------------------------------------------------

--	ADD	YOUR	CODE	HERE

--------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR OFERTA DE COMPRAS DE ITENS ADMINISTRATIVOS NÃO VINCULADAS A UMA SOLICITAÇÃO DE COMPRAS
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 11/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '540000006' AND (:transaction_type ='A' OR :transaction_type ='U')
THEN
 SELECT count(*) into cnt 
 FROM PQT1 T0 INNER JOIN OITM T1 ON T1."ItemCode" = T0."ItemCode"
 WHERE T0."DocEntry" = :list_of_cols_val_tab_del and (IFNULL(T0."BaseRef",'') = '' or T0."BaseType" <> '1470000113')
 AND (T1."U_RBH_TipItem" = 'ADM' OR IFNULL(T1."U_RBH_TipItem",'') = '');
 IF :cnt > 0
 THEN
  error := 1;
  error_message := ' [TRAVA-001] - SOLICITAÇÃO DE COMPRA NÃO IDENTIFICADA, GERE A OFERTA DE COMPRA A PARTIR DE UMA SOLICITAÇÃO DE COMPRA!';
 END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR PEDIDOS DE COMPRAS DE ITENS ADMINISTRATIVOS NÃO VINCULADOS A UMA OFERTA DE COMPRA
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 11/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '22' AND (:transaction_type ='A' OR :transaction_type ='U')
THEN
 SELECT count(*) into cnt 
 FROM POR1 T0 INNER JOIN OITM T1 ON T1."ItemCode" = T0."ItemCode"
 WHERE T0."DocEntry" = :list_of_cols_val_tab_del 
 and (IFNULL(T0."BaseRef",'') = '' OR T0."BaseType" <> '540000006')
 AND (T1."U_RBH_TipItem" = 'ADM' OR IFNULL(T1."U_RBH_TipItem",'') = '');
    IF :cnt > 0
 THEN
  error := 1;
  error_message := ' [TRAVA-002] - O PEDIDO DE COMPRA OBRIGATORIAMENTE DEVE SER GERADO A PARTIR DE UMA OFERTA DE COMPRA, REVISE A OPERAÇÃO!';
 END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR RECEBIMENTO DE MERCADORIAS NÃO VINCULADOS A UM PEDIDO DE COMPRA
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 11/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '20' AND (:transaction_type ='A' OR :transaction_type ='U')
THEN
 SELECT count(*) into cnt 
 FROM PDN1 T0
 WHERE T0."DocEntry" = :list_of_cols_val_tab_del 
 and (IFNULL(T0."BaseRef",'') = '' OR T0."BaseType" NOT IN ('22','20'));
    IF :cnt > 0
 THEN
  error := 1;
  error_message := ' [TRAVA-003] - O RECEBIMENTO DE MERCADORIAS OBRIGATORIAMENTE DEVE SER GERADO A PARTIR DE UM PEDIDO DE COMPRA, REVISE A OPERAÇÃO!';
 END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR NOTA FISCAL DE ENTRADA NÃO VINCULADA A UM RECEBIMENTO DE MERCADORIAS OU A UMA TRANSAÇÃO RECORRENTE
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 11/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '18' AND :transaction_type = 'A'
THEN
 SELECT count(*) into cnt 
 FROM PCH1 T0 INNER JOIN OPCH T1 ON T1."DocEntry" = T0."DocEntry" 
 WHERE T0."DocEntry" = :list_of_cols_val_tab_del
 and (IFNULL(T0."BaseRef",'') = '' OR T0."BaseType" NOT IN ('20','18'))
 AND IFNULL((SELECT 1 FROM ORCP TA WHERE TA."DocObjType" = T0."ObjType" and TA."DraftEntry" = T1."draftKey"),0) = 0;
 IF :cnt > 0
 THEN
  error := 1;
  error_message := ' [TRAVA-004] - A NOTA FISCAL DE ENTRADA OBRIGATORIAMENTE DEVE SER GERADA A PARTIR DE UM RECEBIMENTO DE MERCADORIAS OU A PARTIR DE UMA TRANSAÇÃO RECORRENTE, REVISE A OPERAÇÃO!';
 END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE USUÁRIOS NÃO AUTORIZADOS DE SALVAR OU ATUALIZAR CADASTROS DE FORNECEDORES
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 11/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '2' AND (:transaction_type ='A' OR :transaction_type ='U') THEN 
SELECT COUNT(*) INTO cnt FROM OUSR WHERE "USERID" = 
(SELECT IFNULL("UserSign2","UserSign") from OCRD Where "CardCode" = :list_of_cols_val_tab_del AND "validFor" = 'Y' AND "CardType" = 'S')
AND IFNULL("U_RBH_Aprov",'N') = 'N';
IF :cnt > 0 
THEN 
error := 1;
error_message := ' [TRAVA-005] - SEU USUÁRIO NÃO TEM PERMISSÃO PARA SALVAR OU ATUALIZAR O CADASTRO DE FORNECEDORES COM STATUS "ATIVO", ALTERE O STATUS DE "ATIVO" PARA "INATIVO"!';
END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE USUÁRIOS NÃO AUTORIZADOS DE SALVAR OU ATUALIZAR CADASTROS DE ITENS
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 11/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '4' AND (:transaction_type ='A' OR :transaction_type ='U') THEN 
SELECT COUNT(*) INTO cnt FROM OUSR WHERE "USERID" = 
(SELECT IFNULL("UserSign2","UserSign") from OITM Where "ItemCode" = :list_of_cols_val_tab_del AND "validFor" = 'Y')
AND IFNULL("U_RBH_Aprov",'N') = 'N';
IF :cnt > 0 
THEN 
error := 1;
error_message := ' [TRAVA-006] - SEU USUÁRIO NÃO TEM PERMISSÃO PARA SALVAR OU ATUALIZAR O CADASTRO DE ITENS COM STATUS "ATIVO", ALTERE O STATUS DE "ATIVO" PARA "INATIVO"!';
END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR PARCEIROS DE NEGÓCIOS COM CARACTERES ESPECIAIS, COM ACENTUAÇÃO, COM CAIXA BAIXA OU CEDILHA 
---				NOS CAMPOS NOME DO PN, TIPO DE LOGRADOURO, RUA, Nº, COMPLEMENTO, BAIRRO, CEP E CIDADE
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 11/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '2' AND (:transaction_type ='A' OR :transaction_type ='U') THEN 
SELECT 
	SUM((OCCURRENCES_REGEXPR('([^[:alnum:]])' IN IFNULL(T0."CardName",'1')) - 
	OCCURRENCES_REGEXPR(' ' IN IFNULL(T0."CardName",'1'))) +
	OCCURRENCES_REGEXPR('([[:lower:]])' IN IFNULL(T0."CardName",'A')) +
	(OCCURRENCES_REGEXPR('([^[:alnum:]])' IN IFNULL(T1."AddrType",'1')) - 
	OCCURRENCES_REGEXPR(' ' IN IFNULL(T1."AddrType",'1'))) +
	OCCURRENCES_REGEXPR('([[:lower:]])' IN IFNULL(T1."AddrType",'A')) +
	(OCCURRENCES_REGEXPR('([^[:alnum:]])' IN IFNULL(T1."Street",'1')) -
	OCCURRENCES_REGEXPR(' ' IN IFNULL(T1."Street",'1'))) +
	OCCURRENCES_REGEXPR('([[:lower:]])' IN IFNULL(T1."Street",'A')) +
	(OCCURRENCES_REGEXPR('([^[:alnum:]])' IN IFNULL(T1."StreetNo",'1')) -
	OCCURRENCES_REGEXPR(' ' IN IFNULL(T1."StreetNo",'1'))) +
	OCCURRENCES_REGEXPR('([[:lower:]])' IN IFNULL(T1."StreetNo",'A')) +
	(OCCURRENCES_REGEXPR('([^[:alnum:]])' IN IFNULL(T1."Building",'1')) - 
	OCCURRENCES_REGEXPR(' ' IN IFNULL(T1."Building",'1'))) +
	OCCURRENCES_REGEXPR('([[:lower:]])' IN IFNULL(T1."Building",'A')) +
	(OCCURRENCES_REGEXPR('([^[:alnum:]])' IN IFNULL(T1."ZipCode",'1')) - 
	OCCURRENCES_REGEXPR(' ' IN IFNULL(T1."ZipCode",'1'))) +
	OCCURRENCES_REGEXPR('([[:lower:]])' IN IFNULL(T1."ZipCode",'A')) +
	(OCCURRENCES_REGEXPR('([^[:alnum:]])' IN IFNULL(T1."Block",'1')) -
	OCCURRENCES_REGEXPR(' ' IN IFNULL(T1."Block",'1'))) +
	OCCURRENCES_REGEXPR('([[:lower:]])' IN IFNULL(T1."Block",'A')) +
	(OCCURRENCES_REGEXPR('([^[:alnum:]])' IN IFNULL(T1."City",'1')) -
	OCCURRENCES_REGEXPR(' ' IN IFNULL(T1."City",'1'))) +
	OCCURRENCES_REGEXPR('([[:lower:]])' IN IFNULL(T1."City",'A')))
	INTO cnt
FROM
	OCRD T0 LEFT JOIN CRD1 T1 ON T1."CardCode" = T0."CardCode" 
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del;
IF :cnt > 0 
THEN 
error := 1;
error_message := ' [TRAVA-007] - PREENCHA OS CAMPOS NOME DO PN, TIPO DE LOGRADOURO, RUA, Nº, COMPLEMENTO, BAIRRO, CEP E CIDADE COM CAIXA ALTA, SEM ACENTUAÇÕES OU CARACTERES ESPECIAIS!';
END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR CADASTRO DE ITEM COM CARACTERES ESPECIAIS, COM ACENTUAÇÃO, COM CAIXA BAIXA OU CEDILHA 
---				NO CAMPO DESCRIÇÃO
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 11/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '4' AND (:transaction_type ='A' OR :transaction_type ='U') THEN 
SELECT 
	(OCCURRENCES_REGEXPR('([^[:alnum:]])' IN IFNULL(T0."ItemName",'1')) - 
	OCCURRENCES_REGEXPR(' ' IN IFNULL(T0."ItemName",'1'))) +
	OCCURRENCES_REGEXPR('([[:lower:]])' IN IFNULL(T0."ItemName",'A'))
	INTO cnt
FROM
	OITM T0
WHERE
	T0."ItemCode" = :list_of_cols_val_tab_del;
IF :cnt > 0 
THEN 
error := 1;
error_message := ' [TRAVA-008] - PREENCHA O CAMPO DESCRIÇÃO COM CAIXA ALTA, SEM ACENTUAÇÕES OU CARACTERES ESPECIAIS!';
END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR PEDIDOS DE VENDA SE O PN FOR CLIENTE POTENCIAL
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 12/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '17' AND (:transaction_type ='A' OR :transaction_type ='U') 
THEN
SELECT 
	count(*) into cnt 
FROM 
 	ORDR T0 INNER JOIN OCRD T1 ON T1."CardCode" = T0."CardCode"
WHERE 
 	T0."DocEntry" = :list_of_cols_val_tab_del 
 	and T1."CardType" = 'L';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-009] - O PEDIDO DE VENDA NÃO PODE SER FEITO PARA CLIENTE POTENCIAL, REVISE O CADASTRO DO CLIENTE!';
 END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR COTAÇÃO DE VENDA COM PERCENTUAL DE COMISSÃO SUPERIOR A DEFINIDA NO CADASTRO DE VENDEDORES
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 12/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '23' AND (:transaction_type ='A' OR :transaction_type ='U') 
THEN
SELECT
	COUNT(*) into cnt 
FROM
	OQUT T0 INNER JOIN QUT1 T1 ON T1."DocEntry" = T0."DocEntry"
	LEFT JOIN OSLP T2 ON T2."SlpCode" = T0."SlpCode"
WHERE
	T0."DocEntry" = :list_of_cols_val_tab_del 
	AND T1."Commission" > IFNULL(T2."Commission",0);
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-010] - EXISTEM ITENS COM PERCENTUAL DE COMISSÃO SUPERIOR LIMITE PERMITIDO, AJUSTE O PERCENTUAL DE COMISSÃO!';
 END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR PEDIDO DE VENDA COM PERCENTUAL DE COMISSÃO SUPERIOR A DEFINIDA NO CADASTRO DE VENDEDORES
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 12/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '17' AND (:transaction_type ='A' OR :transaction_type ='U') 
THEN
SELECT
	COUNT(*) into cnt 
FROM
	ORDR T0 INNER JOIN RDR1 T1 ON T1."DocEntry" = T0."DocEntry"
	LEFT JOIN OSLP T2 ON T2."SlpCode" = T0."SlpCode"
WHERE
	T0."DocEntry" = :list_of_cols_val_tab_del 
	AND T1."Commission" > IFNULL(T2."Commission",0);
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-011] - EXISTEM ITENS COM PERCENTUAL DE COMISSÃO SUPERIOR LIMITE PERMITIDO, AJUSTE O PERCENTUAL DE COMISSÃO!';
 END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR PEDIDO DE VENDA COM QUANTIDADES SUPERIORES AS DISPONÍVEIS EM ESTOQUE
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 12/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '17' AND (:transaction_type ='A' OR :transaction_type ='U') 
THEN
SELECT
	COUNT(*) into cnt 
FROM
	RDR1 T1 INNER JOIN OITW T2 ON T2."ItemCode" = T1."ItemCode" AND T2."WhsCode" = T1."WhsCode" 
WHERE
	T1."DocEntry" = :list_of_cols_val_tab_del 
	AND (T2."OnHand" - T2."IsCommited") < 0;
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-012] - EXISTEM ITENS COM QUANTIDADES SUPERIORES AS DISPONÍVEIS NO ESTOQUE, REVISE AS QUANTIDADES!';
 END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE O SALVAMENTO DA ENTREGA QUANDO CAMPO QUANTIDADE DE EMBALAGENS FOR NULO OU IGUAL A ZERO
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 12/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '15' AND (:transaction_type ='A' OR :transaction_type ='U') 
THEN
SELECT
	COUNT(*) into cnt
FROM
	ODLN T0 LEFT JOIN DLN12 T1 ON T1."DocEntry" = T0."DocEntry"
WHERE
	T0."DocEntry" = :list_of_cols_val_tab_del
	AND (T1."QoP" IS NULL OR T1."QoP" = 0);
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-013] - O CAMPO QUANTIDADE DE EMBALANGENS NA ABA IMPOSTO NÃO PODE FICAR VAZIO, EXECUTE A CONSULTA VINCULADA NO CAMPO!';
 END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE O SALVAMENTO DA NOTA DE SAÍDA QUANDO CAMPO QUANTIDADE DE EMBALAGENS FOR NULO OU IGUAL A ZERO
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 12/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '13' AND (:transaction_type ='A' OR :transaction_type ='U') 
THEN
SELECT
	COUNT(*) into cnt
FROM
	OINV T0 LEFT JOIN INV12 T1 ON T1."DocEntry" = T0."DocEntry"
WHERE
	T0."DocEntry" = :list_of_cols_val_tab_del
	AND (T1."QoP" IS NULL OR T1."QoP" = 0);
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-014] - O CAMPO QUANTIDADE DE EMBALANGENS NA ABA IMPOSTO NÃO PODE FICAR VAZIO, EXECUTE A CONSULTA VINCULADA NO CAMPO!';
 END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR E ATUALIZAR PN SEM A DEFINIÇÃO DO CAMPO U_RBH_TipPN
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 12/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '2' AND (:transaction_type ='A' OR :transaction_type ='U')
THEN
SELECT 
	count(*) into cnt 
FROM
	OCRD
WHERE
	"CardCode" = :list_of_cols_val_tab_del
	AND ("U_RBH_TipPN" IS NULL OR "U_RBH_TipPN" = 99);
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-015] - NECESSÁRIO SELECIONAR NO CAMPO "TIPO PN" NA ABA GERAL AS OPÇÕES "PN FISCAL" OU "PN NÃO FISCAL"!';
 END IF;
END IF;
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR E ATUALIZAR CLIENTE E FORNECEDOR DO TIPO "FISCAL" SEM OS DADOS FISCAIS
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 12/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '2' AND (:transaction_type ='A' OR :transaction_type ='U')
THEN
SELECT 
	count(*) into cnt 
FROM
	OCRD T0 
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" <> 'L'
	AND IFNULL(T0."CardName",'') = ''
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-016] - O NOME DO PN É OBRIGATÓRIO, PREENCHA O CAMPO!';
 END IF;
 
SELECT 
	count(*) into cnt 
FROM
	OCRD T0 
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" <> 'L'
	AND (IFNULL(T0."Phone1",'') <> '' OR IFNULL(T0."Phone2",'') <> '')
	AND (LENGTH(T0."Phone1") < 6 OR LENGTH(T0."Phone1") > 14 OR LENGTH(T0."Phone2") < 6 OR LENGTH(T0."Phone2") > 14)
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-017] - EM CASO DE PREENCHIMENTO DOS CAMPOS "TELEFONE 1" OU "TELEFONE 2" NA ABA GERAL, OS MESMOS DEVEM TER ENTRE 6 A 14 CARACTERES!';
 END IF;
 
 SELECT 
	count(*) into cnt 
FROM
	OCRD T0 
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" <> 'L'
	AND (IFNULL(T0."ShipToDef",'') = '' OR IFNULL(T0."BillToDef",'') = '')
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-018] - O PARCEIRO DE NEGÓCIOS DEVE POSSUIR PELO MENOS 2 ENDEREÇOS CADASTRADOS, UM COMO ENDEREÇO DE COBRANÇA E OUTRO COMO ENDEREÇO DE ENTREGA!';
END IF;
 
SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD1 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" <> 'L'
	AND T1."Address" = T0."BillToDef"
	AND T0."U_RBH_TipPN" = '01'
	AND T1."Country" = 'BR'
	AND
	(IFNULL(T1."AddrType",'') = '' OR
	 IFNULL(T1."Street",'') = '' OR
	 IFNULL(T1."StreetNo",'') = '' OR
	 IFNULL(T1."Block",'') = '' OR
	 IFNULL(T1."ZipCode",'') = '' OR
	 IFNULL(T1."City",'') = '' OR
	 IFNULL(T1."State",'') = '' OR
	 IFNULL(T1."County",'') = ''
	 );
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-019] - NO ENDEREÇO DE COBRANÇA PADRÃO OS CAMPOS "TIPO DE LOGRADOURO", "RUA", "Nº", "BAIRRO", "CEP", "CIDADE", "ESTADO" E "MUNICÍPIO" DEVEM SER PREENCHIDOS!';
END IF;

SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD1 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" <> 'L'
	AND T1."Address" = T0."BillToDef"
	AND T1."Country" = 'BR'
	AND LENGTH(T1."ZipCode") <> 10
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-020] - NO ENDEREÇO DE COBRANÇA PADRÃO PREENCHA O CAMPO "CEP" COM 10 DÍGITOS!';
END IF;

SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD1 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" <> 'L'
	AND T1."Address" = T0."ShipToDef"
	AND T0."U_RBH_TipPN" = '01'
	AND T1."Country" = 'BR'
	AND
	(IFNULL(T1."AddrType",'') = '' OR
	 IFNULL(T1."Street",'') = '' OR
	 IFNULL(T1."StreetNo",'') = '' OR
	 IFNULL(T1."Block",'') = '' OR
	 IFNULL(T1."ZipCode",'') = '' OR
	 IFNULL(T1."City",'') = '' OR
	 IFNULL(T1."State",'') = '' OR
	 IFNULL(T1."County",'') = ''
	 );
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-021] - NO ENDEREÇO DE ENTREGA PADRÃO OS CAMPOS "TIPO DE LOGRADOURO", "RUA", "Nº", "BAIRRO", "CEP", "CIDADE", "ESTADO" E "MUNICÍPIO" DEVEM SER PREENCHIDOS!';
END IF;
 
SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD1 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" <> 'L'
	AND T1."Address" = T0."ShipToDef"
	AND T1."Country" = 'BR'
	AND LENGTH(T1."ZipCode") <> 8
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-022] - NO ENDEREÇO DE ENTREGA PADRÃO PREENCHA O CAMPO "CEP" COM 8 DÍGITOS!';
END IF;

SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD7 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" = 'C'
	AND T1."Address" = T0."ShipToDef"
	AND (IFNULL(T1."TaxId0",'') = '' AND IFNULL(T1."TaxId4",'') = '')
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-023] - PREENCHA O "CPF" OU "CNPJ"!';
END IF;

SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD7 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" = 'C'
	AND T1."Address" = T0."ShipToDef"
	AND (IFNULL(T1."TaxId0",'') <> '' AND IFNULL(T1."TaxId4",'') <> '')
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-024] - AMBOS OS CAMPOS "CPF" E "CNPJ" FORAM PREENCHIDOS, PREENCHA APENAS UM DOS DOIS!';
END IF;

SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD7 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" = 'C'
	AND T1."Address" = T0."ShipToDef"
	AND ((IFNULL(T1."TaxId0",'') <> '' AND IFNULL(T1."TaxId4",'') = '' AND OCCURRENCES_REGEXPR('([[:digit:]])' IN IFNULL(T1."TaxId0",'A')) <> 14) 
	OR (IFNULL(T1."TaxId4",'') <> '' AND IFNULL(T1."TaxId0",'') = '' AND OCCURRENCES_REGEXPR('([[:digit:]])' IN IFNULL(T1."TaxId4",'A')) <> 11))
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-025] - O "CPF" DEVE POSSUIR 11 DÍGITOS NUMÉRICOS E O "CNPJ" 14 DÍGITOS NUMÉRICOS, REVISE O PREENCHIMENTO!';
END IF; 

SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD7 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" = 'S'
	AND IFNULL(T1."Address",'') = ''
	AND (IFNULL(T1."TaxId0",'') = '' AND IFNULL(T1."TaxId4",'') = '')
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-026] - PREENCHA O "CPF" OU "CNPJ"!';
END IF;

SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD7 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" = 'S'
	AND IFNULL(T1."Address",'') = ''
	AND (IFNULL(T1."TaxId0",'') <> '' AND IFNULL(T1."TaxId4",'') <> '')
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-027] - AMBOS OS CAMPOS "CPF" E "CNPJ" FORAM PREENCHIDOS, PREENCHA APENAS UM DOS DOIS!';
END IF;

SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD7 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" = 'S'
	AND IFNULL(T1."Address",'') = ''
	AND ((IFNULL(T1."TaxId0",'') <> '' AND IFNULL(T1."TaxId4",'') = '' AND OCCURRENCES_REGEXPR('([[:digit:]])' IN IFNULL(T1."TaxId0",'A')) <> 14) 
	OR (IFNULL(T1."TaxId4",'') <> '' AND IFNULL(T1."TaxId0",'') = '' AND OCCURRENCES_REGEXPR('([[:digit:]])' IN IFNULL(T1."TaxId4",'A')) <> 11))
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-028] - O "CPF" DEVE POSSUIR 11 DÍGITOS NUMÉRICOS E O "CNPJ" 14 DÍGITOS NUMÉRICOS, REVISE O PREENCHIMENTO!';
END IF; 

SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD7 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" = 'S'
	AND IFNULL(T1."Address",'') = ''
	AND IFNULL(T1."TaxId1",'') = ''
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-029] - A "INSCRIÇÃO ESTADUAL" DEVE SER PREENCHIDA OU DEVE SER SELECIONADA A OPÇÃO "ISENTO"!';
END IF;

SELECT 
	count(*) into cnt 
FROM
	OCRD T0 LEFT JOIN CRD7 T1 ON T1."CardCode" = T0."CardCode"
WHERE
	T0."CardCode" = :list_of_cols_val_tab_del 
	AND T0."CardType" = 'C'
	AND T1."Address" = T0."ShipToDef" 
	AND IFNULL(T1."TaxId1",'') = ''
	AND T0."U_RBH_TipPN" = '01';
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-030] - A "INSCRIÇÃO ESTADUAL" DEVE SER PREENCHIDA OU DEVE SER SELECIONADA A OPÇÃO "ISENTO"!';
END IF;

END IF;

--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR COTAÇÃO DE VENDAS SEM A COBRANÇA DE FRETE QUANDO O VALOR DO DOCUMENTO FOR INFERIOR AO VALOR MÍNIMO
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 12/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '23' AND (:transaction_type ='A' OR :transaction_type ='U')
THEN
SELECT
	count(*) into cnt 
FROM
	OQUT T0 LEFT JOIN QUT3 T1 ON T1."DocEntry" = T0."DocEntry" AND T1."ExpnsCode" = 1
	LEFT JOIN OCRD T2 ON T2."CardCode" = T0."CardCode"
WHERE
	T0."DocEntry" = :list_of_cols_val_tab_del
	AND IFNULL(T1."LineTotal",0) < IFNULL(T2."U_RBH_ValFrete",0)
	AND (T0."DocTotal" - IFNULL(T1."LineTotal",0))  < IFNULL(T2."U_RBH_ValFretGrt",0);
SELECT 
	LEFT(REPLACE(CAST(T1."U_RBH_ValFrete" AS NVARCHAR(50)),'.',','),
	LENGTH(REPLACE(CAST(T1."U_RBH_ValFrete" AS NVARCHAR(50)),'.',','))-4) into txt
FROM 
	OQUT T0 INNER JOIN OCRD T1 ON T1."CardCode" = T0."CardCode" 
WHERE 
T0."DocEntry" = :list_of_cols_val_tab_del;
	
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-031] - O VALOR TOTAL DESSE DOCUMENTO REQUER A INCLUSÃO DA COBRANÇA DE FRETE QUE PARA ESSE CLIENTE É DE R$ '
  || txt || ' !';
END IF;
END IF;	
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR PEDIDO DE VENDAS SEM A COBRANÇA DE FRETE QUANDO O VALOR DO DOCUMENTO FOR INFERIOR AO VALOR MÍNIMO
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 12/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '17' AND (:transaction_type ='A' OR :transaction_type ='U')
THEN
SELECT
	count(*) into cnt 
FROM
	ORDR T0 LEFT JOIN RDR3 T1 ON T1."DocEntry" = T0."DocEntry" AND T1."ExpnsCode" = 1
	LEFT JOIN OCRD T2 ON T2."CardCode" = T0."CardCode"
WHERE
	T0."DocEntry" = :list_of_cols_val_tab_del
	AND IFNULL(T1."LineTotal",0) < IFNULL(T2."U_RBH_ValFrete",0)
	AND (T0."DocTotal" - IFNULL(T1."LineTotal",0))  < IFNULL(T2."U_RBH_ValFretGrt",0);
SELECT 
	LEFT(REPLACE(CAST(T1."U_RBH_ValFrete" AS NVARCHAR(50)),'.',','),
	LENGTH(REPLACE(CAST(T1."U_RBH_ValFrete" AS NVARCHAR(50)),'.',','))-4) into txt
FROM 
	ORDR T0 INNER JOIN OCRD T1 ON T1."CardCode" = T0."CardCode" 
WHERE 
T0."DocEntry" = :list_of_cols_val_tab_del;
	
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-032] - O VALOR TOTAL DESSE DOCUMENTO REQUER A INCLUSÃO DA COBRANÇA DE FRETE QUE PARA ESSE CLIENTE É DE R$ '
  || txt || ' !';
END IF;
END IF;	
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
--- FINALIDADE: IMPEDE SALVAR NOTA DE SAÍDA SEM A COBRANÇA DE FRETE QUANDO O VALOR DO DOCUMENTO FOR INFERIOR AO VALOR MÍNIMO
--- AUTOR: JÔNATAS SOUZA 
--- DATA: 12/11/2020
--------------------------------------------------------------------------------------------------------------------------------

IF :object_type = '13' AND (:transaction_type ='A' OR :transaction_type ='U')
THEN
SELECT
	count(*) into cnt 
FROM
	OINV T0 LEFT JOIN INV3 T1 ON T1."DocEntry" = T0."DocEntry" AND T1."ExpnsCode" = 1
	LEFT JOIN OCRD T2 ON T2."CardCode" = T0."CardCode"
WHERE
	T0."DocEntry" = :list_of_cols_val_tab_del
	AND IFNULL(T1."LineTotal",0) < IFNULL(T2."U_RBH_ValFrete",0)
	AND (T0."DocTotal" - IFNULL(T1."LineTotal",0))  < IFNULL(T2."U_RBH_ValFretGrt",0);
SELECT 
	LEFT(REPLACE(CAST(T1."U_RBH_ValFrete" AS NVARCHAR(50)),'.',','),
	LENGTH(REPLACE(CAST(T1."U_RBH_ValFrete" AS NVARCHAR(50)),'.',','))-4) into txt
FROM 
	OINV T0 INNER JOIN OCRD T1 ON T1."CardCode" = T0."CardCode" 
WHERE 
T0."DocEntry" = :list_of_cols_val_tab_del;
	
IF :cnt > 0
THEN
  error := 1;
  error_message := ' [TRAVA-033] - O VALOR TOTAL DESSE DOCUMENTO REQUER A INCLUSÃO DA COBRANÇA DE FRETE QUE PARA ESSE CLIENTE É DE R$ '
  || txt || ' !';
END IF;
END IF;	
--------------------------------------------------------------------------------------------------------------------------------


-- Select the return values
select :error, :error_message FROM dummy;

end;