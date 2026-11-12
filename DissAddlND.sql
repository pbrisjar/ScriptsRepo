
--truncate table AmExReplace
-- Insert Into AmExReplace
-- (TransRemNbr
-- ,NewTrans
-- ,Amount
-- ,TransType)
select t.TransRemNbr
	,NewTrans = cast(cp.CatalogID * power(cast(10 as bigint), 10) 
		+ f.OrdID as varchar(20) )
	,f.Amount
	,t.TransType
Into AmExReplace
from dbo.[AmExUnappND] u
inner join teRemittance t 
on t.TransRemNbr = u.TransRemNbr
inner join dbo.teAmExTXDtl x
on x.TxDSeqNum = t.OrigID
inner join dbo.teTxDiscoverReference f
on (Right(cast(f.AcctNum as varchar(20)),4) = cast(x.cardAcctNum as varchar(4))
	and
	f.Amount = x.TxAmount
	and
	f.TxDate = x.TxDate)
left outer join 
	Janus_Export.dbo.Merchants m WITH (NOLOCK) 
	on
		f.MerchNum = m.merchantnum
left outer join
	Janus_Export.dbo.teCompanyPartner cp WITH (NOLOCK)
	on
		m.PartnerCD = cp.TaxPartnerCode
where 
 u.TransRemNbr not like '999%'
and Right(t.TransRemNbr,6) <> Right(LTRIM(RTRIM(f.ORdID)), 6)


select count(*) from
AmExReplace
where 
left(NewTrans, 4) <> left(TransRemNbr, 4)

select * from teRemittance where TransRemNbr in (select TransRemNbr from AmExUnappND)
order by TransRemNbr, AppldAmt