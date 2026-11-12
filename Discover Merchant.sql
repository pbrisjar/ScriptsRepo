select distinct MerchantNumber
from dbo.teAmExMerchantHR
where MerchID in
(
select dbo.fnAmExMerchant(d.FileID, d.LineNum)
from dbo.teAmExTXDtl d
inner join teRemittance r
on
	d.TxDSeqNum = r.Origid
where r.PPID = 4 
and r.customerid = 109
and r.AppldAmt in (20.00, 30.00)

--and r.TransDate between '10/01/2025' and '10/31/2025'
--and d.TxID <> '0001000000000000'
and r.OriginalBatch = '0001000000000000')
--not in ('601101060354113', '0001000000000000')
--order by d.TxDate

select *
from dbo.teAmExMerchantHR
where MerchantNumber = '601101060354113'