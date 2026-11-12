select 
cast(p.payid as varchar(15)) + ','
from
	dbo.TmpInvoices_Prod p 
inner join
	CashApp_Staging_20260223.dbo.teAmerinetShipItem s
on
	p.PayID = s.UserDef
-- inner join
-- 	Janus_Export.dbo.payments j
-- on
-- 	p.payid = j.payid
left outer join
	dbo.ARIRemitAll a
on
	p.Invoice = a.[Trans-Rem-Nbr]
where 
	p.PaymentDeviceTypeCD = 13
and
	a.[Trans-Rem-Nbr] is null
and
	p.TransactionDtm between '10/01/2025' and '11/30/2025'
-- and
-- 	j.SettleStatID <> 5
and
	p.Invoice not in (select [Trans-Rem-Nbr] from [Amerinet_20251104_ARIREMIT_Prod])
-- order by 
-- 	p.TransactionDtm

-- select p.* from
-- dbo.TmpInvoices_Prod p 
-- left outer join
-- 	CashApp_Staging_20260223.dbo.teAmerinetShipItem a
-- on
-- 	p.PayID = a.UserDef
-- where 
-- 	p.PaymentDeviceTypeCD = 13
-- and
-- 	a.[Trans-Rem-Nbr] is null
-- and
-- 	p.TransactionDtm between '10/12/2025' and '11/30/2025'
-- order by 
-- 	p.TransactionDtm