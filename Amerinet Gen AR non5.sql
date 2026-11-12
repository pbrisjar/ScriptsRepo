

Insert into 
	teDatafeed(DatafeedFileName, DatafeedTypeID, StartDate, EndDate, DFStatus)
Values
	('Non5Amerinet2025Sup_NNN.csv',1,'10/01/2025','11/30/2025','W')
	

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
	p.SettleStatID <> 5



