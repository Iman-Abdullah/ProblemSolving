from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.mysql.hooks.mysql import MySqlHook
from datetime import datetime
import csv
import os

def export_table_to_csv(table_name):
    def _export():
        mysql_hook = MySqlHook(mysql_conn_id='mysql_bookstore')
        conn = mysql_hook.get_conn()
        cursor = conn.cursor()
        cursor.execute(f"SELECT * FROM {table_name}")
        rows = cursor.fetchall()
        columns = [col[0] for col in cursor.description]

        output_dir = "/opt/airflow/output"
        os.makedirs(output_dir, exist_ok=True)
        file_path = os.path.join(output_dir, f"{table_name}.csv")

        with open(file_path, "w", newline="") as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(columns)
            writer.writerows(rows)

        print(f"✅ Exported {table_name} to {file_path}")
    return _export

default_args = {
    'start_date': datetime(2025, 1, 1),
    'retries': 1
}

with DAG(
    dag_id='mysql_bookstore_full_export',
    default_args=default_args,
    schedule_interval='@daily',
    catchup=False,
    tags=["mysql", "etl", "bookstore"]
) as dag:

    export_user = PythonOperator(
        task_id='export_user',
        python_callable=export_table_to_csv('User')
    )

    export_author = PythonOperator(
        task_id='export_author',
        python_callable=export_table_to_csv('Author')
    )

    export_genre = PythonOperator(
        task_id='export_genre',
        python_callable=export_table_to_csv('Genre')
    )

    export_book = PythonOperator(
        task_id='export_book',
        python_callable=export_table_to_csv('Book')
    )

    export_review = PythonOperator(
        task_id='export_review',
        python_callable=export_table_to_csv('Review')
    )

    export_cart = PythonOperator(
        task_id='export_cart',
        python_callable=export_table_to_csv('Cart')
    )

    export_order = PythonOperator(
        task_id='export_order',
        python_callable=export_table_to_csv('Order')
    )

    # Run tasks in parallel
    [export_user, export_author, export_genre, export_book, export_review, export_cart, export_order]
