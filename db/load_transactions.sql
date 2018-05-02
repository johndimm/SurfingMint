#
# Load the transactions.csv file downloaded from Mint
# into a table of strings.
#
drop table if exists mint_incoming;
create table mint_incoming
(
  `Date` varchar(255),
  `Description` varchar(255),
  `Original Description` varchar(255),
  `Amount` varchar(255),
  `Transaction Type` varchar(255),
  `Category` varchar(255),
  `Account Name` varchar(255),
  `Labels` varchar(255),
  `Notes` varchar(255)
);

load data local infile 'transactions.csv' into table mint_incoming
FIELDS TERMINATED BY ',' enclosed by '"'
ignore 1 lines;

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
