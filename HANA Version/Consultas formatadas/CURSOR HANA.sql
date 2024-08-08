DO BEGIN

declare CONTRATO integer;
declare DATA01 date;
declare DATA02 date;


DECLARE CURSOR C01 for 

SELECT distinct

TB."Id",
TA."DueDateBase",
TA."BirthdayDate" 

FROM "IV_C1_ContractLine" TA inner join "IV_C1_Contract" TB on TA."ContractId" = TB."Id"

WHERE

TB."ContractStatusId" = 4
AND TA."Liberated" = 1
AND Cast(TA."BirthdayDate" as date) >= CURRENT_DATE;

CREATE LOCAL TEMPORARY TABLE #MEDICOES ("Contrato" int,"Vencimento" date, "Aniversario" date);

OPEN C01; 
FETCH C01 INTO CONTRATO,DATA01,DATA02;
While not C01::NOTFOUND
DO WHILE DATA01 < DATA02 
DO INSERT INTO #MEDICOES (SELECT CONTRATO, DATA01, DATA02 FROM DUMMY);
SELECT ADD_MONTHS(DATA01,1) INTO DATA01 FROM DUMMY;
END WHILE;
FETCH C01 INTO CONTRATO,DATA01,DATA02;
END WHILE;
CLOSE C01;
END;

select 

TB."Id" "Nº do Contrato",
TB."CardCode" "Código Cliente",
TB."CardName" "Código PN",
TA."ItemCode" "Código do Item",
TA."ItemName" "Descrição do Item",
t0."Vencimento" "Parcela", 
t0."Aniversario" "Aniversário"
from 

#MEDICOES t0 inner join "IV_C1_ContractLine" TA on TA."ContractId" = t0."Contrato"
inner join "IV_C1_Contract" TB on TA."ContractId" = TB."Id"
left join OPCH t1 on t1."U_ContractId" =  t0."Contrato" and t1."DocDueDate" = t0."Vencimento"

where 

t0."Vencimento" <= ADD_DAYS(CURRENT_DATE,15)
AND t0."Vencimento" >= '2019-01-01'
and t1."DocDueDate" is null


ORDER BY "Contrato","Vencimento";

DROP TABLE #MEDICOES