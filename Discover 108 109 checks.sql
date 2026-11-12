--select * from tdPayProviders

select * --dbo.fnAmExMerchant(d.FileID, d.LineNum)
from dbo.teAmExTXDtl d
inner join teRemittance r
on
	d.TxDSeqNum = r.Origid
where r.PPID = 4 
-- and r.customerid = 108
-- --and r.AppldAmt in (20.00, 30.00)
-- 
-- --and r.TransDate between '10/01/2005' and '10/31/2005'
-- and d.TxID = '0001000000000000'
and r.OriginalBatch not like  '6011%'
and r.OriginalBatch not like  '%0000'
--not in ('601101060354113', '0001000000000000')
order by d.TxDate


select distinct d.MerchantNumber
from dbo.teAmExMerchantHR d
left outer join
	Janus_Export.dbo.Merchants m
on
	d.MerchantNumber = m.merchantnum
where m.merchantnum is null

select * --distinct r.OriginalBatch
from  teRemittance r
where r.PPID = 4 
-- and r.customerid = 108
-- --and r.AppldAmt in (20.00, 30.00)
-- 
-- --and r.TransDate between '10/01/2005' and '10/31/2005'
-- and d.TxID = '0001000000000000'
and r.OriginalBatch not like  '6011%'
and r.OriginalBatch not like  '%0000'

--not in ('601101060354113', '0001000000000000')
--order by d.TxDate

select * from tePayProviderFiles where fileid in (1064, 1065, 1078)