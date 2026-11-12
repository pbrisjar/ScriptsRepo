/*
Run against Janus_Export
These are the queries I used to to the Merchant / Acct-Unit troubleshooting.
*/

select *  from vpaymentsdetail
where payid in
(1122433264,
1122433528,
1122388114
)

select * from dbo.txDataFeedXRef
where payid in
(1122433264,
1122433528,
1122388114
)

select * from dbo.txCompanyLawson 
where CompanyID = 
(select companyid  from vpaymentsdetail
where payid in
(1122433264
))

select * from Merchants m
left outer join teCompanyPartner c
on
m.PartnerCD = c.TaxPartnerCode
where
c.TaxPartnerCode is null

select companyid from teCompanyPartner where TaxPartnerCode = 33

select * from dbo.txCompanyLawson l
left outer join teCompanyPartner p
on
l.CompanyID =  p.CompanyID
where p.CompanyID is null

select * from dbo.txCompanyLawson l
right outer join teCompanyPartner p
on
l.CompanyID =  p.CompanyID
where l.CompanyID is null


select * from Merchants where merchantnum = '67435500186' -- azteca

select companyid from teCompanyPartner where TaxPartnerCode = 33 --azteca


select * from Merchants where lower(merchant) like '%ztar%'
--merchant id's - all partnercd 29 - this is a problem this has AccountUNit 0195
-- 2120
-- 119
-- 316
-- 77
-- 2027
-- 553
-- 810

select * from Merchants where lower(merchant) like '%movid%'
--no entry at all

select * from Merchants where lower(merchant) like '%qwest%'
--merchant id's - no PartnerCD
-- 3
-- 107

select * from dbo.txCompanyLawson 
where CompanyID = 
(
select companyid from teCompanyPartner where TaxPartnerCode = 29
)

select * from Merchants where merchantnum in
('7655416',
'67435500186',
'5360493209',
'601101006472698')

