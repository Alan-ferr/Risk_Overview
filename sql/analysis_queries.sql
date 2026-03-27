--Total emprestado por cliente

SELECT
c.client_id,
c.name,
SUM(l.loan_amount) AS total_loans
FROM clients c
JOIN loans l ON c.client_id = l.client_id
GROUP BY c.client_id, c.name
ORDER BY total_loans DESC;

--Clientes com maior número de empréstimos

SELECT  
c.client_id,
c.name,
COUNT(*) AS total_loans
FROM loans l
JOIN clients c 
ON l.client_id = c.client_id
GROUP BY c.client_id, c.name
ORDER BY total_loans DESC;

--Atraso de pagamentos

SELECT
loan_id,
COUNT(*) AS total_payments
FROM payments
GROUP BY loan_id;

--Valor do empréstimo vs valor pago

SELECT
l.loan_id,
c.client_id,
c.name,
l.loan_amount,
COALESCE(SUM(p.amount_paid),0) AS total_paid,
l.loan_amount - COALESCE(SUM(p.amount_paid),0) AS remaining_balance
FROM loans l
LEFT JOIN payments p
ON l.loan_id = p.loan_id
JOIN clients c
ON l.client_id = c.client_id
GROUP BY
l.loan_id,
c.client_id,
c.name,
l.loan_amount
ORDER BY remaining_balance DESC;

--Relação divida/renda

SELECT
c.client_id,
c.income,
SUM(l.loan_amount) AS debt,
SUM(l.loan_amount)/c.income AS debt_ratio
FROM clients c
JOIN loans l ON c.client_id = l.client_id
GROUP BY c.client_id, c.income;