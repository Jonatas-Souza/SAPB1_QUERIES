--SELECT TOP 1 1 FROM OFPR T0, OITM T1, OADT T2, ITM7 T3 WHERE T0."Category" = '[%0]'
--AND T0."Code" >= '[%1]'
--AND  T0."Code" <= '[%2]'
--AND T1."AssetClass" >= '[%3]'
--AND T1."AssetClass" <= '[%4]'
--AND  T2."BalanceAct" = '[%5]' 
--AND  T3."DprArea" = '[%6]'

DECLARE Ano INT;
DECLARE Mes01 VARCHAR(7);
DECLARE Mes02 VARCHAR(7);
DECLARE CttBlc VARCHAR(15);
DECLARE Classe01 VARCHAR(20);
DECLARE Classe02 VARCHAR(20);
DECLARE Area VARCHAR(15);

Ano   := '[%0]';
Mes01 := '[%1]';
Mes02 := '[%2]';
Classe01 := '[%3]';
Classe01 := '[%4]';
CttBlc :=  '[%5]';
Area :=  '[%6]';

SELECT
	T2."BalanceAct" AS "Conta do balanço",
	T3."AcctName" AS "Nome da conta",
	T0."ItemCode" AS "Ativo nº",
	T0."ItemName" AS "Denominação do imobilizado",
	T0."InventryNo" AS "Nº inventário",
	T0."AssetSerNo" AS "Nº de série",
	T4."Location" AS "Localização",
	ifnull(T5."firstName" || ' ','') || ifnull(T5."middleName" || ' ','') || ifnull(T5."lastName" || ' ','') AS "Colaborador",
	T0."U_RBH_AtvFixNf" AS "Nota fiscal",
	CASE WHEN T0."U_RBH_Criticidade" = 'B' THEN 'BAIXA'
		 WHEN T0."U_RBH_Criticidade" = 'M' THEN 'MÉDIA'
		 WHEN T0."U_RBH_Criticidade" = 'M' THEN 'ALTA' END AS "Classificação de criticidade",
	T0."CapDate" AS "Data de incorporação",
	T6."DprStart" AS "Data de início da depreciação",
	T6."UsefulLife" AS "Vida útil",
	CASE WHEN T6."UsefulLife"-(MONTHS_BETWEEN(T6."DprStart",LAST_DAY(TO_DATE(CAST(Ano AS VARCHAR) || RIGHT(Mes02,2) || '01')))+1) < 0 THEN 0
	ELSE T6."UsefulLife"-(MONTHS_BETWEEN(T6."DprStart",LAST_DAY(TO_DATE(CAST(Ano AS VARCHAR) || RIGHT(Mes02,2) || '01')))+1) END AS "Vida útil restante",
	T7."APC" + 
	IFNULL((select sum(te."LineTotal") from OACQ td inner join acq1 te on td."DocEntry" = te."DocEntry"
	where te."ItemCode" = T0."ItemCode" and td."DocStatus" <> 'C' AND td."PostDate" >= TO_DATE(CAST(Ano AS VARCHAR) || '0101') AND td."PostDate" < TO_DATE(Mes01 || '-01')),0.00)
	AS "CAP na data de início",
	T7."OrDpAcc" +
	IFNULL((SELECT SUM(TA."OrdDprPost" + TA."SpDprPost") FROM ODPV TA WHERE TA."PeriodCat" = Ano AND TA."ItemCode" = T0."ItemCode" AND TA."ToDate" < TO_DATE(Mes01 || '-01')),0.00)
	AS "Depreciação acumulada na data início",
	(select sum(te."LineTotal") from OACQ td inner join acq1 te on td."DocEntry" = te."DocEntry"
	where te."ItemCode" = T0."ItemCode" and td."DocStatus" <> 'C' AND td."PostDate" BETWEEN TO_DATE(Mes01 || '-01') AND LAST_DAY(TO_DATE(Mes02 || '-01'))) AS "Capitalização",
	CASE WHEN (select count(td."DocNum") from ORTI td inner join RTI1 te on td."DocEntry" = te."DocEntry"
	where te."ItemCode" = T0."ItemCode" and td."DocStatus" <> 'C') > 0 THEN T7."APC" ELSE 0.00 END AS "APC baixado",
	(SELECT SUM(TA."OrdDprPost" + TA."SpDprPost") FROM ODPV TA WHERE TA."PeriodCat" = Ano AND TA."ItemCode" = T0."ItemCode" AND TA."FromDate" >= TO_DATE(Mes01 || '-01') AND TA."ToDate" <= LAST_DAY(TO_DATE(Mes02 || '-01'))) AS "Depreciação",
	T7."APC" + 
	ifnull((select sum(te."LineTotal") from OACQ td inner join acq1 te on td."DocEntry" = te."DocEntry"
	where te."ItemCode" = T0."ItemCode" and td."DocStatus" <> 'C' AND td."PostDate" BETWEEN TO_DATE(CAST(Ano AS VARCHAR) || '0101') AND LAST_DAY(TO_DATE(Mes02 || '-01'))),0.00) - 
	(CASE WHEN (select count(td."DocNum") from ORTI td inner join RTI1 te on td."DocEntry" = te."DocEntry"
	where te."ItemCode" = T0."ItemCode" and td."DocStatus" <> 'C') > 0 THEN T7."APC" ELSE 0.00 END) AS "CAP na data de término",
	T7."APC" + 
	ifnull((select sum(te."LineTotal") from OACQ td inner join acq1 te on td."DocEntry" = te."DocEntry"
	where te."ItemCode" = T0."ItemCode" and td."DocStatus" <> 'C' AND td."PostDate" BETWEEN TO_DATE(CAST(Ano AS VARCHAR) || '0101') AND LAST_DAY(TO_DATE(Mes02 || '-01'))),0.00) - 
	(CASE WHEN (select count(td."DocNum") from ORTI td inner join RTI1 te on td."DocEntry" = te."DocEntry"
	where te."ItemCode" = T0."ItemCode" and td."DocStatus" <> 'C') > 0 THEN T7."APC" ELSE 
	ifnull((SELECT SUM(TA."OrdDprPost" + TA."SpDprPost") FROM ODPV TA WHERE TA."PeriodCat" = Ano AND TA."ItemCode" = T0."ItemCode"),0.00) +
	T7."OrDpAcc" END) AS "Valor contábil na data de término",
	(CASE WHEN (select count(td."DocNum") from ORTI td inner join RTI1 te on td."DocEntry" = te."DocEntry"
	where te."ItemCode" = T0."ItemCode" and td."DocStatus" <> 'C') > 0 THEN 0.00 ELSE 
	ifnull((SELECT SUM(TA."OrdDprPost" + TA."SpDprPost") FROM ODPV TA WHERE TA."PeriodCat" = Ano AND TA."ItemCode" = T0."ItemCode"),0.00) +
	T7."OrDpAcc" END)
	AS "Depreciação na data de término",
	T7."OrDpAcc" + ifnull((SELECT SUM(TA."OrdDprPost" + TA."SpDprPost") FROM ODPV TA WHERE TA."PeriodCat" = Ano AND TA."ItemCode" = T0."ItemCode"),0.00)
	AS "Depreciação acum.dt.térm."

FROM
	OITM T0 LEFT JOIN ACS1 T1 ON T1."Code" = T0."AssetClass"
	LEFT JOIN OADT T2 ON T2."Code" = T1."AcctDtn"
	LEFT JOIN OACT T3 ON T3."AcctCode" = T2."BalanceAct"
	LEFT JOIN OLCT T4 ON T4."Code" = T0."Location"
	LEFT JOIN OHEM T5 ON T5."empID" = T0."Employee"
	LEFT JOIN ITM7 T6 ON T6."ItemCode" = T0."ItemCode"
	LEFT JOIN ITM8 T7 ON T7."ItemCode" = T0."ItemCode"
WHERE
	T0."ItemType" = 'F'
	AND ((T0."AsstStatus" = 'A') OR (CAST(T0."RetDate" AS DATE) BETWEEN TO_DATE(Mes01 || '-01') AND LAST_DAY(TO_DATE(Mes02 || '-01'))))
	AND T6."PeriodCat" = Ano
	AND T7."PeriodCat" = Ano
	AND T2."BalanceAct" = (CASE WHEN IFNULL(CttBlc,'') = '' THEN T2."BalanceAct" ELSE CttBlc END)
	AND T0."AssetClass" >= (CASE WHEN IFNULL(Classe01,'') = '' THEN T0."AssetClass" ELSE Classe01 END)
	AND T0."AssetClass" <= (CASE WHEN IFNULL(Classe02,'') = '' THEN T0."AssetClass" ELSE Classe02 END)
	AND T6."DprArea" = (CASE WHEN IFNULL(Area,'') = '' THEN T6."DprArea" ELSE Area END)
ORDER BY
	T3."AcctName",T0."ItemCode" ASC;