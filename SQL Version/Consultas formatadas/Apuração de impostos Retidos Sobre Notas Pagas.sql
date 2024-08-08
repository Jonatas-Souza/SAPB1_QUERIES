SELECT distinct 
T11.CardCode As 'C�digo PN',
T11.CardName AS 'Raz�o Social',
T11.TaxId0 AS 'CNPJ',
T11.TaxDate AS 'Data da Emiss�o',
T11.DocDate AS 'Data do Cont�bil',
T11.DueDate AS 'Data do Vencimento',
T11.DocDueDate AS 'Data do Pagto', 
T11.Dscription AS 'Descri��o do Servi�o',
T11.Serial AS 'N�mero da NF',
CASE
WHEN T11.NfmDescrip = 'Nota Fiscal de Servi�os Eletr�nica' THEN 'NFS-e'
ELSE
''
END AS 'S�rie',
T11.InstlmntID AS 'Parcela',


--CONVERT (NVARCHAR (15),T11.Serial) + '-' + CONVERT (NVARCHAR (15),T11.InstlmntID) 'NF e Parcela', -- Numero da Nota mais Parcela

T11.OffclCode AS 'C�digo do Imposto Oficial',
T11.BaseAmnt AS 'Valor NF',

(T11.BaseAmnt-T11.WTAmnt) AS 'VL Parcela',

CASE

WHEN GETDATE () >= T11.DueDate THEN (T11.BaseAmnt-T11.WTAmnt)
WHEN GETDATE () <= T11.DueDate THEN (T11.PaidToDate)
ELSE
''
END AS 'Valor Pago',

T11.WTCode + '-->' + T11.WTName AS 'Tipo da Reten��o',
T11.WTAmnt AS 'Valor Reten��o',

CASE
WHEN T11.Category = 'I' THEN 'Nota Fiscal'
WHEN T11.Category = 'P' THEN 'Pagamento'
ELSE
''
END AS 'Aplica��o da Reten��o',
T11.Usage AS 'Utiliza��o',

CASE

WHEN T11.ObjType = 18 THEN 'Servi�os Tomados'
WHEN T11.ObjType = 13 THEN 'Servi�os Prestados'

ELSE

''

END AS 'Fun��o',

CASE
WHEN T11.WTCode = 'ISP1' THEN T11.City
WHEN T11.WTCode = 'ISP2' THEN T11.City
WHEN T11.WTCode = 'ISP3' THEN T11.City
WHEN T11.WTCode = 'ISP4' THEN T11.City
WHEN T11.WTCode = 'ISP5' THEN T11.City
WHEN T11.WTCode = 'IST1' THEN T11.City
WHEN T11.WTCode = 'IST2' THEN T11.City
WHEN T11.WTCode = 'IST3' THEN T11.City
WHEN T11.WTCode = 'IST4' THEN T11.City
WHEN T11.WTCode = 'IST5' THEN T11.City
WHEN T11.WTCode = 'IST6' THEN T11.City

ELSE
''
END AS 'Local da Reten��o'

FROM

(
SELECT
T6.TaxId0,
T0.CardCode,
T0.DocEntry,
T0.VATRegNum,
T0.TaxDate,
T0.DocDate,
T4.DueDate,
R11.DocDueDate,
T1.Dscription,
T0.Serial,
T4.InstlmntID,
T3.OffclCode,
T0.GrosProfit,
T4.InsTotal,
T4.PaidToDate, 
T3.WTCode,
T3.WTNAME,
T2.Category,
T2.WTAmnt,
T5.Usage,
T0.ObjType,
T0.BaseAmnt,
T0.CardName,
T7.NfmDescrip,
T9.City

FROM OPCH T0
INNER JOIN PCH1 T1 ON T0.DocNum = T1.DocEntry
INNER JOIN PCH5 T2 ON T0.DocNum = T2.AbsEntry
INNER JOIN OWHT T3 ON T2.WTCode = T3.WTCode
INNER JOIN PCH6 T4 ON T0.DocNum = T4.DocEntry
INNER JOIN OUSG T5 ON T1.Usage = T5.ID
INNER JOIN PCH12 T6 ON T0.DocEntry = T6.DocEntry
INNER JOIN ONFM T7 ON T0.Model = T7.AbsEntry
INNER JOIN OCRD T8 ON T0.CardCode = T8.CardCode
INNER JOIN CRD1 T9 ON T8.CardCode = T9.CardCode
INNER JOIN VPM2 T10 on T10.DocEntry = T0.DocEntry and T10.[InstId]  = T4.[InstlmntID] and InvType = 18
INNER JOIN OVPM R11 ON T10.DocNum = R11.[DocNum] and R11.[Canceled] = 'N'
) T11

