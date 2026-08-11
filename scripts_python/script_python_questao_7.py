# -*- coding: utf-8 -*-
"""
Created on Mon Aug 10 20:51:11 2026

@author: Admin
"""

import pandas as pd
import psycopg2

DB_CONFIG = {
    "dbname": "postgres",
    "user": "postgres",
    "password": "",
    "host": "localhost",
    "port": "5433",
}

conn = psycopg2.connect(**DB_CONFIG)

# 1. Ver todas as tabelas criadas no banco
query_tabelas = """
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';
"""
tabelas = pd.read_sql(query_tabelas, conn)
print("--- TABELAS CRIADAS ---")
print(tabelas)

# 2. Consultar os primeiros registros de uma tabela (ex: orders)
query_dados = "SELECT * FROM orders LIMIT 5;"
df = pd.read_sql(query_dados, conn)
print("\n--- PRIMEIROS REGISTROS DE ORDERS ---")
print(df)

conn.close()