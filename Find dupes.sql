/*
a few queries to find FOOMP dupes
*/

select origid, count (*) from teRemittance
where fileid = 603
group by origid having count (*) > 1



select [Trans-Rem-Nbr], count (*)
from dbo.[20251227_ARIREMIT_PROD]
where customer = 103
group by [Trans-Rem-Nbr] having count (*) > 1