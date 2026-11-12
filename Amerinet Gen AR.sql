

Insert into 
	teDatafeed(DatafeedFileName, DatafeedTypeID, StartDate, EndDate, DFStatus)
Values
	('Amerinet2005Sup_NNN.csv',1,'10/01/2005','11/30/2005','W')
	

DECLARE @FileID int = SCOPE_IDENTITY()

insert into dbo.txDataFeedXRef
	(DataFeedID, PayId)
select
	@FileID,
	cast(r.origid as int)
from
	cashapp_staging.dbo.teRemittance r
inner join
	dbo.Payments p
on
	cast(r.origid as int) = p.payid
where 
	r.FileID = 1075
and
	p.SettleStatID = 5


select * from cashapp_staging.dbo.tePayProviderFiles
where ChecksumValue = 'AmerinetAddl2'
--order by 

