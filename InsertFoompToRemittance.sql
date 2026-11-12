insert into teRemittance
	(
	FileID 
	,PPID
	,HdrFileId
	,OrigID
	,CardType
	,CustomerID
	,TransType
	,TransNbr
	,SeqNbr
	,TransRemNbr
	,RemitSeq   
	,AppldAmt
	,AuthCode
	,OriginalBatch
	,ProcDate	
	,TransDate
	,RemitType)

select
	td.FileID
	,2
	,1036
	,td.DtlID
	,7
	,103
	,'I'
	,2
	,2
	,cast(coalesce(cp.CatalogID, td.MerchantNum) * power(cast(10 as bigint), 10) 
					+ td.MerchantRefNum as varchar(20) )
	,12404
	,td.TxAmount
	,td.AuthCD
	,td.MerchantNum
	,td.PayEffDate
	,td.TransactionDate
	,'D'
	from
	teFoompTransDtl td WITH (NOLOCK)
	left outer join 
	Janus_Export.dbo.Merchants m WITH (NOLOCK) 
	on
		cast (td.MerchantNum as bigint) = cast (m.merchantnum as bigint)
	full outer join
	Janus_Export.dbo.teCompanyPartner cp WITH (NOLOCK)
	on
		m.PartnerCD = cp.TaxPartnerCode
where
td.DtlID = 3631773

-- select distinct HDrFileID from teREmittance where
-- fileid = 1035 and PPID = 2