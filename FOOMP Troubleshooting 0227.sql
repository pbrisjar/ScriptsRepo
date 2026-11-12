select * from tePayProviderFiles WITH (NOLOCK)
where [FileName] like '%FOOMP%'
order by importdate desc

--996316.2200

select
	CustomerID
	,ProcDate
	,TranAmt = sum(case when [TransType] = 'I' then cast([AppldAmt] as money) else -cast([AppldAmt] as money) end) 
from teRemittance WITH (NOLOCK)
where fileid = 1045
and RemitType = 'D'
Group by CustomerID, ProcDate
Order by CustomerID, ProcDate

select --*
	Customer
	,ProcessDate
	,HdrAmt = sum(OrigAmt) 
from teRemittanceHdr WITH (NOLOCK)
where fileid = 1046
Group by Customer, ProcessDate
Order by Customer, ProcessDate


select * from txMerchantNumCustomer
where merchantnum in
('5963537',
'7666434')



select *
-- sum(TxAmount) 
from dbo.teFoompTransDtl 
where fileid = 1037
and cast(merchantnum as bigint) in
(select merchantNum from txMerchantNumCustomer)

select 
sum ( case when TransType = 'I' then AppldAmt else -AppldAmt end)
 from teRemittance 
where TransRemNbr like '%K%' 
and FileID = 1035
and CustomerID <> '999'
and RemitType = 'D'  --36276.4400


select
[TransRemNbr], count (*)
from
dbo.[teRemittance]
where --CustomerID = 103
--and 
FileID = 1037
group by [TransRemNbr] having count (*) > 1
--exec pDeleteFiles 1041, 1044

select * from teFoompTransDtl
where DtlID not in
(select Origid from teRemittance where fileid in (1035, 1037))
and fileid in (1035, 1037)

select f.PayEffDate
	,coalesce(mn.Customer, t.CustomerID)
	,coalesce(SUM(f.AMOUNT), 0)	
from
	dbo.teFoompPaymentSum f WITH (NOLOCK)
left outer join
	dbo.txMerchantNumCustomer mn
on
	cast(f.MerchantNum as bigint) = cast(mn.MerchantNum as bigint)
inner join 
	dbo.txAcquirerPayDeviceCustomer t
on
	t.AcqID = 5
and
	t.PaymentDeviceTypeCD = 4
where	
	FileID = 1036
and
	AmountSign <> '-'
and
	(LTRIM(RTRIM(AmountCat)) = 'BATCH HEADER'
	or
	AmountCat like '%NON_SET'
	or
	LTRIM(RTRIM(AmountCat)) = 'PYMT ADJ')	
GROUP BY mn.Customer, t.CustomerID, PayEffDate	


select f.PayEffDate 
	,coalesce(mn.Customer, t.CustomerID)
	,coalesce(SUM(f.AMOUNT), 0) * -1	
from
	dbo.teFoompPaymentSum f WITH (NOLOCK)
left outer join
	dbo.txMerchantNumCustomer mn
on
	cast(f.MerchantNum as bigint) = cast(mn.MerchantNum as bigint)
inner join 
	dbo.txAcquirerPayDeviceCustomer t
on
	t.AcqID = 5
and
	t.PaymentDeviceTypeCD = 4
where	
	FileID = 1036 
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
GROUP BY mn.Customer, t.CustomerID, f.PayEffDate	
