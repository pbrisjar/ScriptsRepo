select * from tePayPRoviderFIles  order by importdate desc 

select count (*) from teARIREmit 
where RmtID in
(
select RemittanceID from teRemittance where FileID in (1040, 1042) 
)
and CustomerID not in (105, 106, 108) and RemitType = 'D' and Imported = 'N'

select TransRemNbr, count (*) 
from teRemittance 
where FileID in (1040, 1042) 
group by TransRemNbr having COUNT(*) > 1

select 
	sum(case when TxAmountSg = '-' then -TxAmount else TxAmount end)
--MerchantNum, count (*) 
from dbo.teFoompTransDtl
where 
FileID = 1040
and CardType not in
('AMEX','CHASE')
and MerchantNum <> '0005963537'

-- and DtlID not in
-- (
-- select
-- 	OrigID --sum(case when [TransType] = 'I' then cast([AppldAmt] as money) else -cast([AppldAmt] as money) end) 
-- from teRemittance
-- where FileID = 1040 
-- -- and RemitTYpe = 'D'
-- -- and CustomerID = 103
-- )
-- Group by merchantnum


select distinct cardtype from dbo.teFoompTransDtl
where fileid = 1040


select sum(Amount)
from dbo.teFOOMPPaymentSum
where	
	FileID = 1041
and MerchantNum <> '0005963537'
and
	AmountSign <> '-'
and
	(LTRIM(RTRIM(AmountCat)) = 'BATCH HEADER'
	or
	AmountCat like '%NON_SET'
	or
	LTRIM(RTRIM(AmountCat)) = 'PYMT ADJ')

select -sum(Amount)
from dbo.teFOOMPPaymentSum
where	
	FileID = 1041
and MerchantNum <> '0005963537'
and
	AmountSign = '-'
and
	(AmountCat like '%NON_SET'
	or
	LTRIM(RTRIM(AmountCat)) = 'BATCH HEADER'
	or
	LTRIM(RTRIM(AmountCat)) = 'PYMT ADJ'
	or
	LTRIM(RTRIM(AmountCat)) = 'SALES REJECT')	
--1180678.25