import random
from faker import Faker
from datetime import  timedelta

import psycopg2

fake = Faker('pt_BR')

conn = psycopg2.connect(
    host="localhost",
    database="risk_data_mart",
    user="postgres",
    password="admin",
    port=5432
)

cursor = conn.cursor()

# Criar tabelas
with open("schema.sql", "r") as f:
    cursor.execute(f.read())

# -------- CLIENTS --------
for i in range(1000):
    cursor.execute("""
        INSERT INTO clients (name, birth_date, income, city, credit_score, created_at)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (
        fake.name(),
        fake.date_of_birth(minimum_age=18, maximum_age=70),
        round(random.uniform(1500, 20000), 2),
        fake.city(),
        random.randint(300, 850),
        fake.date_between(start_date="-5y", end_date="today")
    ))

# -------- ACCOUNTS --------
for client_id in range(1, 1001):
    cursor.execute("""
        INSERT INTO accounts (client_id, account_type, status, created_at)
        VALUES (%s, %s, %s, %s)
    """, (
        client_id,
        random.choice(["checking", "savings"]),
        "active",
        fake.date_between(start_date="-5y", end_date="today")
    ))

# -------- TRANSACTIONS --------
for account_id in range(1, 1001):
    for _ in range(random.randint(10, 50)):
        cursor.execute("""
            INSERT INTO transactions (account_id, transaction_date, amount, transaction_type, category)
            VALUES (%s, %s, %s, %s, %s)
        """, (
            account_id,
            fake.date_between(start_date="-1y", end_date="today"),
            round(random.uniform(10, 5000), 2),
            random.choice(["credit", "debit"]),
            random.choice(["food", "rent", "shopping", "transport", "salary"])
        ))

# -------- LOANS --------
for client_id in random.sample(range(1, 1001), 300):
    loan_amount = round(random.uniform(1000, 50000), 2)
    loan_date = fake.date_between(start_date="-2y", end_date="-30d")
    due_date = loan_date + timedelta(days=365)
    status = random.choice(["active", "paid", "default"])

    cursor.execute("""
        INSERT INTO loans (client_id, loan_amount, interest_rate, loan_date, due_date, status)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (
        client_id,
        loan_amount,
        round(random.uniform(0.02, 0.15), 3),
        loan_date,
        due_date,
        status
    ))

    # -------- PAYMENTS --------
for loan_id in range(1, 301):
    for _ in range(random.randint(1, 12)):
        cursor.execute("""
        INSERT INTO payments (loan_id, payment_date, amount_paid)
        VALUES (%s, %s, %s)
        """,
        (
            loan_id,
            fake.date_between(start_date="-2y", end_date="today"),
            round(random.uniform(100, 2000), 2)
        ))

conn.commit()
conn.close()