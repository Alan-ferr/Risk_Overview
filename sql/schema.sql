-- DDL for Risk Data Mart
-- Optimized for Financial Analysis

CREATE TABLE IF NOT EXISTS clients (
    client_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    birth_date DATE NOT NULL,
    income DECIMAL(15, 2) NOT NULL CHECK (income >= 0),
    city VARCHAR(100),
    credit_score INTEGER CHECK (credit_score BETWEEN 300 AND 1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS accounts (
    account_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL,
    account_type VARCHAR(20) CHECK (account_type IN ('checking', 'savings')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'closed', 'frozen')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INTEGER NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(15, 2) NOT NULL,
    transaction_type VARCHAR(10) CHECK (transaction_type IN ('credit', 'debit')),
    category VARCHAR(50),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS loans (
    loan_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL,
    loan_amount DECIMAL(15, 2) NOT NULL CHECK (loan_amount > 0),
    interest_rate DECIMAL(5, 4) NOT NULL CHECK (interest_rate >= 0),
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'paid', 'default', 'written_off')),
    FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    CONSTRAINT chk_dates CHECK (due_date >= loan_date)
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,
    loan_id INTEGER NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount_paid DECIMAL(15, 2) NOT NULL CHECK (amount_paid >= 0),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE CASCADE
);

-- Indices for performance (Critical for banking scale)
CREATE INDEX idx_clients_credit_score ON clients(credit_score);
CREATE INDEX idx_loans_client_id ON loans(client_id);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_payments_loan_id ON payments(loan_id);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
