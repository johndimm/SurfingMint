drop procedure if exists get_detail;
delimiter //
create procedure get_detail(_quarter varchar(32), _category varchar(255))
begin
  select *
  from mint
  where quarter = _quarter
  and category = _category
  and type = 'debit'
  ;
end //
delimiter ;

drop procedure if exists get_agg;
delimiter //
create procedure get_agg(_quarter varchar(32))
begin
  select *
  from mint_aggregate
  where quarter = _quarter
  and type = 'debit'
  ;
end //
delimiter ;

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