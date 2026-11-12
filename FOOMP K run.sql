/*
RUn against CashApp_Staging
This is an extract of the Foomp to remittance proc to check / test the "K" transaction matching query.
*/
DECLARE @PPID int
		,@HdrData	varchar(80)
		,@AcqID 	int
		,@CollMerch	bigint
		,@CollCard	int
		,@CafeMerch	bigint
		,@FileID	int
			
SELECT
	@PPID = PPID,
	@AcqID = AcqID
FROM
	dbo.tdPayProviders WITH (NOLOCK)
WHERE
	PPShort = 'FOOMP'

Select @CollMerch = 7666434			
	,@CollCard = 99
	,@CafeMerch = 5963537
	,@FIleID = 781


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
	,SetNum = substring(T.MerchantRefNum,11,2)
FROM 
	dbo.teFoompTransDtl T WITH (NOLOCK)
WHERE
	T.MerchantNum <> @CollMerch
and
	T.MerchantNum <> @CafeMerch
and
	T.MerchantRefNum like '%K%'
and 
	T.FileID = @FileID 



select 

DISTINCT td.DtlID, p.OrdId, p.SettleID, SetChk = Right(p.SettleID,2), td.SetNum into #tmpCHeck

from #tmpKTrans td

inner join Janus_Export.dbo.Payments p on p.AppCode = td.AuthCD

inner join Janus_Export.dbo.Merchants m on cast(m.MerchantNum as bigint) = td.MerchantNum

inner join dbo.txFoompPayType t on t.ProductCode = td.CardType

where 

 cast(datediff(dd,+0,p.TranDate) as datetime) = td.TransactionDate

and p.Amount = td.TxAmount

and p.SeqNum = td.SeqNum

and m.AcqId = 5

and p.SettleStatID <> 0

and p.PaymentDeviceTypeCD = t.PaymentDeviceTypeCD

--and Right(p.SettleID,2) = td.SetNum

--drop table #tmpCHeck where SetChk <> SetNum

select * from #tmpCHeck where SetChk <> SetNum   

-- DECLARE @PPID int
-- 		,@HdrData	varchar(80)
-- 		,@AcqID 	int
-- 		,@CollMerch	bigint
-- 		,@CollCard	int
-- 		,@CafeMerch	bigint
-- 		,@FileID	int
			
-- SELECT
-- 	@PPID = PPID,
-- 	@AcqID = AcqID
-- FROM
-- 	dbo.tdPayProviders WITH (NOLOCK)
-- WHERE
-- 	PPShort = 'FOOMP'
-- 
-- Select @CollMerch = 7666434			
-- 	,@CollCard = 99
-- 	,@CafeMerch = 5963537
-- 	,@FIleID = 781

SELECT 
	count (*)
FROM 
	dbo.teFoompTransDtl T WITH (NOLOCK)
WHERE
	T.MerchantNum <> @CollMerch
and
	T.MerchantNum <> @CafeMerch
and
	T.MerchantRefNum like '%K%'
and 
	T.FileID = @FileID 