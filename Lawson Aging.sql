--This is for PROCORPSQ01 (Lawson)

select --top 3

-- TRANS_TYPE

-- ,STATUS

--,

CUSTOMER

,INVOICE

,APPLD_AMT

,TRAN_AMT

,TRANS_TYPE

-- ,datediff(dd,'2025-12-31',DUE_DATE)-1
-- 
-- ,count(*)
-- 
-- ,sum(case when TRANS_TYPE = 'I' then TRAN_AMT else -TRAN_AMT end)
-- 
-- ,sum(case when TRANS_TYPE = 'I' then  APPLD_AMT else  -APPLD_AMT end)

from dbo.AROITEMS

where 1=1

and CUSTOMER = 103

--and   STATUS <> 7

and   TRANS_DATE = '2025-10-24'-- and '2025-10-26'

and   TRAN_AMT - APPLD_AMT <> 0

and   TRAN_AMT = 19.90

and TRANS_TYPE = 'C'

and left(INVOICE, 4) = '1204'

--and   TRANS_TYPE = 'C'

-- group by 
-- 
-- CUSTOMER
-- 
-- ,DUE_DATE
-- 
-- order by 
-- 
-- CUSTOMER
-- 
-- ,DUE_DATE
