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
