--drop table DecDiscUnapp

select TransRemNbr, count(*) as cnt
into DiscUnappND
from teRemittance
where Customerid = 105
and TransDate between '10/27/2025' and '12/28/2025'
and RemitType = 'D'
--and TransRemNbr not in (select TransRemNbr from CashApp_Staging.dbo.NovDiscUnapp)
group by TransRemNbr having count (*) > 1


select TransRemNbr, count (*) as cnt
into AmexUnappND
from teRemittance
where Customerid = 106
and TransDate between '10/27/2025' and '12/28/2025'
and RemitType = 'D'
--and TransRemNbr not in (select TransRemNbr from CashApp_Staging.dbo.NovAmexUnapp)
group by TransRemNbr having count (*) > 1

select max(TransDate) from teremittance

select a.* 

from DecAmexUnapp a 
--where customer = 108 and tbl = 22

left outer join Import.dbo.working2 b

            on ( a.[TransRemNbr] = b.Invoice )

where   ( b.Invoice is null)

and                   a.Customer  not in (108, 109)

and a.[Trans-Rem-Nbr] not like '999%'