/*
Run against a production mirror of CashApp_Staging
Special run of missed Amerinet transactions
*/

--drop table TmpLostFOOMP
--drop table TmpRemit
DECLARE @PPID int
		,@AcqID 	int
		,@FileID	int
			
SELECT
	@PPID = PPID,
	@AcqID = AcqID
FROM
	dbo.tdPayProviders WITH (NOLOCK)
WHERE
	PPShort = 'Amerinet'


--Generate file entry

Insert into dbo.tePayProviderFiles
	([FileName]
	,PPID
	,RptDate
	,ChecksumValue
	,ARIStatus)
Select
	'AmerinetAddl.adm'
	,@PPID
	,'12/31/2025'
	,'AmerinetAddl'
	,'P'

Select @FileID = SCOPE_IDENTITY()

--Now, put data into temp remittance table.  
create table #TmpRemit (RemSeqNum	int identity(1,1), 
					FileID			int,
					PPID			int,
					HdrFileId		int,
					OrigId			int,
					CardType		int,
					Customer		int,
					TransType		varchar(4),
					TransNbr		varchar(4), -- # from header
					SeqNbr			varchar(4),
					TransRemNbr		varchar(20),
					AppldAmt		money,
					AuthCode		varchar(6),
					OriginalBatch	varchar(20),
					RemitType		char(1),
					TransDate		datetime,
					ProcDate		DateTime)
					
--------------------------------------------------
-- Translate data and insert
--------------------------------------------------

insert into #TmpRemit
	(FileID
	,PPID
	,HdrFileId
	,OrigId
	,CardType
	,Customer
	,TransType
	,TransNbr
	,SeqNbr
	,TransRemNbr
	,AppldAmt
	,AuthCode
	,OriginalBatch
	,RemitType
	,TransDate
	,ProcDate)
select
	@FileID 
	,@PPID
	,@FileID 
	,vpd.PayID
	,vpd.PaymentDeviceTypeCD as CardType
	,107
	,case 
		when vpd.IsReversal = 0 then 'I'
		when vpd.IsReversal = 1 then 'C'
	end
	,1
	,1
	,TransRemNbr = cast(vpd.CatalogID * power(cast(10 as bigint), 10) + vpd.SourceOrderNbr as varchar(20) )
	,vpd.PaymentAmt
	,0000
	,vpd.MerchantNbr
	,'D'
	,vpd.TransactionDtm
	,vpd.TransactionDtm + 1
	from
	Janus_Export.dbo.vPaymentsDetail vpd (NOLOCK)
	where
	vpd.PayID in
	(1115984782,
	
	1115980827,
	
	1115789227,
	
	1115646617,
	
	1115983788,
	
	1115981134,
	
	1115985050,
	
	1115721486,
	
	1115745699,
	
	1115982698,
	
	1116011893,
	
	1115746337,
	
	1115984091,
	
	1115646646,
	
	1115982136,
	
	1115982225,
	
	1115985627,
	
	1115746261,
	
	1115721378,
	
	1115983595,
	
	1115984739,
	
	1115745658,
	
	1115983023,
	
	1115982246,
	
	1115789240,
	
	1115646878,
	
	1115646902,
	
	1115770555,
	
	1115721369,
	
	1115985725,
	
	1115986316,
	
	1115981520,
	
	1115745567,
	
	1115721308,
	
	1115980787,
	
	1115770598,
	
	1115983085,
	
	1115994124,
	
	1115980512,
	
	1115982646,
	
	1115985352,
	
	1115981514,
	
	1115789288,
	
	1115745977,
	
	1115985744,
	
	1115986405,
	
	1115984869,
	
	1115981298,
	
	1115983357,
	
	1115983348,
	
	1115646714,
	
	1115746564,
	
	1115745679,
	
	1115980554,
	
	1115984432,
	
	1115981941,
	
	1115984758,
	
	1115675634,
	
	1115985656,
	
	1116005965,
	
	1115745870,
	
	1115982285,
	
	1115646982,
	
	1115983559,
	
	1115981308,
	
	1115984014,
	
	1115721345,
	
	1115745492,
	
	1115745503,
	
	1115675251
	
	)

Insert into dbo.teRemittance
	(FileID
	,PPID
	,HdrFileId
	,OrigId
	,CardType
	,CustomerID
	,TransType
	,TransNbr
	,SeqNbr
	,TransRemNbr
	,AppldAmt
	,OrigAmt
	,AuthCode
	,OriginalBatch
	,RemitType
	,TransDate
	,ProcDate
	,RemitSeq)
select
	FileID
	,PPID
	,HdrFileId
	,OrigId
	,CardType
	,Customer
	,TransType
	,TransNbr
	,SeqNbr
	,TransRemNbr
	,AppldAmt
	,AppldAmt
	,AuthCode
	,OriginalBatch
	,RemitType
	,TransDate
	,ProcDate
	,RemSeqNum
from #TmpRemit

--now generate header information
insert into dbo.teRemittanceHdr
	(Customer
	,PPID
	,FileID
	,ProcessDate
	,TransNbr
	,OrigAmt)
select
	Customer
	,@PPID
	,@FileID
	,ProcDate
	,0
	,sum(case when [TransType] = 'I' then cast([AppldAmt] as money) else -cast([AppldAmt] as money) end) 
from #TmpRemit
Group by Customer, ProcDate
Order by Customer

drop table #TmpRemit

-- select * from TmpLostFOOMP
-- select * from TmpRemit order by TransDate

-- select 
-- --	ProcDate,
-- 	TransAmt = sum(case when [TransType] = 'I' then [AppldAmt] else -[AppldAmt] end) 
-- from 
-- 	TmpRemit
-- where ProcDate between '10/01/2025'  and '10/31/2025'
-- Group by
-- 	ProcDate
-- order by
-- 	ProcDate
