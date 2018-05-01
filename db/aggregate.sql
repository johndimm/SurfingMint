#
# Define the period of time for all analysis.
# It is called a "quarter" here, but current is set to month.
#
drop function if exists year_quarter;
delimiter //
create function year_quarter(theDate DATE)
returns varchar(255)
begin
  # Month
  return DATE_FORMAT(theDate, '%Y-%m');

  # Year
  return year(theDate);

  # Quarter
  return
     concat(year(theDate),
     " Q",
     1 + floor((month(theDate) - 1) / 3.0));
end //
delimiter ;

#
# Skip non-discretionary spending categories.
#
drop table if exists skip_cat;
create table skip_cat
(
  id int auto_increment primary key,
  category varchar(255)
);
load data local infile 'skip_cat.txt' into table skip_cat (category);

#
# Skip some specified accounts.
#
drop table if exists skip_account;
create table skip_account
(
  id int auto_increment primary key,
  account varchar(255)
);
load data local infile 'skip_account.txt' into table skip_account (account);

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
  left join skip_cat on skip_cat.category = mint_incoming.category
  left join skip_account on skip_account.account = mint_incoming.`Account Name`
  where skip_cat.category is null
  and skip_account.account is null
;

set @nTransactions = (select count(*) from mint_incoming);
set @nValidTransactions = (select count(*) from mint_in2);

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
  convert(Amount, decimal(7,2)) as Amount,
  case when type = 'credit'
     then convert(Amount, decimal(7.2))
     else convert(Amount, decimal(7,2)) * -1
   end as signed_amount,
  type,
  Category,
  `Account Name`
  from mint_in2
;

create index idx_m1 on mint(Date);
create index idx_m2 on mint(Category);
create index idx_m3 on mint(quarter);
create index idx_m4 on mint(type);



select @nTransactions as `Total incoming transaction`;
select @nValidTransactions as `Number of discretionary transactions`;

select 'mint transactions' as 'table description', mint.* from mint
limit 1\G

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
# Spending is what percent of income, by quarter?
#
drop table if exists mint_pc;
create table mint_pc as
select a.*,
  round(100 * a.Amount / b.Amount) as pcIncome
from mint_top as a
join mint_top as b on a.quarter=b.quarter and b.type='debit'
;

create index idx_mpc on mint_pc(type);
create index idx_mpc2 on mint_pc(quarter);


#
# This table has only the categories associated with spending.  Later, we will add null categories.
#
drop table if exists mint_quarter;
create table mint_quarter as
select
  a.*,
  b.category,
  round(sum(b.Amount)) as sumAmount,
  (100 * sum(b.Amount) / a.Amount) as pcAmount
from mint_pc as a
join mint as b on
  a.quarter = b.quarter
  and a.type = b.type

# left join monthly_payments as mp on mp.Description = b.Description
# and mp.Amount = b.Amount
# where mp.Description is null

group by a.quarter, a.type, b.category
having pcAmount > 0.75
order by quarter, pcAmount desc
;


drop table if exists mint_other;
create table mint_other as
select quarter, sum(sumAmount) as Amount
from
(
select
  a.*,
  b.category,
  round(sum(b.Amount)) as sumAmount,
  (100 * sum(b.Amount) / a.Amount) as pcAmount
from mint_pc as a
join mint as b on
  a.quarter = b.quarter
  and a.type = b.type

# left join monthly_payments as mp on mp.Description = b.Description
# and mp.Amount = b.Amount
# where mp.Description is null

group by a.quarter, a.type, b.category
having pcAmount <= 0.75
order by quarter, pcAmount desc
) as t
group by quarter
order by quarter;
;


drop table mint_pc;

#
# Define colors for bars for each category.
#
drop function if exists hex2;
delimiter //
create function hex2()
returns char(2)
begin
  set @i = 30 + 140 * rand();
  set @h = hex(@i);
  return (select concat(
    case when length(@h) < 2 then '0' else '' end,
    @h
  ));
end //
delimiter ;

#
# Get random colors.
#
drop function if exists color;
delimiter //
create function color()
returns varchar(10)
begin
  return concat("#",hex2(),hex2(),hex2());
end //
delimiter ;


#
# List the categories that have data.
#
drop table if exists cat_used;
create table cat_used as
select category, sum(sumAmount) as Amount, color() as color
from mint_quarter
where type='debit'
group by category
order by Amount desc;

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
#
drop table if exists cat_all;
create table cat_all as
select q.quarter, mu.category, mu.Amount, mu.color
from cat_used as mu
join quarters as q
;

#
# This table has every category, even those with 0 data, for each quarter.
#
drop table if exists mint_aggregate;
create table mint_aggregate as
select
  ca.quarter, ca.category, ca.color, 'debit' as type, 'spending' as category_type,
  ifnull(q.Amount,0) as Amount,
  ifnull(pcIncome,0) as pcIncome,
  ifnull(sumAmount,0) as sumAmount,
  ifnull(pcAmount, 0) as pcAmount
from cat_all as ca
left join mint_quarter as q on q.category = ca.category
where q.quarter is null or q.quarter = ca.quarter
and q.type = 'debit'
order by ca.quarter, ca.Amount desc
;

insert into mint_aggregate
(quarter, category, color, type, category_type, sumAmount)
select quarter, "Other" as category, "#773344" as color,
  'debit' as type, 'spending' as category_type, Amount as sumAmount
from mint_other;

drop table cat_all;
drop table cat_used;
drop table mint_quarter;
drop table mint_top;

select 'aggregate transaction table' as `table description`, ma.*
from mint_aggregate as ma
limit 1 \G