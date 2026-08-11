import pandas as pd
import numpy as np

# 1. Carregamento dos dados
orders = pd.read_csv('data/orders.csv')
order_items = pd.read_csv('data/order_items.csv')
product_variants = pd.read_csv('data/product_variants.csv')
products = pd.read_csv('data/products.csv')

# Conversão de datas
orders['created_at'] = pd.to_datetime(orders['created_at'])

# 2. Identificar o produto "Bússola de Bordo 702"
target_product = products[products['name'] == 'Bússola de Bordo 702']
if target_product.empty:
    target_product = products[products['name'].str.contains('Bússola de Bordo 702', case=False, na=False)]

product_id = target_product.iloc[0]['id']

# Mapear as variantes associadas a este produto
variant_ids = product_variants[product_variants['product_id'] == product_id]['id'].tolist()

# 3. Unificar dados de vendas do produto
df_items = order_items[order_items['product_variant_id'].isin(variant_ids)].copy()
df_merged = df_items.merge(orders, left_on='order_id', right_on='id')

# Extrair Ano-Mês para agregação
df_merged['ano_mes'] = df_merged['created_at'].dt.to_period('M')

# Agrupar total de itens vendidos por mês
vendas_mensais = df_merged.groupby('ano_mes')['quantity'].sum().reset_index()
vendas_mensais['data'] = vendas_mensais['ano_mes'].dt.to_timestamp()
vendas_mensais = vendas_mensais.sort_values('data').reset_index(drop=True)

# Garantir grid temporal completo (sem falha de meses zerados)
min_date = vendas_mensais['data'].min()
max_date = pd.to_datetime('2026-03-31')
full_range = pd.date_range(start=min_date, end=max_date, freq='MS')

df_completo = pd.DataFrame({'data': full_range})
df_completo = df_completo.merge(vendas_mensais[['data', 'quantity']], on='data', how='left')
df_completo['quantity'] = df_completo['quantity'].fillna(0)

# 4. Construção do Baseline: Média Móvel de 3 Meses (evitando Data Leakage)
df_completo['previsao_movel'] = df_completo['quantity'].shift(1).rolling(window=3).mean()

# 5. Separação de Treino e Teste (Primeiro Trimestre de 2026)
df_teste = df_completo[(df_completo['data'] >= '2026-01-01') & (df_completo['data'] <= '2026-03-31')].copy()

# Cálculo da previsão total e do MAE com numpy
soma_previsao_q1 = int(round(df_teste['previsao_movel'].sum()))
mae_q1 = np.mean(np.abs(df_teste['quantity'] - df_teste['previsao_movel']))

print("--- RESULTADOS DA QUESTÃO 6 ---")
print(f"Previsões mensais Q1 2026:\n{df_teste[['data', 'quantity', 'previsao_movel']]}")
print(f"\nSoma total prevista (Q1 2026) arredondada: {soma_previsao_q1}")
print(f"MAE do modelo Baseline (Q1 2026): {mae_q1:.2f}")