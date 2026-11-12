select  TransactionDate, TxAmount, TxAMountSg, count (*) 
from dbo.teFoompTransDtl
where DtlID in
(
select origid from teRemittance where FileID = 1067 and TransRemNbr like '%K%'
)
group by TransactionDate, TxAmount, TxAmountSg
--select * from tePayProviderFiles order by importdate desc 