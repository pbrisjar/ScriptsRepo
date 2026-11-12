--drop table DiscUnappJ

select TransRemNbr, count(*) as cnt
into DiscUnappJ
from teRemittance
where Customerid = 105
and TransDate between '12/28/2025' and '01/31/2026'
and RemitType = 'D'
and TransRemNbr not in (select TransRemNbr from cashapp_staging_20260106.dbo.DiscUnappND)
group by TransRemNbr having count (*) > 1


select TransRemNbr, count (*) as cnt
into AmexUnappJ
from teRemittance
where Customerid = 106
and TransDate between '12/28/2025' and '01/31/2026'
and RemitType = 'D'
and TransRemNbr not in (select TransRemNbr from cashapp_staging_20260106.dbo.AmexUnappND)
group by TransRemNbr having count (*) > 1

--select max(TransDate) from teremittance

