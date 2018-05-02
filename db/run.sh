mysql -e "drop database mint; create database mint"
mysql < load_transactions.sql
mysql < sp.sql
mysql < aggregate.sql
