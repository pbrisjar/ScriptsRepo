/*
Run this against cashapp_staging on dmsql01
This will list all transactions reported by Amerinet that were not reported to Accounting for the month of November.
2025Nov_ARIREMIT_Prod has all Amerinet transactions reported to accounting for the month of November.
*/

select ShipDate, count (*)
from teAmerinetShipItem
where 
ShipDate between '11/01/2025' and '11/30/2025'
and
ShipItemId in
(select r.origid from
teRemittance r
left outer join 
[2025Nov_ARIREMIT_Prod] p
on
r.TransRemNbr = p.[Trans-Rem-Nbr]
where
p.[Trans-Rem-Nbr] is null
and
r.CustomerID = 107)
group by ShipDate