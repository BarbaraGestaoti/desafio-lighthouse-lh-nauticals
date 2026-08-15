# -*- coding: utf-8 -*-
"""
Created on Sat Aug 15 02:21:16 2026

@author: Admin
"""

import pandas as pd
import numpy as np

# 1. Carregamento dos datasets exigidos pela tarefa
products = pd.read_csv('products.csv')
product_variants = pd.read_csv('product_variants.csv')
orders = pd.read_csv('orders.csv')
order_items = pd.read_csv('order_items.csv')

# 2. Unificação do dataset (Dataset Unificado)
# Relacionando orders -> order_items -> product_variants -> products
df = orders.merge(order_items, left_on='id', right_on='order_id', suffixes=('', '_item')) \
           .merge(product_variants, left_on='product_variant_id', right_on='id', suffixes=('', '_variant')) \
           .merge(products, left_on='product_id', right_on='id', suffixes=('', '_product'))

# 3. Filtrar estritamente o produto solicitado: "Bússola de Bordo 702"
# Verifique se o nome da coluna de descrição/nome no seu CSV é 'name' ou 'title'
bussola_df = df[df['name'] == 'Bussola de Bordo 702'].copy()

# 4. Converter data e agregar as vendas por mês (mensal)
bussola_df['created_at'] = pd.to_datetime(bussola_df['created_at'])
bussola_df['ano_mes'] = bussola_df['created_at'].dt.to_period('M')

# Agrupando a quantidade vendida por mês
vendas_mensais = bussola_df.groupby('ano_mes')['quantity'].sum().reset_index()
vendas_mensais['ano_mes'] = vendas_mensais['ano_mes'].dt.to_timestamp()
vendas_mensais = vendas_mensais.sort_values('ano_mes').set_index('ano_mes')

# 5. Premissa Obrigatória: Período de treino até 31/12/2025
treino = vendas_mensais.loc[:'2025-12-31']

# 6. Construção do Modelo Baseline: Média Móvel dos últimos 3 meses
# shift(1) garante que usamos apenas dados anteriores à data prevista (evita Data Leakage)
vendas_mensais['media_movel_3m'] = vendas_mensais['quantity'].shift(1).rolling(window=3).mean()

# 7. Previsão para o Primeiro Trimestre de 2026 (Jan, Fev, Mar de 2026)
# Gerando a base para o Q1/2026
previsoes_q1_2026 = vendas_mensais.loc['2026-01-01':'2026-03-31', 'media_movel_3m']

print("Previsões mensais para o Q1/2026:")
print(previsoes_q1_2026)

# Soma da previsão para o Q1/2026 (Valor numérico solicitado comumente em validações)
soma_previsao_q1 = previsoes_q1_2026.sum()
print(f"\nSoma da previsão de vendas para o Q1/2026: {soma_previsao_q1:.0f}")