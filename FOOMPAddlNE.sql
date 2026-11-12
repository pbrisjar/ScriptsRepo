/*
Run against a production mirror of CashApp_Staging
Special run of missed FOOMP transactions
*/

--drop table TmpLostFOOMP
--drop table TmpRemit
DECLARE @PPID int
		,@AcqID 	int
		,@FileID	int
		,@HdrFile	int			
SELECT
	@PPID = PPID,
	@AcqID = AcqID
FROM
	dbo.tdPayProviders WITH (NOLOCK)
WHERE
	PPShort = 'FOOMP'

Insert into dbo.tePayProviderFiles
	([FileName]
	,PPID
	,RptDate
	,ChecksumValue
	,ARIStatus)
Select
	'FOOMPAddlNEHdr.adm'
	,@PPID
	,'10/20/2025'
	,'FOOMPAddlNEHdr'
	,'P'

Select @HdrFile = SCOPE_IDENTITY()


--Generate file entry

Insert into dbo.tePayProviderFiles
	([FileName]
	,PPID
	,RptDate
	,ChecksumValue
	,ARIStatus)
Select
	'FOOMPAddlNE.adm'
	,@PPID
	,'10/20/2025'
	,'FOOMPAddlNE'
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
	,@HdrFile
	,vpd.PayID
	,vpd.PaymentDeviceTypeCD as CardType
	,103
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
	Janus_Export.dbo.vPaymentsDetail vpd WITH (NOLOCK)
	where
	vpd.PayID in
	(1114866546,
1114866547,
1114866548,
1114866549,
1114866550,
1114866587,
1114866588,
1114866614,
1114866616,
1114866621,
1114866622,
1114866968,
1114866998,
1114878957,
1114878962,
1114878968,
1114878970,
1114879329,
1114883252,
1114884062,
1114885852,
1114885860,
1114885925,
1114885927,
1114886601,
1114887426,
1114887431,
1114887437,
1114887440,
1114887474,
1114887478,
1114887490,
1114887947,
1114888039,
1114889114,
1114889117,
1114889936,
1115116890,
1115117253,
1115128627,
1114866054,
1114866055,
1114866057,
1114866058,
1114866059,
1114866060,
1114866062,
1114866063,
1114866065,
1114866067,
1114866068,
1114866069,
1114866070,
1114866071,
1114866072,
1114866073,
1114866074,
1114866077,
1114866325,
1114866448,
1114866458,
1114866464,
1114866465,
1114866699,
1114866739,
1114871374,
1114871381,
1114871385,
1114882740,
1114882745,
1114884835,
1114889687,
1114889692,
1114890079,
1114890085,
1114890222,
1115117351,
1115124404
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
	,@HdrFile
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
-- where PRocDate between '10/01/2025'  and '10/31/2025'
-- Group by
-- 	ProcDate
-- order by
-- 	ProcDate
