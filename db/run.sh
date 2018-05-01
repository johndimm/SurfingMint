mysql -e "drop database mint; create database mint"
mysql < load_transactions.sql
mysql < aggregate.sql
mysql < reporting_procs.sql
