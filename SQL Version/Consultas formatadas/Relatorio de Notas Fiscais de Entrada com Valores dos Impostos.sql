/*select from dbo.Opch t0*/ 
declare @dtIniEmi AS DateTime
declare @dtFinEmi AS DateTime

/* where */ 
SET @dtIniEmi = /* T0.docdate */ '[%0]'
SET @dtFinEmi = /* T0.docdate */ '[%1]'

----------------------------------------
-- NFs de Entrada
---------------------------------------

select
 'NF. Entrada' as 'Tipo doc'
,NF.DocEntry
,NF.BPLName
,NF.DocDate
,NF.TaxDate
,NFL.CFOPCode
,NF.Serial as 'N° NF'
,ONFM.NfmName as 'Modelo'
,NF.DocDueDate
,(CASE when DF.TaxId0 = '' OR DF.TaxId0 IS NULL THEN DF.TaxId4 ELSE DF.TaxId0 END)   as 'CPF/CNPJ'
,NF.CardName
,DF.State
,NFL.ItemCode as 'Item'
,NFL.Dscription as 'Descrição'
,ONCM.NcmCode as 'NCM'
,NFL.CSTCode as 'CST'
,NFL.Quantity as 'Quantidade'
,NFL.unitMsr as 'Unidade'
,NFL.Price as 'Preço Unit'
,NFL.LineTotal
,(SELECT sum(S0.BaseSum) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '10' and S0.Linenum = NFL.LineNum) AS 'B.C do ICMS'
,(SELECT sum(S0.TaxRate) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '10' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ICMS'
,(SELECT sum(S0.TaxSum)  FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '10' and S0.Linenum = NFL.LineNum) AS 'Valor ICMS'

,(SELECT sum(S0.BaseSum) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '11' and S0.Linenum = NFL.LineNum) AS 'B.C do ICMS-IMP'
,(SELECT sum(S0.TaxRate) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '11' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ICMS-IMP'
,(SELECT sum(S0.TaxSum)  FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '11' and S0.Linenum = NFL.LineNum) AS 'Valor ICMS-IMP'

,(SELECT sum(S0.BaseSum) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '12' and S0.Linenum = NFL.LineNum) AS 'B.C do ICMS-DIF'
,(SELECT sum(S0.TaxRate) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '12' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ICMS-DIF'
,(SELECT sum(S0.TaxSum)  FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '12' and S0.Linenum = NFL.LineNum) AS 'Valor ICMS-DIF'

,(SELECT sum(S0.BaseSum) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '13' and S0.Linenum = NFL.LineNum) AS 'B.C ICMS-ST'
,(SELECT sum(S0.TaxRate) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '13' and S0.Linenum = NFL.LineNum) AS 'Alíq. ICMS-ST'
,(SELECT sum(S0.TaxSum)  FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '13' and S0.Linenum = NFL.LineNum) AS 'VL ICMS-ST'

,(SELECT sum(S0.BaseSum) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '19' and S0.Linenum = NFL.LineNum) AS 'B.C do PIS'
,(SELECT sum(S0.TaxRate) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '19' and S0.Linenum = NFL.LineNum) AS 'Alíq. do PIS'
,(SELECT sum(S0.TaxSum)  FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '19' and S0.Linenum = NFL.LineNum) AS 'Valor PIS'
,(SELECT sum(S0.BaseSum) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '21' and S0.Linenum = NFL.LineNum) AS 'B.C do Cofins'
,(SELECT sum(S0.TaxRate) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '21' and S0.Linenum = NFL.LineNum) AS 'Alíq. do Cofins'
,(SELECT sum(S0.TaxSum)  FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '21' and S0.Linenum = NFL.LineNum) AS 'Valor Cofins'
,(SELECT sum(S0.BaseSum) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '16' and S0.Linenum = NFL.LineNum) AS 'B.C do ISS'
,(SELECT sum(S0.TaxRate) FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '16' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ISS'
,(SELECT sum(S0.TaxSum)  FROM PCH4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '16' and S0.Linenum = NFL.LineNum) AS 'Valor ISS'
,(SELECT sum(S0.Rate)    FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '3' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq IR'
,(SELECT sum(S0.WTAmnt)  FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '3' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor IR'
,(SELECT sum(S0.Rate)    FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '1' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq PIS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '1' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor PIS RETIDO'
,(SELECT sum(S0.Rate)    FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '2' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq Cofins RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '2' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor Cofins RETIDO'
,(SELECT sum(S0.Rate)    FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '4' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq CSLL RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '4' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor CSLL RETIDO'
,(SELECT sum(S0.Rate)    FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '5' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq INSS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '5' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor INSS RETIDO'
,(SELECT sum(S0.Rate)    FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '6' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq ISS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '6' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor ISS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '10' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor PCC'
,(SELECT sum(S0.Rate)    FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '8' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq ISSQN'
,(SELECT sum(S0.WTAmnt)  FROM PCH5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '8' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor ISSQN'
,NFL.AcctCode as 'C. Contabil'
,OACT.AcctName as 'Nome da Conta'
,NF.ComMents

from OPCH NF

inner join PCH1 NFL on NF.DocEntry = NFL.DocEntry
inner join PCH12 DF on NF.DocEntry = DF.DocEntry
inner join OITM IT on NFL.ItemCode = IT.ItemCode
left join ONCM on IT.NCMCode = ONCM.AbsEntry
inner join OACT on NFL.AcctCode = OACT.AcctCode
left join ONFM on NF.Model  = ONFM.AbsEntry

where NF.CANCELED = 'N'
AND NF.DocDate between (case when @dtIniEmi = '' then NF.DocDate else @dtIniEmi end) AND (case when @dtFinEmi = '' then NF.DocDate else @dtFinEmi end)

UNION ALL

-------------------------------------------
-- Devolução de NFs de Entrada
-------------------------------------------

select
 'Devolução de NF. Entrada' as 'Tipo doc'
,NF.DocEntry
,NF.BPLName
,NF.DocDate
,NF.TaxDate
,NFL.CFOPCode
,NF.Serial as 'N° NF'
,ONFM.NfmName as 'Modelo'
,NF.DocDueDate
,(CASE when DF.TaxId0 = '' OR DF.TaxId0 IS NULL THEN DF.TaxId4 ELSE DF.TaxId0 END)   as 'CPF/CNPJ'
,NF.CardName
,DF.State
,NFL.ItemCode as 'Item'
,NFL.Dscription as 'Descrição'
,ONCM.NcmCode as 'NCM'
,NFL.CSTCode as 'CST'
,NFL.Quantity as 'Quantidade'
,NFL.unitMsr as 'Unidade'
,NFL.Price as 'Preço Unit'
,NFL.LineTotal
,(SELECT sum(S0.BaseSum) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '10' and S0.Linenum = NFL.LineNum) AS 'B.C do ICMS'
,(SELECT sum(S0.TaxRate) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '10' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ICMS'
,(SELECT sum(S0.TaxSum)  FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '10' and S0.Linenum = NFL.LineNum) AS 'Valor ICMS'

,(SELECT sum(S0.BaseSum) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '11' and S0.Linenum = NFL.LineNum) AS 'B.C do ICMS-IMP'
,(SELECT sum(S0.TaxRate) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '11' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ICMS-IMP'
,(SELECT sum(S0.TaxSum)  FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '11' and S0.Linenum = NFL.LineNum) AS 'Valor ICMS-IMP'

,(SELECT sum(S0.BaseSum) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '12' and S0.Linenum = NFL.LineNum) AS 'B.C do ICMS-DIF'
,(SELECT sum(S0.TaxRate) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '12' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ICMS-DIF'
,(SELECT sum(S0.TaxSum)  FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '12' and S0.Linenum = NFL.LineNum) AS 'Valor ICMS-DIF'

,(SELECT sum(S0.BaseSum) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '13' and S0.Linenum = NFL.LineNum) AS 'B.C ICMS-ST'
,(SELECT sum(S0.TaxRate) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '13' and S0.Linenum = NFL.LineNum) AS 'Alíq. ICMS-ST'
,(SELECT sum(S0.TaxSum)  FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '13' and S0.Linenum = NFL.LineNum) AS 'VL ICMS-ST'

,(SELECT sum(S0.BaseSum) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '19' and S0.Linenum = NFL.LineNum) AS 'B.C do PIS'
,(SELECT sum(S0.TaxRate) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '19' and S0.Linenum = NFL.LineNum) AS 'Alíq. do PIS'
,(SELECT sum(S0.TaxSum)  FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '19' and S0.Linenum = NFL.LineNum) AS 'Valor PIS'
,(SELECT sum(S0.BaseSum) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '21' and S0.Linenum = NFL.LineNum) AS 'B.C do Cofins'
,(SELECT sum(S0.TaxRate) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '21' and S0.Linenum = NFL.LineNum) AS 'Alíq. do Cofins'
,(SELECT sum(S0.TaxSum)  FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '21' and S0.Linenum = NFL.LineNum) AS 'Valor Cofins'
,(SELECT sum(S0.BaseSum) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '16' and S0.Linenum = NFL.LineNum) AS 'B.C do ISS'
,(SELECT sum(S0.TaxRate) FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '16' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ISS'
,(SELECT sum(S0.TaxSum)  FROM RPC4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '16' and S0.Linenum = NFL.LineNum) AS 'Valor ISS'
,(SELECT sum(S0.Rate)    FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '3' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq IR'
,(SELECT sum(S0.WTAmnt)  FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '3' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor IR'
,(SELECT sum(S0.Rate)    FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '1' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq PIS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '1' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor PIS RETIDO'
,(SELECT sum(S0.Rate)    FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '2' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq Cofins RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '2' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor Cofins RETIDO'
,(SELECT sum(S0.Rate)    FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '4' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq CSLL RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '4' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor CSLL RETIDO'
,(SELECT sum(S0.Rate)    FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '5' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq INSS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '5' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor INSS RETIDO'
,(SELECT sum(S0.Rate)    FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '6' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq ISS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '6' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor ISS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '10' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor PCC'
,(SELECT sum(S0.Rate)    FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '8' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq ISSQN'
,(SELECT sum(S0.WTAmnt)  FROM RPC5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '8' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor ISSQN'
,NFL.AcctCode as 'C. Contabil'
,OACT.AcctName as 'Nome da Conta'
,NF.ComMents

from ORPC NF
inner join RPC1 NFL on NF.DocEntry = NFL.DocEntry
inner join RPC12 DF on NF.DocEntry = DF.DocEntry
inner join OITM IT on NFL.ItemCode = IT.ItemCode
left join ONCM on IT.NCMCode = ONCM.AbsEntry
inner join OACT on NFL.AcctCode = OACT.AcctCode
left join ONFM on NF.Model  = ONFM.AbsEntry

where NF.CANCELED = 'N'
AND NF.DocDate between (case when @dtIniEmi = '' then NF.DocDate else @dtIniEmi end) AND (case when @dtFinEmi = '' then NF.DocDate else @dtFinEmi end)

UNION ALL

---------------------------------------------
-- Recebimento de Mercadorias
---------------------------------------------

select
'Recebimento de Mercadorias' as 'Tipo doc'
,NF.DocEntry
,NF.BPLName
,NF.DocDate
,NF.TaxDate
,NFL.CFOPCode
,NF.Serial as 'N° NF'
,ONFM.NfmName as 'Modelo'
,NF.DocDueDate
,(CASE when DF.TaxId0 = '' OR DF.TaxId0 IS NULL THEN DF.TaxId4 ELSE DF.TaxId0 END)   as 'CPF/CNPJ'
,NF.CardName
,DF.State
,NFL.ItemCode as 'Item'
,NFL.Dscription as 'Descrição'
,ONCM.NcmCode as 'NCM'
,NFL.CSTCode as 'CST'
,NFL.Quantity as 'Quantidade'
,NFL.unitMsr as 'Unidade'
,NFL.Price as 'Preço Unit'
,NFL.LineTotal
,(SELECT sum(S0.BaseSum) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '10' and S0.Linenum = NFL.LineNum) AS 'B.C do ICMS'
,(SELECT sum(S0.TaxRate) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '10' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ICMS'
,(SELECT sum(S0.TaxSum)  FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '10' and S0.Linenum = NFL.LineNum) AS 'Valor ICMS'

,(SELECT sum(S0.BaseSum) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '11' and S0.Linenum = NFL.LineNum) AS 'B.C do ICMS-IMP'
,(SELECT sum(S0.TaxRate) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '11' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ICMS-IMP'
,(SELECT sum(S0.TaxSum)  FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '11' and S0.Linenum = NFL.LineNum) AS 'Valor ICMS-IMP'

,(SELECT sum(S0.BaseSum) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '12' and S0.Linenum = NFL.LineNum) AS 'B.C do ICMS-DIF'
,(SELECT sum(S0.TaxRate) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '12' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ICMS-DIF'
,(SELECT sum(S0.TaxSum)  FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '12' and S0.Linenum = NFL.LineNum) AS 'Valor ICMS-DIF'

,(SELECT sum(S0.BaseSum) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '13' and S0.Linenum = NFL.LineNum) AS 'B.C ICMS-ST'
,(SELECT sum(S0.TaxRate) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '13' and S0.Linenum = NFL.LineNum) AS 'Alíq. ICMS-ST'
,(SELECT sum(S0.TaxSum)  FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '13' and S0.Linenum = NFL.LineNum) AS 'VL ICMS-ST'

,(SELECT sum(S0.BaseSum) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '19' and S0.Linenum = NFL.LineNum) AS 'B.C do PIS'
,(SELECT sum(S0.TaxRate) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '19' and S0.Linenum = NFL.LineNum) AS 'Alíq. do PIS'
,(SELECT sum(S0.TaxSum)  FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '19' and S0.Linenum = NFL.LineNum) AS 'Valor PIS'
,(SELECT sum(S0.BaseSum) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '21' and S0.Linenum = NFL.LineNum) AS 'B.C do Cofins'
,(SELECT sum(S0.TaxRate) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '21' and S0.Linenum = NFL.LineNum) AS 'Alíq. do Cofins'
,(SELECT sum(S0.TaxSum)  FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '21' and S0.Linenum = NFL.LineNum) AS 'Valor Cofins'
,(SELECT sum(S0.BaseSum) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '16' and S0.Linenum = NFL.LineNum) AS 'B.C do ISS'
,(SELECT sum(S0.TaxRate) FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '16' and S0.Linenum = NFL.LineNum) AS 'Alíq. do ISS'
,(SELECT sum(S0.TaxSum)  FROM PDN4 S0 WHERE S0.DocEntry = NFL.DOCENTRY AND S0.staType = '16' and S0.Linenum = NFL.LineNum) AS 'Valor ISS'
,(SELECT sum(S0.Rate)    FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '3' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq IR'
,(SELECT sum(S0.WTAmnt)  FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '3' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor IR'
,(SELECT sum(S0.Rate)    FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '1' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq PIS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '1' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor PIS RETIDO'
,(SELECT sum(S0.Rate)    FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '2' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq Cofins RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '2' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor Cofins RETIDO'
,(SELECT sum(S0.Rate)    FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '4' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq CSLL RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '4' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor CSLL RETIDO'
,(SELECT sum(S0.Rate)    FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '5' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq INSS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '5' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor INSS RETIDO'
,(SELECT sum(S0.Rate)    FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '6' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq ISS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '6' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor ISS RETIDO'
,(SELECT sum(S0.WTAmnt)  FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '6' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor ISS RETIDO'
,(SELECT sum(S0.Rate)    FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '8' and S0.Doc1LineNo = NFL.LineNum) AS 'Alíq ISSQN'
,(SELECT sum(S0.WTAmnt)  FROM PDN5 S0 inner join OWHT on S0.WTCode = OWHT.WTCode WHERE S0.AbsEntry = NFL.DOCENTRY AND OWHT.WTTypeId = '8' and S0.Doc1LineNo = NFL.LineNum) AS 'Valor ISSQN'
,NFL.AcctCode as 'C. Contabil'
,OACT.AcctName as 'Nome da Conta'
,NF.ComMents

from OPDN NF
inner join PDN1 NFL on NF.DocEntry = NFL.DocEntry
inner join PDN12 DF on NF.DocEntry = DF.DocEntry
inner join OITM IT on NFL.ItemCode = IT.ItemCode
left join ONCM on IT.NCMCode = ONCM.AbsEntry
inner join OACT on NFL.AcctCode = OACT.AcctCode
left join ONFM on NF.Model  = ONFM.AbsEntry

where NF.CANCELED = 'N'
AND NF.DocDate between (case when @dtIniEmi = '' then NF.DocDate else @dtIniEmi end) AND (case when @dtFinEmi = '' then NF.DocDate else @dtFinEmi end) AND NF.BPLid <> 1
