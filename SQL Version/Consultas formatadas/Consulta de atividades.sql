select 
T0.ClgCode 'Atividade',
T0.CardCode 'C�digo do PN',
T1.CardName 'Nome do PN',
CASE WHEN T0.Action='C' THEN 'Telefonema'
	 WHEN T0.Action='M' THEN 'Reuni�o'
	 WHEN T0.Action='T' THEN 'Tarefa'
	 WHEN T0.Action='E' THEN 'Nota'
	 WHEN T0.Action='p' THEN 'Campanha'
	 WHEN T0.Action='N' THEN 'Outros' 
end 'Atividade',
t3.Name 'Tipo',
t4.Name 'Assunto',
CASE WHEN T0.AttendUser IS NOT NULL THEN 'USU�RIO' ELSE 'EMPREGADO' END 'Usu�rio/Empregado',
CASE WHEN T0.AttendUser IS NOT NULL THEN T5.U_NAME ELSE T6.firstName + ' ' + t6.middleName END 'Atribu�do a',
T7.U_NAME 'Atribu�do por',
T0.Details 'Observa��es',
T0.Recontact 'Data In�cio',
T0.endDate 'Data T�rmino',
T0.Notes 'Conte�do'


from OCLG T0
LEFT JOIN OCRD T1 ON T0.CardCode = T1.CardCode
LEFT JOIN OCLT T3 ON T0.CNTCTTYPE = t3.code
LEFT JOIN OCLS T4 ON T0.CntctSbjct = T4.Code
LEFT JOIN OUSR T5 ON T0.AttendUser = T5.USERID
LEFT JOIN OHEM T6 ON T0.AttendUser = T6.empID
LEFT JOIN OUSR T7 ON T0.AssignedBy = T7.USERID
