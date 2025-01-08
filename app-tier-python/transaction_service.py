import mysql.connector
from db_config import DB_HOST, DB_USER, DB_PWD, DB_DATABASE


# Database Connection
def get_db_connection():
    return mysql.connector.connect(
        host=DB_HOST, user=DB_USER, password=DB_PWD, database=DB_DATABASE
    )


def add_transaction(amount, desc):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO transactions (amount, description) VALUES (%s, %s)",
            (amount, desc),
        )
        conn.commit()
        cursor.close()
        conn.close()
        return 200
    except Exception as e:
        print(f"Error adding transaction: {str(e)}")
        return 500


def get_all_transactions():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM transactions")
        transactions = cursor.fetchall()
        cursor.close()
        conn.close()
        return transactions
    except Exception as e:
        print(f"Error fetching all transactions: {str(e)}")
        return []


def find_transaction_by_id(transaction_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM transactions WHERE id = %s", (transaction_id,))
        transaction = cursor.fetchone()
        cursor.close()
        conn.close()
        return transaction
    except Exception as e:
        print(f"Error finding transaction by ID: {str(e)}")
        return None


def delete_all_transactions():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM transactions")
        conn.commit()
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Error deleting all transactions: {str(e)}")


def delete_transaction_by_id(transaction_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM transactions WHERE id = %s", (transaction_id,))
        conn.commit()
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Error deleting transaction by ID: {str(e)}")
