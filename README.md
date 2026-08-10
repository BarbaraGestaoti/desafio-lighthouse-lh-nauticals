# Desafio Técnico — LH Nauticals (Programa Lighthouse)

Projeto desenvolvido como parte do processo seletivo do Programa Lighthouse (Indicium). O objetivo principal é realizar análises exploratórias em SQL, automação de schemas DDL e cargas de dados (ETL) em Python, modelagem de previsão de demanda e desenvolvimento de um sistema de recomendação de produtos.

---

# Desafio Técnico - LH Nauticals
> **Programa Lighthouse - Dados & AI**

---

## 📌 Sumário
- [Visão Geral & Tecnologias](#visão-geral--tecnologias)
- [Estrutura do Repositório](#estrutura-do-repositório)
- [Questão 1 - Análise Exploratória](#questão-1---análise-exploratória-e-diagnóstico-de-dados)
- [Questão 2 - Schema e Estrutura do Banco](#questão-2---schema-e-definição-de-estrutura-de-banco-de-dados)
- [Questão 3 - Carregamento de Dados (ETL)](#questão-3---carregamento-de-dados-etlelt)
- [Questão 4 - Análise de Clientes](#questão-4---análise-de-clientes)
- [Questão 5 - Dimensão Calendário](#questão-5---dimensão-de-calendário)
- [Questão 6 - Previsão de Demanda](#questão-6---previsão-de-demanda)
- [Questão 7 - Sistema de Recomendação](#questão-7---sistema-de-recomendação)

---

## 🛠️ Visão Geral & Tecnologias

- **Linguagem Principal:** Python 3 (puro para ETL/Schema; Pandas/Numpy/Scikit-Learn para ML/Analytics)
- **Banco de Dados:** PostgreSQL / SQL ANSI
- **Objetivo:** Resolver os 7 desafios de negócio da LH Nauticals integrando Engenharia de Dados, Analytics e Data Science.

---

## 📁 Estrutura do Repositório

```text
.
├── data/                   # Arquivos CSV originais do desafio
├── src/                    # Scripts Python e queries SQL
│   ├── 01_eda_orders.sql
│   ├── 02_generate_schema.py
│   ├── 03_load_data.py
│   ├── 04_client_analysis.sql
│   ├── 05_dim_calendar.sql
│   ├── 06_demand_forecast.py
│   └── 07_recommender.py
├── output/                 # Arquivos gerados (ex: schema.sql)
├── dashboard/              # Painéis e relatórios de BI
├── README.md               # Documentação executiva do projeto
└── requirements.txt        # Dependências do projeto Python
