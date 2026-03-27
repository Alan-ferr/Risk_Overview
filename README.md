# 🏦 Credit Risk Analytics & Data Mart

[![Python](https://img.shields.io/badge/Python-3.11+-blue.svg)](https://www.python.org/)
[![SQL](https://img.shields.io/badge/SQL-Advanced-blue.svg)](https://www.postgresql.org/)
[![Analytics](https://img.shields.io/badge/Business-Intelligence-green.svg)](https://pandas.pydata.org/)

Este projeto simula um ecossistema de dados de **Risco de Crédito**, projetado para atender aos requisitos técnicos de grandes instituições financeiras. Ele demonstra competência em **Engenharia de Dados (SQL/ETL)**, **Análise Quantitativa (KPIs de Risco)** e **Machine Learning (Predictive Default)**.

---

## 🎯 Objetivo de Negócio
O foco é o monitoramento e previsão de **Inadimplência (Default)**. Através da modelagem de um Data Mart, calculamos métricas críticas que determinam a saúde financeira de um banco:
- **PD (Probability of Default):** Probabilidade de um cliente não pagar a dívida.
- **EAD (Exposure at Default):** Valor total exposto ao risco no momento da falha.
- **LGD (Loss Given Default):** Percentual da exposição que não será recuperado.
- **Vintage Analysis:** Performance de safras de crédito ao longo do tempo.
- **NPL Ratio (Non-Performing Loans):** Percentual da carteira em atraso (NPL 15, 30, 90).

---

## 📂 Estrutura do Projeto (Padrão de Mercado)

```text
├── 🛠️ src/
│   ├── data/            # Geração de dados sintéticos (Simulação Bancária)
│   └── analysis/     # Scripts de análise quantitativa e modelagem preditiva
├── 📈 notebooks/        # EDA (Análise Exploratória de Dados)
├── 🗄️ sql/              # Modelagem de Dados, Views e Queries Avançadas
│   ├── schema.sql       # DDL com Constraints e Índices (Performance)
│   ├── business_queries.sql # Vintage, NPL e Roll Rates
│   └── feature_table_v2.sql # Feature Engineering para Modelagem
├── 🖼️ assets/           # Visualizações e Dashboards
└── 📄 README.md         # Documentação Técnica e de Negócio
```

---

## 🚀 Destaques Técnicos

### 1. Modelagem de Dados & SQL
- **Performance:** Schema otimizado com índices em campos de busca (credit_score, status) e constraints (CHECK, FOREIGN KEYS).
- **Queries Avançadas:** Implementação de **Vintage Analysis** e **Roll Rates** via SQL puro, demonstrando conhecimento em lógica de negócios bancários.

### 2. Análise de Risco (Python)
- Extração de dados via SQLAlchemy/Pandas.
- Cálculo de **PD por bucket de score**, permitindo segmentação estratégica de clientes.
- Visualização de **Concentração de Exposição** vs Score de Crédito.

---

## 📈 Resultados e KPIs
Os scripts geram relatórios executivos com:
- Exposição total do portfólio (EAD).
- Taxa de Recuperação (Recovery Rate).
- Distribuição de risco segmentada.

---

## 🛠️ Como Executar
1. Instale as dependências: `pip install pandas scikit-learn matplotlib seaborn faker sqlalchemy`
2. Gere os dados: `python src/data/generate_data.py`
3. Execute a análise de risco: `python src/analysis/risk_analysis.py`

---
**Foco:** Análise de Dados | Ciência de Dados | Risco de Crédito
