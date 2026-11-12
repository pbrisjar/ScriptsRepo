/*
Run against cashapp_staging
This is a bunch of queries and partial queries to help with checking FOOMP balances.
*/
select * from tePayProviderFIles where ImportDate > '12/22/2005'

select count(*) from teRemittance where fileid = 592
select * from janus_export.dbo.merchants where acqid = 5 order by merchantid

select * from dbo.teFoompTransDtl WITH (NOLOCK)
where fileid = 612-- and AppldAmt = 39.90 and RemitTYpe = 'D'
and DtlID not in
(select sum(appldamt) from teRemittance WITH (NOLOCK) where fileid = 612 and RemitTYpe = 'D' and customerid = 109 and transtype = 'C')

select AmountCat, count (*) from dbo.teFOOMPPaymentSum WITH (NOLOCK) group by AmountCat
select sum(amount) from dbo.teFOOMPPaymentSum where AmountCat = 'SALES REJECT'
and fileid = 613 and merchantnum like '%5963537%'

select distinct customerid from teRemittance where fileid = 516 and Customerid is null

select Customerid, sum(cast([AppldAmt] as money)) 
--- (select sum(cast([AppldAmt] as money)) from dbo.[teRemittance] where customerid = 109 and [TransType] = 'C' and fileid = 565)
as [109]
from dbo.[teRemittance] where [TransType] = 'I' and RemitType = 'D' and fileid = 516 group by customerid



select CardType, TxAmountSg, sum(TxAmount) from dbo.teFoompTransDtl WITH (NOLOCK)
where fileid = 612
group by CardType, TxAmountSg
order by CardType, TxAmountSg
and DtlID not in
(select origid from teRemittance where fileid = 516 and customerid = 103)
order by cardtype
and TxAmountSg = '-'
AND
	merchantnum <> 5963537
and
	CardType not in ('CHASE  ', 'AMEX      ')

select * from dbo.teFoompTransDtl (NOLOCK)
where LTRIM(RTRIM(cardtype)) = 'DINERS'
order by fileid

-- and AppldAmt = 39.90 and RemitTYpe = 'D'
and DtlID not in
(select origid from teRemittance WITH (NOLOCK) where fileid = 565)

select CardType, TxAmountSg, sum(TxAmount) from dbo.teFoompTransDtl WITH (NOLOCK)
where merchantnum <> 5963537
and FileID = 516
group by CardType, TxAmountSg
order by CardType
(1064244,
1064458
)
where fileid in (516, 517) and TxAmount = 39.90

select  cast(cast(MerchantNum as bigint) as varchar(20))
from
	dbo.teFoompPaymentSum WITH (NOLOCK)
where	
	FileID = 517
AND
	AmountCat = 'BATCH HEADER'	
AND
	AmountSign <> '-'
AND
	merchantnum <> 5963537

select PayEffDate
	,coalesce(SUM(AMOUNT), 0)	
from
	dbo.teFoompPaymentSum WITH (NOLOCK)
where	
	FileID = 566
and
	AmountSign <> '-'
and
	(AmountCat = 'BATCH HEADER'
	or
	AmountCat like '%NON_SET')	
AND
	merchantnum <> 5963537
GROUP BY PayEffDate	

select PayEffDate 
	,coalesce(SUM(AMOUNT), 0)	
from
	dbo.teFoompPaymentSum WITH (NOLOCK)
where	
	FileID = 566
and
	AmountSign = '-'
and
	(AmountCat like '%NON_SET'
	or
	AmountCat = 'BATCH HEADER'
	or
	AmountCat = 'ADJUSTMENT')	
 AND
 	merchantnum <> 5963537
GROUP BY PayEffDate

select * from dbo.teRemittance WITH (NOLOCK)
where fileid = 516 and customerid <> 103 and appldamt = 39.90order by customerid
TransRemNbr in
('12040000342586',
'12040000342465'
)

select * from dbo.teRemitPreHeader where fileid = 566



fileid  = 516 and REmitTYpe = 'D' and customerid <> 103
AppldAmt = 39.90 and REmitTYpe = 'D'

select * from janus_export.dbo.merchants where merchantid > 2133

select * from tePayProviderFIles order by ImportDate desc where FileName like '%FOOMP%' and ImportDate > '12/28/2025'