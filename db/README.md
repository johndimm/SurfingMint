To prepare the mint database:

 * Download your personal Mint data using the link at the bottom of the Transactions tab.
     * The downloaded file is transactions.csv.
 * Run the import script run.sh

That creates the mint database used by the React code.

To run the React app, edit my.cnf to point to your database server.

    [client]
    host=localhost
    user=mint
    password=<pw>

    [mysql]
    database=mint

