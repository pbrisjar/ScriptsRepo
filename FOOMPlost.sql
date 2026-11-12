/*
Run against a production mirror of CashApp_Staging
THIS is the query to run...
It should get you every FOOMP transaction that was dropped and not reported on ARI due to the merchant issues.
*/

--drop table TmpLostFOOMP
--drop table TmpRemit
DECLARE @PPID int
		,@HdrData	varchar(80)
		,@AcqID 	int
		,@CollMerch	bigint
		,@CollCard	int
		,@CafeMerch	bigint
		,@HdrFileID	int
		,@DtlFileID	int
			
SELECT
	@PPID = PPID,
	@AcqID = AcqID
FROM
	dbo.tdPayProviders (NOLOCK)
WHERE
	PPShort = 'FOOMP'

Select @CollMerch = 7666434			
	,@CollCard = 99
	,@CafeMerch = 5963537

--Generate Header and transaction file entries

Insert into dbo.tePayProviderFiles
	([FileName]
	,PPID
	,RptDate
	,ChecksumValue
	,ARIStatus)
Select
	'FOOMPMerchantSupplementalHdr.adm'
	,@PPID
	,'11/14/2025'
	,'FOOMPMerchantSupplementalHdr'
	,'P'

Select @HdrFileID = SCOPE_IDENTITY()

Insert into dbo.tePayProviderFiles
	([FileName]
	,PPID
	,RptDate
	,ChecksumValue
	,ARIStatus)
Select
	'FOOMPMerchantSupplementalDtl.adm'
	,@PPID
	,'11/14/2025'
	,'FOOMPMerchantSupplementalDtl'
	,'P'

Select @DtlFileID = SCOPE_IDENTITY()

--Identify dropped transactions

select * --TransactionDate, sum(case when TxAmountSg = '-' then -TxAmount else TxAmount end)
into Scratch.dbo.TmpLostFOOMP
from dbo.teFoompTransDtl
where
DtlID not in
(select Origid from teRemittance where PPID = 2)
and  CardType not in ('AMEX','CHASE')
and MerchantNum <> @CafeMerch
--and TransactionDate = '02/23/2026'
-- group by TransactionDate
-- order by TransactionDate

--Do standatd FOOMPtoRemittance processing

--Identify and match up 'K' transactions
create table #TmpOrds	(DtlID	int,
			OrdId	varchar(20)	)				


Create table #tmpKTrans
	(DtlId			int
	,AuthCd			varchar(8)
	,MerchantNum		bigint
	,TransactionDate	datetime
	,TxAmount		int
	,SeqNum			int
	,CardType		varchar(255)
	,SetNum			char(2)) 

insert into #tmpKTrans
	(DtlId	
	,AuthCd	
	,MerchantNum
	,TransactionDate
	,TxAmount
	,SeqNum
	,CardType
	,SetNum)
SELECT 
	T.DtlId
	,T.AuthCd
	,MerchantNum = cast(T.MerchantNum as bigint)
	,T.TransactionDate
	,TxAmount = (T.TxAmount * 100)
	,SeqNum = cast(substring(T.MerchantRefNum,13,4) as int)
	,CardType
	,SetNum = substring(T.MerchantRefNum,11,2) --PA 1/31/2026 refine matching
FROM 
	Scratch.dbo.TmpLostFOOMP T (NOLOCK)
WHERE
	T.MerchantNum <> @CollMerch
and
	T.MerchantNum <> @CafeMerch
and
	T.MerchantRefNum like '%K%'

insert into #TmpOrds

(DtlId,

OrdId)

select 

DISTINCT td.DtlID, p.OrdId

from #tmpKTrans td

inner join Janus_Export.dbo.Payments p on p.AppCode = td.AuthCD

--inner join Janus_Export.dbo.Settlements s on s.SettleID = p.SettleID

inner join Janus_Export.dbo.Merchants m on cast(m.MerchantNum as bigint) = td.MerchantNum

inner join dbo.txFoompPayType t on t.ProductCode = td.CardType

where 

 cast(datediff(dd,+0,p.TranDate) as datetime) = td.TransactionDate

and p.Amount = td.TxAmount

and p.SeqNum = td.SeqNum

and m.AcqId = 5

and p.SettleStatID <> 0

and p.PaymentDeviceTypeCD = t.PaymentDeviceTypeCD

and Right(p.SettleID,2) = td.SetNum

--add in the rest
insert into #TmpOrds
	(DtlID
	,OrdID)
select
	DtlID
	,MerchantRefNum 
from 
	Scratch.dbo.TmpLostFOOMP
where 
	DtlID not in
	(select DtlId 
	from #TmpOrds)
and
	merchantnum <> @CafeMerch --exclude Recharge Cafe

--Now, put data into temp remittance table.  persist table for troubleshooting / etc.
create table Scratch.dbo.TmpRemit (RemSeqNum	int identity(1,1), 
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

insert into Scratch.dbo.TmpRemit
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
	@DtlFileID --whatever we enter into tePayPRoviderFiles for transaction file.
	,@PPID
	,@HdrFileID --whatever we enter into tePayPRoviderFiles for payment (header) file.
	,td.DtlId
	,coalesce(fpt.PaymentDeviceTypeCD, '98') as CardType
	,ap.CustomerID as Customer
	,case 
		when td.TxAmountSg = '' then 'I'
		when td.TxAmountSg = '-' then 'C'
	end
	,1
	,1
	,case
		when o.OrdId like '%K%' then
			'99900K0' + cast((@PPID *10000000) + td.DtlId as varchar(15))
		else	
			cast(coalesce(cp.CatalogID, td.MerchantNum) * power(cast(10 as bigint), 10) 
				+ coalesce(o.OrdId, td.MerchantRefNum) as varchar(20) )
	end as TransRemNbr				
	,td.TxAmount
	,td.AuthCD
	,td.MerchantNum
	,rt.RemitType
	,td.TransactionDate
	,td.PayEffDate
	from
	teFoompTransDtl td WITH (NOLOCK)
	inner join
	#TmpOrds o
	on
		o.DtlId = td.DtlId
	inner join txFoompRemitType rt
	on
		td.PaymentFlag = rt.FoompPayFlag	
	left outer join 
	Janus_Export.dbo.Merchants m WITH (NOLOCK) 
	on
		cast (td.MerchantNum as bigint) = cast (m.merchantnum as bigint)
	full outer join
	Janus_Export.dbo.teCompanyPartner cp WITH (NOLOCK)
	on
		m.PartnerCD = cp.TaxPartnerCode
	left outer join txFoompPayType fpt WITH (NOLOCK)
	on
		td.CardType = fpt.ProductCode
	inner join txAcquirerPayDeviceCustomer ap WITH (NOLOCK)
	on
	  ap.AcqId = 5
	  and
	  ap.PaymentDeviceTypeCD = fpt.PaymentDeviceTypeCD
	where
	m.AcqId = 5	

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
from Scratch.dbo.TmpRemit

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
	,@HdrFileID
	,ProcDate
	,0
	,sum(case when [TransType] = 'I' then cast([AppldAmt] as money) else -cast([AppldAmt] as money) end) 
from Scratch.dbo.TmpRemit
Group by Customer, ProcDate
Order by Customer

drop table #tmpOrds
drop table #tmpKTrans
-- drop table scratch.dbo.TmpLostFOOMP
-- drop table scratch.dbo.TmpRemit

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
