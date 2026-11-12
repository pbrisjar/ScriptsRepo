/*
Run against a production mirror of CashApp_Staging
Special run of missed AmEx reversals
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
	dbo.tdPayProviders (NOLOCK)
WHERE
	PPShort = 'AmEx'


--Generate file entry

Insert into dbo.tePayProviderFiles
	([FileName]
	,PPID
	,RptDate
	,ChecksumValue
	,ARIStatus)
Select
	'AmExOctRevs.adm'
	,@PPID
	,'10/31/2025'
	,'AmExOctRevs'
	,'P'

Select @FileID = SCOPE_IDENTITY()

--Now, put data into temp remittance table.  persist table for troubleshooting / etc.
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
	,105
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
	(43809115,
	1114282819,
	43830553,
	1114951296,
	1114951317,
	1114951346,
	1114951372,
	44184931,
	44184943,
	44215129,
	44221813,
	44223022,
	1115313406,
	1115313907,
	1115334788,
	1115332148,
	1115332187,
	1115339133,
	1115468839
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
