/*
This should get the "missing" FOOMP transactions into remittance.
It has not yet been fully tested.
*/

create table #tmpRem
	(SeqNum		int identity(1,1)
	,RmtId		int
	,CustomerID	int
	,TransType	varchar(4)
	,TransNbr	int
	,TransRemNbr	varchar(20)
	,Amount		money)
	
insert into #tmpRem
	(RmtId
	,CustomerID
	,TransType
	,TransNbr
	,TransRemNbr
	,Amount)
Select
	r.RemittanceID
	,r.CustomerID
	,r.TransType
	,coalesce(ta.SeqNum, 0)
	,r.TransRemNbr
	,r.AppldAmt
From
	teRemittance r
inner join
	#tmpPay ta
on
	r.CustomerID = ta.Customer
where
	r.RemitType = 'D'
and
	ta.AriGen = 'N'	
and
	r.HdrFileId = 99998
and
	r.CustomerID <> 108
and
	r.TransDate >= '10/01/2025'  --special startup filtering
ORDER BY
	r.CustomerID

                
insert into teARIRemit
	(RmtId
	,CustomerID
	,TransType
	,TransNbr
	,TransRemNbr
	,RemitSeq
	,Amount)
select
	RmtId
	,CustomerID
	,TransType
	,TransNbr
	,TransRemNbr
	,SeqNum
	,Amount
from #tmpRem
ORDER BY SeqNum

DROP TABLE #tmpPay
DROP TABLE #tmpRem
