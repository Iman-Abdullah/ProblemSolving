import csv
import os
from airflow.providers.mysql.hooks.mysql import MySqlHook

def extract_books():
    mysql_hook = MySqlHook(mysql_conn_id='mysql_bookstore')
    connection = mysql_hook.get_conn()
    cursor = connection.cursor()
    cursor.execute("SELECT Title, Price, Stock FROM Book")
    rows = cursor.fetchall()

    # Ensure output directory exists
    os.makedirs("/opt/airflow/output", exist_ok=True)

    # Write results to CSV
    with open("/opt/airflow/output/books.csv", "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["Title", "Price", "Stock"])
        writer.writerows(rows)

    print("✅ Data exported to /opt/airflow/output/books.csv")  # check code


