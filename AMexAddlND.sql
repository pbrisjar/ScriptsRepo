/*
Run against CashApp_Staging DMSQL01
This proc will populate an interim table for supplemental ARI report.
This is based on data in AmexUnappND 
(which has all duplicate transactions from the matching process for November and December)
*/

--truncate table AmexReplace
-- Insert Into AmexReplace
-- (TransRemNbr
-- ,NewTrans
-- ,Amount
-- ,TransType)
select distinct t.TransREmNbr
	,NewTrans = cast(cp.CatalogID * power(cast(10 as bigint), 10) 
		+ f.OrdID as varchar(20) )
	,f.Amount
	,t.TransType
Into AmexReplace
from dbo.[AmexUnappND] u
inner join teRemittance t 
on t.TransRemNbr = u.TransRemNbr
inner join dbo.teAmexROC11Dtl x
on x.TxDtlID = t.OrigID
inner join dbo.teTxAmexReference f
on (Right(cast(f.AcctNum as varchar(20)),4) = cast(x.CMNum as varchar(4))
	and
	f.Amount = x.RocAmount
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
-- 
-- 
-- delete  from
-- AmexReplace 
-- where
-- NewTrans in
-- (select NewTrans
-- from AmexReplace a
-- left outer join
-- Import.dbo.OrdTrans o
-- on
-- cast(cast(Right(a.NewTrans,8) as bigint) as varchar(8)) = o.OrdID
-- and
-- a.Amount = o.Amount
-- where 
-- left(a.NewTrans, 4) <> left(a.TransRemNbr, 4)
-- and
-- o.ordid is null
-- )


select * from teRemittance where TransRemNbr in (select TransRemNbr from AmexUnappND)
order by TransRemNbr, AppldAmt