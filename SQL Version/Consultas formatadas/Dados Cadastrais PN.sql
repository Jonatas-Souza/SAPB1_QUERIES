select

t0.CardCode 'COD. PN',
t0.cardname 'RAZÃO SOCIAL / NOME',
ISNULL(T0.CARDFNAME,CAST(T0.ALIASNAME AS VARCHAR(MAX))) 'FANTASIA',
case when t0.CardType = 'S' then
(select top 1 ta.TaxId0 from crd7 ta where ta.CardCode = t0.CardCode and isnull(ta.TaxId0,'') <> '')
else
(select top 1 ta.TaxId0 from crd7 ta inner join crd1 tb on tb.CardCode = ta.CardCode
where ta.CardCode = t0.CardCode and isnull(ta.TaxId0,'') <> '' and tb.Address = t0.ShipToDef AND TB.AdresType = 'S')
end CNPJ,
case when t0.CardType = 'S' then
(select top 1 ta.Taxid4 from crd7 ta where ta.CardCode = t0.CardCode and isnull(ta.Taxid4,'') <> '')
else
(select top 1 ta.Taxid4 from crd7 ta inner join crd1 tb on tb.CardCode = ta.CardCode
where ta.CardCode = t0.CardCode and isnull(ta.Taxid4,'') <> '' and tb.Address = t0.ShipToDef AND TB.AdresType = 'S')
end CPF,
case when t0.CardType = 'S' then
(select top 1 ta.Taxid1 from crd7 ta where ta.CardCode = t0.CardCode and isnull(ta.Taxid1,'') <> '')
else
(select top 1 ta.Taxid1 from crd7 ta inner join crd1 tb on tb.CardCode = ta.CardCode
where ta.CardCode = t0.CardCode and isnull(ta.Taxid1,'') <> '' and tb.Address = t0.ShipToDef AND TB.AdresType = 'S')
end 'INSC. ESTADUAL',
case when t0.CardType = 'S' then
(select top 1 ta.Taxid3 from crd7 ta where ta.CardCode = t0.CardCode and isnull(ta.Taxid3,'') <> '')
else
(select top 1 ta.Taxid3 from crd7 ta inner join crd1 tb on tb.CardCode = ta.CardCode
where ta.CardCode = t0.CardCode and isnull(ta.Taxid3,'') <> '' and tb.Address = t0.ShipToDef AND TB.AdresType = 'S')
end 'INSC. MUNICIPAL',
(SELECT TOP 1 TA.ZipCode FROM CRD1 TA WHERE TA.CardCode = T0.CardCode AND TA.Address = T0.ShipToDef AND TA.AdresType = 'S') CEP,
(SELECT TOP 1 ISNULL(TA.AddrType,'') + ' ' + ISNULL(TA.Street,'') + ISNULL(', ' + TA.StreetNo,'') + ISNULL(', ' + CAST(TA.Building AS VARCHAR(MAX)),'')
FROM CRD1 TA WHERE TA.CardCode = T0.CardCode AND TA.Address = T0.ShipToDef AND TA.AdresType = 'S') ENDEREÇO,
(SELECT TOP 1 TA.Block FROM CRD1 TA WHERE TA.CardCode = T0.CardCode AND TA.Address = T0.ShipToDef AND TA.AdresType = 'S') BAIRRO,
(SELECT TOP 1 UPPER(TB.Name) 
FROM CRD1 TA INNER JOIN OCNT TB ON TB.AbsId = TA.County WHERE TA.CardCode = T0.CardCode AND TA.Address = T0.ShipToDef AND TA.AdresType = 'S') CIDADE,
(SELECT TOP 1 UPPER(TB.State) 
FROM CRD1 TA INNER JOIN OCNT TB ON TB.AbsId = TA.County WHERE TA.CardCode = T0.CardCode AND TA.Address = T0.ShipToDef AND TA.AdresType = 'S') UF,
T0.Phone1 'TELEFONE 1',
T0.Phone2 'TELEFONE 2',
T0.Cellular 'CELULAR',
T0.Fax 'FAX',
T0.E_Mail 'E-MAIL',
T0.IntrntSite 'SITE',

(SELECT tx.Name  from 
(select ta.Name,ROW_NUMBER() over(order by ta.CntctCode asc) seq from OCPR ta where ta.CardCode = t0.CardCode) tx where tx.seq = 1 ) 'CONTATO 1',
(SELECT top 1 isnull('1º NOME: ' + tx.FirstName,'') + isnull(' 2º NOME: ' + tx.MiddleName,'') + isnull(' SOBRENOME: ' + tx.LastName,'') + isnull(' TÍTULO: ' + tx.Title,'')
+ isnull(' POSIÇÃO: ' + tx.Position,'') + isnull(' ENDEREÇO: ' + tx.Address,'') + isnull(' TEL.1: ' + tx.Tel1,'') + + isnull(' TEL.2: ' + tx.Tel2,'') + isnull(' CELULAR: ' + tx.Cellolar,'')
+ isnull(' FAX: ' + tx.Fax,'') + isnull(' E-MAIL: ' + tx.E_MailL,'')
from  
(select ta.FirstName,TA.MiddleName,TA.LastName,TA.Title,TA.Position,ta.Address,ta.Tel1,ta.Tel2,ta.Cellolar,ta.Fax,ta.E_MailL,ROW_NUMBER() over(order by ta.CntctCode asc) seq 
from OCPR ta where ta.CardCode = t0.CardCode) tx where tx.seq = 1) 'DADOS CONTATO 1',

(SELECT tx.Name  from 
(select ta.Name,ROW_NUMBER() over(order by ta.CntctCode asc) seq from OCPR ta where ta.CardCode = t0.CardCode) tx where tx.seq = 2 ) 'CONTATO 2',
(SELECT top 1 isnull('1º NOME: ' + tx.FirstName,'') + isnull(' 2º NOME: ' + tx.MiddleName,'') + isnull(' SOBRENOME: ' + tx.LastName,'') + isnull(' TÍTULO: ' + tx.Title,'')
+ isnull(' POSIÇÃO: ' + tx.Position,'') + isnull(' ENDEREÇO: ' + tx.Address,'') + isnull(' TEL.1: ' + tx.Tel1,'') + + isnull(' TEL.2: ' + tx.Tel2,'') + isnull(' CELULAR: ' + tx.Cellolar,'')
+ isnull(' FAX: ' + tx.Fax,'') + isnull(' E-MAIL: ' + tx.E_MailL,'')
from  
(select ta.FirstName,TA.MiddleName,TA.LastName,TA.Title,TA.Position,ta.Address,ta.Tel1,ta.Tel2,ta.Cellolar,ta.Fax,ta.E_MailL,ROW_NUMBER() over(order by ta.CntctCode asc) seq 
from OCPR ta where ta.CardCode = t0.CardCode) tx where tx.seq = 2) 'DADOS CONTATO 2',

(SELECT tx.Name  from 
(select ta.Name,ROW_NUMBER() over(order by ta.CntctCode asc) seq from OCPR ta where ta.CardCode = t0.CardCode) tx where tx.seq = 3 ) 'CONTATO 3',
(SELECT top 1 isnull('1º NOME: ' + tx.FirstName,'') + isnull(' 2º NOME: ' + tx.MiddleName,'') + isnull(' SOBRENOME: ' + tx.LastName,'') + isnull(' TÍTULO: ' + tx.Title,'')
+ isnull(' POSIÇÃO: ' + tx.Position,'') + isnull(' ENDEREÇO: ' + tx.Address,'') + isnull(' TEL.1: ' + tx.Tel1,'') + + isnull(' TEL.2: ' + tx.Tel2,'') + isnull(' CELULAR: ' + tx.Cellolar,'')
+ isnull(' FAX: ' + tx.Fax,'') + isnull(' E-MAIL: ' + tx.E_MailL,'')
from  
(select ta.FirstName,TA.MiddleName,TA.LastName,TA.Title,TA.Position,ta.Address,ta.Tel1,ta.Tel2,ta.Cellolar,ta.Fax,ta.E_MailL,ROW_NUMBER() over(order by ta.CntctCode asc) seq 
from OCPR ta where ta.CardCode = t0.CardCode) tx where tx.seq = 3) 'DADOS CONTATO 3',

(SELECT tx.Name  from 
(select ta.Name,ROW_NUMBER() over(order by ta.CntctCode asc) seq from OCPR ta where ta.CardCode = t0.CardCode) tx where tx.seq = 4 ) 'CONTATO 4',
(SELECT top 1 isnull('1º NOME: ' + tx.FirstName,'') + isnull(' 2º NOME: ' + tx.MiddleName,'') + isnull(' SOBRENOME: ' + tx.LastName,'') + isnull(' TÍTULO: ' + tx.Title,'')
+ isnull(' POSIÇÃO: ' + tx.Position,'') + isnull(' ENDEREÇO: ' + tx.Address,'') + isnull(' TEL.1: ' + tx.Tel1,'') + + isnull(' TEL.2: ' + tx.Tel2,'') + isnull(' CELULAR: ' + tx.Cellolar,'')
+ isnull(' FAX: ' + tx.Fax,'') + isnull(' E-MAIL: ' + tx.E_MailL,'')
from  
(select ta.FirstName,TA.MiddleName,TA.LastName,TA.Title,TA.Position,ta.Address,ta.Tel1,ta.Tel2,ta.Cellolar,ta.Fax,ta.E_MailL,ROW_NUMBER() over(order by ta.CntctCode asc) seq 
from OCPR ta where ta.CardCode = t0.CardCode) tx where tx.seq = 4) 'DADOS CONTATO 4',

(SELECT tx.Name  from 
(select ta.Name,ROW_NUMBER() over(order by ta.CntctCode asc) seq from OCPR ta where ta.CardCode = t0.CardCode) tx where tx.seq = 5 ) 'CONTATO 5',
(SELECT top 1 isnull('1º NOME: ' + tx.FirstName,'') + isnull(' 2º NOME: ' + tx.MiddleName,'') + isnull(' SOBRENOME: ' + tx.LastName,'') + isnull(' TÍTULO: ' + tx.Title,'')
+ isnull(' POSIÇÃO: ' + tx.Position,'') + isnull(' ENDEREÇO: ' + tx.Address,'') + isnull(' TEL.1: ' + tx.Tel1,'') + + isnull(' TEL.2: ' + tx.Tel2,'') + isnull(' CELULAR: ' + tx.Cellolar,'')
+ isnull(' FAX: ' + tx.Fax,'') + isnull(' E-MAIL: ' + tx.E_MailL,'')
from  
(select ta.FirstName,TA.MiddleName,TA.LastName,TA.Title,TA.Position,ta.Address,ta.Tel1,ta.Tel2,ta.Cellolar,ta.Fax,ta.E_MailL,ROW_NUMBER() over(order by ta.CntctCode asc) seq 
from OCPR ta where ta.CardCode = t0.CardCode) tx where tx.seq = 5) 'DADOS CONTATO 5',

t0.CreateDate 'DATA DE CADASTRO',
CASE WHEN T0.frozenFor = 'Y' THEN 'INATIVO' ELSE 'ATIVO' END 'STATUS DO CADASTRO'


from

OCRD t0 

ORDER BY T0.CardName ASC