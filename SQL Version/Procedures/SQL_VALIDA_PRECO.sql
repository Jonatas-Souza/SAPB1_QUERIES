CREATE PROCEDURE [dbo].[RBH_PRECO_ITEM]
(
	@ListFrom CHAR(1),  -- ORIGEM DA LISTA DE PRE�O:	(P) - LISTA PADR�O DO CADASTRO DO PN		(C) - LISTA PADR�O DA CONDI��O DE PGTO 
	@CardCode VARCHAR(15),
��� @ItemCode VARCHAR(50),
	@Quantity NUMERIC(19,6),
��� @UomEntry INT,
	@GroupNum INT,
	@PriceOnList NUMERIC(19,6) OUTPUT
)

AS 


DECLARE @OITMGrpItem INT,
		@OITMFabItem INT,
		@PriceList INT,
		@OITMPriceOnList NUMERIC(19,6),
		@OEDGAbsEntry INT,
		@OEDGDiscRel CHAR(1),
		@OCRDGrpPn INT,
		@OCRDDiscRel CHAR(1),
		@OCRDNoDiscount Char(1),
		@PriceDec INT,
		@PercentDec INT;

DECLARE @CaracteristicasItem table ("IdCaract" INT);
DECLARE @GrpDesc table ("PercDisc" NUMERIC(19,6));

SELECT
	@PriceDec = "PriceDec",
	@PercentDec = "PercentDec"
FROM
	OADM;

SELECT
	@PriceList = CASE WHEN @ListFrom = 'P' THEN (SELECT "ListNum" FROM OCRD WHERE "CardCode" = @CardCode)
					  WHEN @ListFrom = 'C' THEN (SELECT "ListNum" FROM OCTG WHERE "GroupNum" = @GroupNum) END;

SELECT 
	@OITMGrpItem = T0."ItmsGrpCod",
	@OITMFabItem = T0."FirmCode",
	@OITMPriceOnList = ROUND(T1."Price",@PriceDec)
FROM 
	OITM T0 INNER JOIN ITM1 T1 ON T1."ItemCode" = T0."ItemCode"
WHERE 
	T0."ItemCode" = @ItemCode
	AND T1."PriceList" = @PriceList
	AND T1."UomEntry" = @UomEntry;

SELECT 
	@OCRDGrpPn = "GroupCode",
	@OCRDDiscRel = "DiscRel",
	@OCRDNoDiscount = "NoDiscount"
FROM 
	OCRD 
WHERE 
	"CardCode" = @CardCode;

SELECT TOP 1
	@OEDGAbsEntry = "AbsEntry",
	@OEDGDiscRel = "DiscRel"
FROM
	OEDG
WHERE
	"Type" IN ('C','S','A')
	AND (CASE WHEN "Type" IN ('C','S') THEN "ObjCode"
			  WHEN "Type" = 'A' THEN @CardCode END) IN (@OCRDGrpPn,@CardCode)
ORDER BY 
	"AbsEntry" ASC;



INSERT INTO @CaracteristicasItem 

SELECT 1 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup1" = 'Y'
UNION
SELECT 2 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup2" = 'Y'
UNION
SELECT 3 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup3" = 'Y'
UNION
SELECT 4 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup4" = 'Y'
UNION
SELECT 5 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup5" = 'Y'
UNION
SELECT 6 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup6" = 'Y'
UNION
SELECT 7 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup7" = 'Y'
UNION
SELECT 8 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup8" = 'Y'
UNION
SELECT 9 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup9" = 'Y'
UNION
SELECT 10 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup10" = 'Y'
UNION
SELECT 11 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup11" = 'Y'
UNION
SELECT 12 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup12" = 'Y'
UNION
SELECT 13 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup13" = 'Y'
UNION
SELECT 14 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup14" = 'Y'
UNION
SELECT 15 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup15" = 'Y'
UNION
SELECT 16 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup16" = 'Y'
UNION
SELECT 17 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup17" = 'Y'
UNION
SELECT 18 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup18" = 'Y'
UNION
SELECT 19 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup19" = 'Y'
UNION
SELECT 20 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup20" = 'Y'
UNION
SELECT 21 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup21" = 'Y'
UNION
SELECT 22 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup22" = 'Y'
UNION
SELECT 23 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup23" = 'Y'
UNION
SELECT 24 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup24" = 'Y'
UNION
SELECT 25 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup25" = 'Y'
UNION
SELECT 26 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup26" = 'Y'
UNION
SELECT 27 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup27" = 'Y'
UNION
SELECT 28 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup28" = 'Y'
UNION
SELECT 29 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup29" = 'Y'
UNION
SELECT 30 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup30" = 'Y'
UNION
SELECT 31 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup31" = 'Y'
UNION
SELECT 32 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup32" = 'Y'
UNION
SELECT 33 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup33" = 'Y'
UNION
SELECT 34 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup34" = 'Y'
UNION
SELECT 35 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup35" = 'Y'
UNION
SELECT 36 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup36" = 'Y'
UNION
SELECT 37 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup37" = 'Y'
UNION
SELECT 38 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup38" = 'Y'
UNION
SELECT 39 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup39" = 'Y'
UNION
SELECT 40 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup40" = 'Y'
UNION
SELECT 41 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup41" = 'Y'
UNION
SELECT 42 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup42" = 'Y'
UNION
SELECT 43 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup43" = 'Y'
UNION
SELECT 44 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup44" = 'Y'
UNION
SELECT 45 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup45" = 'Y'
UNION
SELECT 46 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup46" = 'Y'
UNION
SELECT 47 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup47" = 'Y'
UNION
SELECT 48 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup48" = 'Y'
UNION
SELECT 49 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup49" = 'Y'
UNION
SELECT 50 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup50" = 'Y'
UNION
SELECT 51 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup51" = 'Y'
UNION
SELECT 52 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup52" = 'Y'
UNION
SELECT 53 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup53" = 'Y'
UNION
SELECT 54 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup54" = 'Y'
UNION
SELECT 55 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup55" = 'Y'
UNION
SELECT 56 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup56" = 'Y'
UNION
SELECT 57 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup57" = 'Y'
UNION
SELECT 58 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup58" = 'Y'
UNION
SELECT 59 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup59" = 'Y'
UNION
SELECT 60 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup60" = 'Y'
UNION
SELECT 61 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup61" = 'Y'
UNION
SELECT 62 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup62" = 'Y'
UNION
SELECT 63 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup63" = 'Y'
UNION
SELECT 64 FROM OITM WHERE "ItemCode" = @ItemCode AND "QryGroup64" = 'Y'
;


INSERT INTO @GrpDesc

SELECT
	CAST("Discount" AS FLOAT)
FROM
	EDG1
WHERE 
	(((CASE WHEN "ObjType" = 52 THEN "ObjKey" END) = @OITMGrpItem)
	OR
	((CASE WHEN "ObjType" = 43 THEN "ObjKey" END) = @OITMFabItem)
	OR
	((CASE WHEN "ObjType" = 4 THEN "ObjKey" END) = @ItemCode))

UNION

SELECT
   CASE WHEN @OEDGDiscRel = 'L'
		THEN CAST(MIN("Discount") AS FLOAT)
		WHEN @OEDGDiscRel = 'H'
		THEN CAST(MAX("Discount") AS FLOAT)
		WHEN @OEDGDiscRel = 'A'
		THEN CAST(AVG("Discount") AS FLOAT)
		WHEN @OEDGDiscRel = 'S'
		THEN CAST(SUM("Discount") AS FLOAT)
		WHEN @OEDGDiscRel = 'M'
		THEN CAST((1.00-EXP(SUM(LOG(1.00-("Discount"/100.00)))))*100.00 AS FLOAT)
		END
FROM
	EDG1
WHERE 
	"ObjType" = 8 
	AND "ObjKey" IN (SELECT "IdCaract" FROM @CaracteristicasItem)
;

------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT
	
	@PriceOnList  =

ISNULL
(
ISNULL
(
ISNULL
(
ISNULL
(
--	1. VALIDA EXIST�NCIA DE PRE�O ESPECIAL DO PN
ISNULL
(
ISNULL
(
-- 1.1 VALIDA PRE�O ESPECIAL DO PN COM DESCONTO POR QUANTIDADE
(
SELECT TOP 1
	ROUND(T2."Price",@PriceDec)
FROM
	OSPP T0 INNER JOIN SPP1 T1 ON T0."ItemCode" = T1."ItemCode" AND T0."CardCode" = T1."CardCode"
	INNER JOIN SPP2 T2 ON T0."ItemCode" = T2."ItemCode" AND T0."CardCode" = T2."CardCode"
WHERE
	T0."CardCode" = @CardCode
	AND T0."ItemCode" = @ItemCode
	AND T2."UomEntry" = @UomEntry
	AND T2."Amount" <= @Quantity
ORDER BY
	T2."SPP2LNum" DESC
),
-- 1.2 VALIDA PRE�O ESPECIAL DO PN COM DESCONTO POR PER�ODO ESPEC�FICO
(
SELECT
	ROUND(T1."Price",@PriceDec)
FROM
	OSPP T0 INNER JOIN SPP1 T1 ON T0."ItemCode" = T1."ItemCode" AND T0."CardCode" = T1."CardCode"
WHERE
	T0."CardCode" = @CardCode
	AND T0."ItemCode" = @ItemCode
	AND ISNULL(CAST(T1."ToDate" AS DATE),CAST(GETDATE() AS DATE)) >= CAST(GETDATE() AS DATE)
)
),
-- 1.3 VALIDA PRE�O ESPECIAL DO PN SEM CONDI��ES ESPEC�FICAS
(
SELECT
	ROUND(T0."Price",@PriceDec)
FROM
	OSPP T0 
WHERE
	T0."CardCode" = @CardCode
	AND T0."ItemCode" = @ItemCode
)
),


-- 2. VALIDA EXIST�NCIA DE GRUPOS DE DESCONTO PARA TODAS AS SITUA��ES (TODOS PNs, PN ESPEC�FICO, GRUPO DE CLIENTE, GRUPO DE ITENS, CARACTER�STICAS DO ITEM, FABRICANTE E ITEM ESPEC�FICO)
(
SELECT
	CASE WHEN @OCRDNoDiscount = 'Y' THEN NULL
	ELSE
ROUND(CAST((SELECT 
		@OITMPriceOnList *
		(1.00 - 
		(ROUND((CASE WHEN @OCRDDiscRel = 'L'
		THEN CAST(MIN("PercDisc") AS FLOAT)
		WHEN @OCRDDiscRel = 'H'
		THEN CAST(MAX("PercDisc") AS FLOAT)
		WHEN @OCRDDiscRel = 'A'
		THEN CAST(AVG("PercDisc") AS FLOAT)
		WHEN @OCRDDiscRel = 'S'
		THEN CAST(SUM("PercDisc") AS FLOAT)
		WHEN @OCRDDiscRel = 'M'
		THEN CAST(EXP(SUM(LOG("PercDisc"))) AS FLOAT)
		END),@PercentDec)/ 100.00))
		
FROM
	@GrpDesc) AS NUMERIC(19,6)),@PriceDec)
END
)
),
		

-- 3. VALIDA EXIST�NCIA DE DESCONTOS POR PER�ODO E VOLUME

-- 3.1 VALIDA DESCONTOS POR QUANTIDADE

(
SELECT TOP 1
	ROUND(T2."Price",@PriceDec)
FROM
	OSPP T0 INNER JOIN SPP1 T1 ON T0."ItemCode" = T1."ItemCode" AND T0."CardCode" = T1."CardCode"
	INNER JOIN SPP2 T2 ON T0."ItemCode" = T2."ItemCode" AND T0."CardCode" = T2."CardCode"
WHERE
	T0."CardCode" LIKE '*%'�
	AND T0."ItemCode" = @ItemCode
	AND T2."UomEntry" = @UomEntry
	AND T2."Amount" <= @Quantity
	AND T0."ListNum" = @PriceList
ORDER BY
	T2."SPP2LNum" DESC
)
),

-- 3.2 VALIDA DESCONTOS POR PER�ODO ESPEC�FICO

(
SELECT
	ROUND(T1."Price",@PriceDec)
FROM
	OSPP T0 INNER JOIN SPP1 T1 ON T0."ItemCode" = T1."ItemCode" AND T0."CardCode" = T1."CardCode"
WHERE
	T0."CardCode" LIKE '*%'�
	AND T0."ItemCode" = @ItemCode
	AND ISNULL(CAST(T1."ToDate" AS DATE),CAST(GETDATE() AS DATE)) >= CAST(GETDATE() AS DATE)
	AND T0."ListNum" = @PriceList
)
),

--	4. VALIDA EXIST�NCIA DE PRE�O NA LISTA PADR�O DO PN OU DA CONDI��O DE PGTO. CONFORME PAR�METRO PASSADO NA EXECU��O DA PROCEDURE

(
 SELECT @OITMPriceOnList
)
)
;

RETURN;
