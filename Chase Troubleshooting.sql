select * from tePayProviderFiles WITH (NOLOCK)
where PPID = 3
order by ImportDate desc

update tdPayProviders  
set FTPFIleDir = 'D:\PayFiles\Chase\'
where PPID = 3

select
	CustomerID
	,ProcDate
	,sum(case when [TransType] = 'I' then cast([AppldAmt] as money) else -cast([AppldAmt] as money) end) 
from teRemittance WITH (NOLOCK)
where fileid = 1058
and RemitType = 'D'
Group by CustomerID, ProcDate
Order by CustomerID, ProcDate

select --*
	Customer
	,ProcessDate
	,sum(OrigAmt) 
from teRemittanceHdr WITH (NOLOCK)
where fileid = 1057
Group by Customer, ProcessDate
Order by Customer, ProcessDate

Select 
	coalesce(mn.Customer, ap.CustomerID),
	d.DepositDate,
	Sum(d.NetSalesAmount)
	from
		dbo.teChaseDERHeader d	WITH (NOLOCK)				
	left outer join 
		dbo.txMerchantNumCustomer mn
	on
		d.FDMSMerchantNumber = mn.MerchantNum
	inner join 
		txAcquirerPayDeviceCustomer ap WITH (NOLOCK)
	on
		ap.AcqId = 6
	and
		ap.PaymentDeviceTypeCD = 4
	where 
		d.FileID = 1047
	Group by mn.Customer,  ap.CustomerID, d.DepositDate 

select distinct FDMSMerchantNumber 
	from
		dbo.teChaseDERHeader
where FileID = 1047

select merchantNum from txMerchantNumCustomer


select 
FDMSMerchantNumber
,sum(cast(TransactionAmount as money))
from dbo.teChaseE012Detail1
where fileid = 1048
and ProductCode  in ('A','S')
group by FDMSMerchantNumber

select * from dbo.txChasePayType

select distinct ProductCode
from dbo.teChaseE012Detail1
where fileid = 1048

select * 
from dbo.teChaseE012Detail1
where Detail1ID not in
(select OrigID from teRemittance where FileID = 1047)
and FileID = 1048

select * from teRemittance where fileid = 1047 and Imported = 'N' and RemitType = 'D'

select Sum(DinerNet) + sum(CBNet) 
from dbo.teChaseDERSummaryDC
where fileid = 1048

select sum(NetSalesAmount) 	from
		dbo.teChaseDERHeader
where fileid = 1048


	select 
	  ProcDate
	  ,sum(case when RemitType = 'I' then AppldAmt else -AppldAmt end) as TheSum
	from
	  teRemittance
	where 
	  CustomerID in (105, 106)
	and
	  FileID = 1047
	group by ProcDate


select * from
dbo.teChaseE012Detail1 d
inner join
dbo.teRemittance r on
d.Detail1ID = r.OrigID
and 
d.FileID = r.FileID
where
d.FileID = 1047
and 
cast(d.TransactionAmount as money) <> r.AppldAmt

--exec pDeleteFiles 1053, 1054

	select --*
	  ProcDate
	  ,sum(case when TransType = 'I' then cast([AppldAmt] as money) else -cast([AppldAmt] as money) end) as TheSum
	from
	  teRemittance
	where 
		FileID = 1050
	and
	  RemitType = 'T'
	and
	  CustomerID in (105, 106)
	group by ProcDate

select
	ProcDate
	,sum(case when [TransType] = 'I' then cast([AppldAmt] as money) else -cast([AppldAmt] as money) end) 
from teRemittance WITH (NOLOCK)
where fileid = 1050
and CustomerID in (105, 106)
Group by ProcDate


select
	*
from teRemittance (NOLOCK)
where fileid = 1050
and CustomerID in (105, 106)
and RemitType <> 'T'


	select 
	  ProcDate
	  ,sum(case when TransType = 'I' then AppldAmt else -AppldAmt end) as TheSum
	from
	  teRemittance
	where 
	  RemitType = 'T'
	and
	  FileID = 1056
	group by ProcDate
