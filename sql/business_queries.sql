-- SQL Queries for Risk Management Analytics
-- Targeted at Credit Risk Analysts (Nubank, Itaú, PicPay)

-- 1. Vintage Analysis (Taxa de Default por Safra de Concessão)
-- Essencial para entender se as concessões de um mês específico estão performando mal
CREATE OR REPLACE VIEW v_vintage_analysis AS
WITH loan_summary AS (
    SELECT 
        TO_CHAR(loan_date, 'YYYY-MM') AS vintage,
        COUNT(loan_id) AS total_loans,
        SUM(loan_amount) AS total_amount,
        SUM(CASE WHEN status = 'default' THEN 1 ELSE 0 END) AS count_default,
        SUM(CASE WHEN status = 'default' THEN loan_amount ELSE 0 END) AS amount_default
    FROM loans
    GROUP BY 1
)
SELECT 
    vintage,
    total_loans,
    total_amount,
    count_default,
    amount_default,
    ROUND((count_default::FLOAT / total_loans::FLOAT) * 100, 2) AS default_rate_qty,
    ROUND((amount_default::FLOAT / total_amount::FLOAT) * 100, 2) AS default_rate_amount
FROM loan_summary
ORDER BY vintage DESC;

-- 2. NPL (Non-Performing Loans) Ratio - Indicador Chave de Bancos
-- NPL 15, 30, 60, 90 (Dias em atraso)
CREATE OR REPLACE VIEW v_npl_metrics AS
WITH overdue_calc AS (
    SELECT 
        l.loan_id,
        l.loan_amount,
        l.status,
        (CURRENT_DATE - l.due_date) AS days_overdue,
        l.loan_amount - COALESCE(SUM(p.amount_paid), 0) AS remaining_balance
    FROM loans l
    LEFT JOIN payments p ON l.loan_id = p.loan_id
    WHERE l.status != 'paid'
    GROUP BY 1, 2, 3, 4
)
SELECT
    SUM(remaining_balance) AS total_portfolio,
    SUM(CASE WHEN days_overdue > 15 THEN remaining_balance ELSE 0 END) AS npl_15_amount,
    SUM(CASE WHEN days_overdue > 30 THEN remaining_balance ELSE 0 END) AS npl_30_amount,
    SUM(CASE WHEN days_overdue > 90 THEN remaining_balance ELSE 0 END) AS npl_90_amount,
    ROUND((SUM(CASE WHEN days_overdue > 90 THEN remaining_balance ELSE 0 END) / SUM(remaining_balance)) * 100, 2) AS npl_90_ratio
FROM overdue_calc;

-- 3. Roll Rates (Fluxo de Inadimplência)
-- Analisa quantos clientes pulam de uma faixa de atraso para outra
CREATE OR REPLACE VIEW v_roll_rates_summary AS
SELECT 
    CASE 
        WHEN (CURRENT_DATE - due_date) <= 30 THEN '0-30 days'
        WHEN (CURRENT_DATE - due_date) <= 60 THEN '31-60 days'
        WHEN (CURRENT_DATE - due_date) <= 90 THEN '61-90 days'
        ELSE '90+ days'
    END AS delinquency_bucket,
    COUNT(*) AS customer_count,
    SUM(loan_amount) AS total_exposure
FROM loans
WHERE status != 'paid'
GROUP BY 1
ORDER BY 1;

-- 4. Profitability by Risk Category (RAROC - Risk-Adjusted Return on Capital)
-- Simula o retorno ajustado pelo risco
CREATE OR REPLACE VIEW v_risk_profitability AS
SELECT 
    f.risk_category,
    COUNT(f.loan_id) AS total_loans,
    SUM(f.loan_amount) AS total_disbursed,
    AVG(f.interest_rate) * 100 AS avg_interest_rate,
    SUM(f.total_paid) AS total_recovered,
    SUM(f.remaining_balance) AS exposure_at_default,
    ROUND((SUM(f.total_paid) / SUM(f.loan_amount)) * 100, 2) AS recovery_rate
FROM loan_risk_features_v2 f
GROUP BY 1;
