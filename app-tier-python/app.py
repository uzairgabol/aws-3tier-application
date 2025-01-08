from flask import Flask, request, jsonify
from flask_cors import CORS
from transaction_service import (
    add_transaction,
    get_all_transactions,
    delete_all_transactions,
    find_transaction_by_id,
    delete_transaction_by_id,
)

app = Flask(__name__)
CORS(app)


# Health Check
@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({"message": "This is the health check"}), 200


# Add Transaction
@app.route("/transaction", methods=["POST"])
def add_transaction_route():
    try:
        data = request.get_json()
        amount = data.get("amount")
        desc = data.get("desc")
        if not amount or not desc:
            return jsonify({"message": "Amount and description are required"}), 400

        success = add_transaction(amount, desc)
        if success == 200:
            return jsonify({"message": "Added transaction successfully"}), 200
        else:
            return jsonify({"message": "Failed to add transaction"}), 500
    except Exception as e:
        return jsonify({"message": "Something went wrong", "error": str(e)}), 500


# Get All Transactions
@app.route("/transaction", methods=["GET"])
def get_transactions():
    try:
        transactions = get_all_transactions()
        return jsonify({"result": transactions}), 200
    except Exception as e:
        return jsonify(
            {"message": "Could not get all transactions", "error": str(e)}
        ), 500


# Delete All Transactions
@app.route("/transaction", methods=["DELETE"])
def delete_all_transactions_route():
    try:
        delete_all_transactions()
        return jsonify({"message": "All transactions deleted successfully"}), 200
    except Exception as e:
        return jsonify({"message": "Error deleting transactions", "error": str(e)}), 500


# Delete Transaction by ID
@app.route("/transaction/id", methods=["DELETE"])
def delete_transaction_by_id_route():
    try:
        data = request.get_json()
        transaction_id = data.get("id")
        if not transaction_id:
            return jsonify({"message": "Transaction ID is required"}), 400

        delete_transaction_by_id(transaction_id)
        return jsonify(
            {"message": f"Transaction with ID {transaction_id} deleted successfully"}
        ), 200
    except Exception as e:
        return jsonify({"message": "Error deleting transaction", "error": str(e)}), 500


# Get Single Transaction by ID
@app.route("/transaction/id", methods=["GET"])
def get_transaction_by_id_route():
    try:
        data = request.args
        transaction_id = data.get("id")
        if not transaction_id:
            return jsonify({"message": "Transaction ID is required"}), 400

        transaction = find_transaction_by_id(transaction_id)
        if transaction:
            return jsonify(transaction), 200
        else:
            return jsonify({"message": "Transaction not found"}), 404
    except Exception as e:
        return jsonify(
            {"message": "Error retrieving transaction", "error": str(e)}
        ), 500


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=4000)


# from flask import Flask, request, jsonify
# from flask_cors import CORS

# app = Flask(__name__)
# CORS(app)


# # Health Check
# @app.route("/health", methods=["GET"])
# def health_check():
#     return jsonify({"message": "This is the health check"}), 200


# # Dummy Transactions
# dummy_transactions = [
#     {"id": 1, "amount": 100, "desc": "Payment for services"},
#     {"id": 2, "amount": 200, "desc": "Payment for goods"},
#     {"id": 3, "amount": 150, "desc": "Refund for returned item"},
# ]


# # Add Transaction (Dummy data, no database interaction)
# @app.route("/transaction", methods=["POST"])
# def add_transaction_route():
#     try:
#         data = request.get_json()
#         amount = data.get("amount")
#         desc = data.get("desc")
#         if not amount or not desc:
#             return jsonify({"message": "Amount and description are required"}), 400

#         # Create a dummy transaction and add it to the list
#         new_transaction = {
#             "id": len(dummy_transactions) + 1,  # Increment the ID
#             "amount": amount,
#             "desc": desc,
#         }
#         dummy_transactions.append(new_transaction)

#         return jsonify(
#             {
#                 "message": "Added transaction successfully",
#                 "transaction": new_transaction,
#             }
#         ), 200
#     except Exception as e:
#         return jsonify({"message": "Something went wrong", "error": str(e)}), 500


# # Get All Transactions (Returns the dummy transactions)
# @app.route("/transaction", methods=["GET"])
# def get_transactions():
#     try:
#         return jsonify({"result": dummy_transactions}), 200
#     except Exception as e:
#         return jsonify(
#             {"message": "Could not get all transactions", "error": str(e)}
#         ), 500


# # Delete All Transactions (Clears the dummy transactions list)
# @app.route("/transaction", methods=["DELETE"])
# def delete_all_transactions_route():
#     try:
#         dummy_transactions.clear()  # Clear the list of dummy transactions
#         return jsonify({"message": "All transactions deleted successfully"}), 200
#     except Exception as e:
#         return jsonify({"message": "Error deleting transactions", "error": str(e)}), 500


# # Delete Transaction by ID (Removes transaction by ID)
# @app.route("/transaction/id", methods=["DELETE"])
# def delete_transaction_by_id_route():
#     try:
#         data = request.get_json()
#         transaction_id = data.get("id")
#         if not transaction_id:
#             return jsonify({"message": "Transaction ID is required"}), 400

#         # Remove the transaction from the dummy transactions list
#         global dummy_transactions
#         dummy_transactions = [
#             txn for txn in dummy_transactions if txn["id"] != transaction_id
#         ]

#         return jsonify(
#             {"message": f"Transaction with ID {transaction_id} deleted successfully"}
#         ), 200
#     except Exception as e:
#         return jsonify({"message": "Error deleting transaction", "error": str(e)}), 500


# # Get Single Transaction by ID (Returns the dummy transaction by ID)
# @app.route("/transaction/id", methods=["GET"])
# def get_transaction_by_id_route():
#     try:
#         data = request.args
#         transaction_id = data.get("id")
#         if not transaction_id:
#             return jsonify({"message": "Transaction ID is required"}), 400

#         # Find the transaction in the dummy transactions list
#         transaction = next(
#             (txn for txn in dummy_transactions if txn["id"] == int(transaction_id)),
#             None,
#         )

#         if transaction:
#             return jsonify(transaction), 200
#         else:
#             return jsonify({"message": "Transaction not found"}), 404
#     except Exception as e:
#         return jsonify(
#             {"message": "Error retrieving transaction", "error": str(e)}
#         ), 500


# if __name__ == "__main__":
#     app.run(debug=True, host="0.0.0.0", port=4000)
