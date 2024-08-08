

-- 01 - ITENS E DEPÓSITOS COM SALDOS


DECLARE @IGN1_DTW AS TABLE (DocNUm INT,LineNum INT,ItemCode Nvarchar(50),Quantity Numeric(19,6),WhsCode Nvarchar(8),PriceBefDi Numeric(19,6))

INSERT INTO @IGN1_DTW

SELECT 



ROW_NUMBER() OVER(ORDER BY T0.ItemCode ASC),
0 'LineNum',
T0.ItemCode,
T0.OnHand,
T0.WhsCode,
T0.AvgPrice


FROM

OITW T0 INNER JOIN OITM T1 ON T1.ItemCode = T0.ItemCode

WHERE

T0.OnHand > 0


-- 02 - LOTES COM SALDO DA QUERY ANTERIOR

DECLARE @BTNT_DTW AS TABLE 

(DocNum INT,LineNum INT,DistNumber NVARCHAR(36),MnfSerial NVARCHAR(36),LotNumber NVARCHAR(36),ExpDate NVARCHAR(8),MnfDate NVARCHAR(8),InDate NVARCHAR(8),Location NVARCHAR(100),Notes text,
Quantity numeric(19,6),DocLineNum INT)

INSERT INTO @BTNT_DTW

SELECT 
t0.DocNUm,
ROW_NUMBER() OVER(PARTITION BY T0.docnum ORDER BY T2.DISTNUMBER) -1 
,T2.DistNumber,T2.MnfSerial,T2.LotNumber,REPLACE(CAST(T2.ExpDate AS DATE),'-',''),REPLACE(CAST(T2.MnfDate AS DATE),'-',''),REPLACE(CAST(T2.InDate AS DATE),'-',''),
T2.Location,CAST(T2.Notes AS VARCHAR(MAX)),SUM(T1.Quantity),T0.LineNum

FROM 
@IGN1_DTW T0 INNER JOIN ITL1 T1 ON T1.ItemCode = T0.ItemCode INNER JOIN OITL T3 ON T3.LogEntry = T1.LogEntry AND T3.LocCode = T0.WhsCode
INNER JOIN OBTN T2 ON T2.AbsEntry = T1.MdAbsEntry


GROUP BY t0.DocNUm,T2.DistNumber,T2.MnfSerial,T2.LotNumber,T2.ExpDate,T2.MnfDate,T2.InDate,T2.Location,CAST(T2.Notes AS VARCHAR(MAX)),T0.LineNum

HAVING SUM(T1.Quantity) > 0

ORDER BY T0.DocNUm


-- 03 - POSIÇÕES COM SALDO E POSIÇÕES COM LOTES E SALDO

DECLARE @IGN19_DTW AS TABLE (DocNum INT,[LineNo] INT,BinAbs INT,Quantity NUMERIC(19,6),AllowNeg NVARCHAR(3),SnBMDAbs INT,LineNum INT)

INSERT @IGN19_DTW

SELECT 
t0.DocNUm,
'',
(SELECT TA.AbsEntry FROM OBIN TA WHERE TA.BinCode = T3.BinCode),
ISNULL(T2.OnHandQty,T1.OnHandQty),
'tNO',
T5.LineNum,
T0.LineNum


FROM

@IGN1_DTW T0 INNER JOIN OIBQ T1 ON T0.ItemCode = T1.ItemCode AND T1.WhsCode = T0.WhsCode
LEFT JOIN OBBQ T2 ON T1.ItemCode = T2.ItemCode AND T1.BinAbs = T2.BinAbs AND T1.WhsCode = T2.WhsCode AND T2.OnHandQty > 0
INNER JOIN OBIN T3 ON T3.AbsEntry = T1.BinAbs
LEFT JOIN OBTN T4 ON T4.AbsEntry = T2.SnBMDAbs
LEFT JOIN @BTNT_DTW T5 ON T5.DistNumber = T4.DistNumber AND T5.DocLineNum = T0.LineNum AND T5.DOCNUM = T0.DocNUm
WHERE

 T1.OnHandQty > 0



ORDER BY T0.DocNUm,T5.LineNum


SELECT * FROM @IGN1_DTW
SELECT * FROM @BTNT_DTW
Select * from @IGN19_DTW 

