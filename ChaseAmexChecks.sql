/*
Run against CashApp_Staging (VESTADW02)
Checks to verify that Chase Amex transactions are being sent through without truncation issues.
*/
select * from tePayProviderFiles order by ImportDate desc

select Len(RTRIM(LTRIM(SERef))), *
from dbo.teAmexROC11Dtl 
where 
 	FileID > 536
--  and 
-- 	Len(RTRIM(LTRIM(SERef))) > 4
 and
	TxDate > '01/16/2026'
 and
	SEUnitNum = 'CINGULAR'
order by TxDate DESC
--order by count (*)

select * from tdPayPRoviders

select *
from dbo.teAmexROC11Dtl 
where SERef in
(
select LTRIM(RTRIM(MerchantReferenceNumber))
from dbo.teChaseE012Detail1 
where fileid > 528 
and productCode not in ('V', 'M')
)

select '*'+MerchantReferenceNumber+'*'
from dbo.teChaseE012Detail1 
where fileid = 540
and productCode not in ('V', 'M')