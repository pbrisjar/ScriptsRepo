/*
Run against CashApp_Staging
Some amount checks for FOOMP
*/
select sum(Amount) as subtr from dbo.teFOOMPPaymentSum (NOLOCK)
where
fileid = 412
and
AmountSign = '-'
and
(AmountCat like '%NON_SET'
or
AmountCat = 'BATCH HEADER'
or
AmountCat = 'ADJUSTMENT')
and merchantnum in
(select merchantnum from teFoompTransDtl where MerchantRefNum not like '%K%' and TxAmountSg = '-' and PaymentFlag = 'Y' and fileid = 411)

select sum(Amount) as chargebackamt from dbo.teFOOMPPaymentSum WITH (NOLOCK)
where
fileid = 412
and
AmountCat = 'CHARGEBACK'

select sum(Amount) as addamt  from dbo.teFOOMPPaymentSum WITH (NOLOCK)
where
fileid = 412
and
AmountSign <> '-'
and
(AmountCat = 'BATCH HEADER'
or
AmountCat like '%NON_SET')
and merchantnum in
(select distinct(merchantnum) from teFoompTransDtl 
	where MerchantRefNum not like '%K%' and TxAmountSg <> '-' and PaymentFlag = 'Y' and fileid = 411)

