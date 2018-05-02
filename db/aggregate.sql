#
# We bulk-loaded the transactions from Mint into a table of strings.
# Convert to dates and numbers.
#
drop temporary table if exists mint_in2;
create temporary table mint_in2 as
select
  STR_TO_DATE(date, '%m/%d/%Y') as Date,
  Description,
  `Original Description`,
  convert(Amount, decimal(7,2)) as Amount,
  `Transaction Type` as type,
  mint_incoming.Category,
  `Account Name`
  from mint_incoming

#  left join skip_cat on skip_cat.category = mint_incoming.category
#  left join skip_account on skip_account.account = mint_incoming.`Account Name`
#  where skip_cat.category is null
#  and skip_account.account is null

;

set @nTransactions = (select count(*) from mint_incoming);
select @nTransactions as `Total incoming transactions`;


#
# Incoming table no longer needed.
#
drop table if exists mint_incoming;


#
# Create the base table for further analysis.
#
drop table if exists mint;
create table mint as
select
  Date,
  year_quarter(Date) as quarter,
  Description,
  `Original Description`,
  case when type = 'credit'
     then Amount
     else Amount * -1
   end as Amount,
  type,
  Category,
  `Account Name`
  from mint_in2
;


create index idx_m1 on mint(Date);
create index idx_m2 on mint(Category);
create index idx_m3 on mint(quarter);
create index idx_m4 on mint(type);


#
# Create table with overall quarterly debit and credit.
#
drop table if exists mint_top;
create table mint_top as
select
  quarter,
  mint.type,
  round(sum(mint.Amount)) as Amount
from mint
group by quarter, type
;

#
# This table has only the categories associated with activity.  Later, we will add null categories.
#
drop table if exists mint_quarter;
create table mint_quarter as
select
  a.quarter,
  a.category,
  round(sum(a.Amount)) as Amount
from mint a
group by a.quarter, a.category
order by quarter, Amount desc
;

#
# List the categories that have spending.
#
drop table if exists cat_used;
create table cat_used as
select q.category, sum(q.Amount) as Amount, color() as color
from mint_quarter as q
group by q.category
having Amount < 0
order by Amount;

#
# List the quarters that have data.
#
drop temporary table if exists quarters;
create temporary table quarters as
select distinct quarter
from mint_quarter
order by quarter;

#
# Create cartesian join:  all categories, in all quarters.
# Needed to have consistent colors and positions of categories in the pie chart.
#
drop table if exists cat_all;
create table cat_all as
select q.quarter, cu.category, cu.Amount, cu.color
from cat_used as cu
join quarters as q
order by q.quarter, cu.Amount
;

#
# This table has every category, even those with no data, for each quarter.
#
drop table if exists mint_aggregate;
create table mint_aggregate as
select
  ca.quarter,
  ca.category,
  ca.color,
  'debit' as type,
  'spending' as category_type,
  round(ifnull(q.Amount,0)) as Amount
from cat_all as ca
left join mint_quarter as q on q.category = ca.category
where q.quarter is null or q.quarter = ca.quarter
order by ca.quarter, ca.Amount
;


/*
drop table cat_all;
drop table cat_used;
drop table mint_quarter;
drop table mint_top;
*/
