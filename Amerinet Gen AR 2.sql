

Insert into 
	teDatafeed(DatafeedFileName, DatafeedTypeID, StartDate, EndDate, DFStatus)
Values
	('Amerinet2025Sup2_NNN.csv',1,'10/01/2025','11/30/2025','W')
	

DECLARE @FileID INT = SCOPE_IDENTITY()

insert into dbo.txDataFeedXRef
	(DataFeedID, PayId)
select
	@FileID
	,1114831169



