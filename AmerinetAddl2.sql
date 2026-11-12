--<>
/*
Run against a production mirror of CashApp_Staging
Special run of missed Amerinet transactions
*/

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
	'AmerinetAddl2.adm'
	,@PPID
	,'11/29/2025'
	,'AmerinetAddl2'
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
	Janus_Export.dbo.vPaymentsDetail vpd WITH (NOLOCK)
	where
	vpd.PayID in
	(1114832785,
	1114832788,
	1114832806,
	1114832286,
	1114832311,
	1114832332,
	1114832510,
	1114831681,
	1114835664,
	1114835797,
	1114835867,
	1114835912,
	1114835929,
	1114836049,
	1114836130,
	1114836191,
	1114836203,
	1114836282,
	1114836375,
	1114836423,
	1114836469,
	1114836513,
	1114836523,
	1114836987,
	1114836748,
	1114831075,
	1114831806,
	1114832002,
	1114832032,
	1114832081,
	1114832085,
	1114832185,
	1114830843,
	1114830879,
	1114840731,
	1114806366,
	1115646714,
	1115646646,
	1115646617,
	1115646902,
	1115646982,
	1115646878,
	1115789227,
	1115789240,
	1115789288,
	1115770555,
	1115770598,
	1115745679,
	1115745503,
	1115745870,
	1115746564,
	1115746261,
	1115745977,
	1115745699,
	1115745492,
	1115745567,
	1115745658,
	1115746337,
	1115675251,
	1115675634,
	1116005965,
	1115721308,
	1115721345,
	1115721486,
	1115721378,
	1115721369,
	1115983357,
	1115980787,
	1115983348,
	1115982136,
	1115982246,
	1115982225,
	1115980512,
	1115980554,
	1115981941,
	1115981308,
	1115981298,
	1115982646,
	1115994124,
	1115982285,
	1115984432,
	1115984014,
	1115985725,
	1115986405,
	1115981520,
	1115984091,
	1115983788,
	1115983559,
	1115985352,
	1115986316,
	1115984739,
	1115985050,
	1115984782,
	1115985656,
	1115982698,
	1115983085,
	1115983595,
	1115984758,
	1115985744,
	1115981514,
	1115983023,
	1115980827,
	1115984869,
	1115985627,
	1115981134,
	1116011893
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


