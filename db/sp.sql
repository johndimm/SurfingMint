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
# Used by React at runtime to get data.
#
drop procedure if exists get_detail;
delimiter //
create procedure get_detail(_quarter varchar(32), _category varchar(255))
begin
  select *
  from mint
  where quarter = _quarter
  and category = _category
  #  and type = 'debit'
  order by Amount asc
  ;
end //
delimiter ;

#
# Reporting stored procedures
#
# Get mandatory categories for this quarter.
#
drop procedure if exists get_mandatory;
delimiter //
create procedure get_mandatory(_quarter varchar(32))
begin
  drop temporary table if exists agg;
  create temporary table agg as
  select
    quarter,
    ma.category,
    'debit' as type,
    round(-1 * Amount) as Amount,
    color
  from mint_aggregate as ma
  left join skip_cat as sc on sc.category = ma.category
  where quarter = _quarter
  and sc.category is not null
  ;

  call fill_agg(_quarter);
end //
delimiter ;

#
# Get discretionary categories for this quarter.
#
drop procedure if exists get_discretionary;
delimiter //
create procedure get_discretionary(_quarter varchar(32))
begin
  drop temporary table if exists agg;
  create temporary table agg as
  select
    quarter,
    ma.category,
    'debit' as type,
    round(-1 * Amount) as Amount,
    color
  from mint_aggregate as ma
  left join skip_cat as sc on sc.category = ma.category
  where quarter = _quarter
  and sc.category is null
  ;

  call fill_agg(_quarter);
end //
delimiter ;

#
# Get both.
#
drop procedure if exists get_mandatory_discretionary;
delimiter //
create procedure get_mandatory_discretionary(_quarter varchar(32))
begin
  drop temporary table if exists agg;
  create temporary table agg as
  select
    quarter,
    ma.category,
    'debit' as type,
    round(-1 * Amount) as Amount,
    color
  from mint_aggregate as ma
  left join skip_cat as sc on sc.category = ma.category
  where quarter = _quarter
  #and sc.category is not null
  ;

  call fill_agg(_quarter);
end //
delimiter ;


#
#  Step 2 of returning aggregate data:  add the Other category.
#
drop procedure if exists fill_agg;
delimiter //
create procedure fill_agg(_quarter varchar(32))
begin

  #
  # How much is missing if we show only the top 20?
  #
  set @total = (select sum(Amount) from agg);
  set @top20 = (select sum(Amount) from (select * from agg limit 20) as t);
  set @other = round(@total - @top20);

  #
  # Return top 20, plus Other.
  #
  select * from
  (
    select *
    from agg
    limit 20
  ) as t
  union
  select
    _quarter as quarter,
    "Other" as category,
    'debit' as type,
    @other as Amount,
    "#558899" as color
  ;

end //
delimiter ;

#
# Reporting
#
drop procedure if exists get_quarters;
delimiter //
create procedure get_quarters()
begin
  select distinct quarter
  from mint_aggregate
  order by quarter
  ;
end //
delimiter ;