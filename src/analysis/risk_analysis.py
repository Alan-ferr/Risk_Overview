import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sqlite3 # Use sqlite3 since we have database.db file
import numpy as np
import os

# Ensure assets directory exists for plot saving
os.makedirs('/mnt/workspace/6BALCRHSGsqGUkKDPdEqTruDtR9Bas2fxdFq6LFG7Yw5YeJL16v3ZmXZCgmZv1Z/assets', exist_ok=True)

# 1. Conexão com o Banco de Dados (Mock de ambiente PostgreSQL/SQLite)
# Em um ambiente real usaríamos psycopg2, mas para o repositório usaremos SQLite para o usuário testar localmente
db_path = '/mnt/workspace/6BALCRHSGsqGUkKDPdEqTruDtR9Bas2fxdFq6LFG7Yw5YeJL16v3ZmXZCgmZv1Z/database.db'
conn = sqlite3.connect(db_path)

# 2. SQL Query para Extração de Dados de Risco
# KPIs de Crédito: PD (Probability of Default), EAD (Exposure at Default), LGD (Loss Given Default)
query = """
WITH loan_data AS (
    SELECT
        l.loan_id,
        c.client_id,
        c.name,
        c.credit_score,
        c.income,
        l.loan_amount,
        l.interest_rate,
        l.status,
        COALESCE(SUM(p.amount_paid), 0) AS total_paid
    FROM loans l
    JOIN clients c ON l.client_id = c.client_id
    LEFT JOIN payments p ON l.loan_id = p.loan_id
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
)
SELECT
    *,
    loan_amount - total_paid AS ead, -- Exposure at Default
    CASE 
        WHEN status = 'default' THEN (loan_amount - total_paid) / loan_amount
        ELSE 0 
    END AS lgd_calc -- Loss Given Default Estimate
FROM loan_data
"""

df = pd.read_sql(query, conn)

# 3. Engenharia de Features de Risco (PD Estimation)
# Criando faixas de risco baseadas no score (Padrão Bancário)
df['risk_bucket'] = pd.cut(df['credit_score'], bins=[300, 500, 650, 750, 1000], 
                           labels=['E (Very High)', 'D (High)', 'C (Medium)', 'B/A (Low)'])

# 4. Cálculo de PD (Probability of Default) por Bucket de Score
pd_by_score = df.groupby('risk_bucket')['status'].apply(lambda x: (x == 'default').mean()).reset_index()
pd_by_score.columns = ['Risk Bucket', 'PD (Probability of Default)']

# 5. Visualização Profissional (Estilo Dashboard Bancário)
plt.style.use('ggplot')
fig, ax = plt.subplots(1, 2, figsize=(16, 6))

# Plot 1: PD por Score
sns.barplot(data=pd_by_score, x='Risk Bucket', y='PD (Probability of Default)', ax=ax[0], palette='Reds_r')
ax[0].set_title('Probability of Default (PD) by Credit Score Bucket', fontsize=14, fontweight='bold')
ax[0].set_ylabel('Probability (%)')

# Plot 2: Exposure vs Score (Concentração de Crédito)
sns.scatterplot(data=df, x='credit_score', y='loan_amount', hue='status', alpha=0.6, ax=ax[1])
ax[1].set_title('Loan Amount vs Credit Score (Portfolio Exposure)', fontsize=14, fontweight='bold')
ax[1].set_xlabel('Credit Score')
ax[1].set_ylabel('Loan Amount ($)')

plt.tight_layout()
plt.savefig('/mnt/workspace/6BALCRHSGsqGUkKDPdEqTruDtR9Bas2fxdFq6LFG7Yw5YeJL16v3ZmXZCgmZv1Z/assets/risk_analysis_plot.png')

# 6. Sumário de Executivo
print("-" * 50)
print("FINANCIAL RISK SUMMARY - EXECUTIVE REPORT")
print("-" * 50)
print(f"Total Portfolio Exposure (EAD): ${df['ead'].sum():,.2f}")
print(f"Overall Default Rate: {(df['status'] == 'default').mean()*100:.2f}%")
print(f"Average Interest Rate: {df['interest_rate'].mean()*100:.2f}%")
print("-" * 50)
print("PD by Risk Bucket:")
print(pd_by_score)
print("-" * 50)

conn.close()
