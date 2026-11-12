update teRemittance
set OriginalBatch = MerchNum
from
(
	select 
	  RemitID = r.RemittanceID
	  ,MerchNum = cast(m.MerchantNumber as varchar(20))
	from
	  teRemittance r
	inner join dbo.teAmExTXDtl d
	on
		d.TxDSeqNum = r.Origid
	inner join
		dbo.teAmExMerchantHR m
	on
		m.merchID = dbo.fnAmExMerchant(d.FileID, d.LineNum)
	where 
		r.PPID = 4 
	and 
		r.OriginalBatch not like  '6011%'
	and
		r.FileID not in (1064, 1065, 1078)) ts
where 
	RemittanceID = ts.RemitID