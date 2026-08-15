-- Reconhecimento da tabela
SELECT *
FROM orders o  
LIMIT 100;
-- valores numericos registrados como texto

-- Reconhecimento detalhado: obter insight
SELECT 
    id AS order_id,
    customer_id,
    salesperson_id,
    status,
    discount_amount::numeric AS valor_desconto,
    subtotal::numeric AS subtotal_pedido,
    total::numeric AS total_liquido_pedido,
    placed_at::timestamp AS data_pedido
FROM orders
LIMIT 100;

SELECT 
    status,
    COUNT(id) AS total_pedidos,
    ROUND(SUM(discount_amount::numeric), 2) AS total_descontos_concedidos_rs,
    ROUND(SUM(total::numeric), 2) AS receita_total_rs
FROM orders
GROUP BY status
ORDER BY receita_total_rs DESC;

-- DISTRIBUIÇÃO E PESO DE CADA STATUS NO TOTAL
WITH total_geral AS (
    SELECT SUM(total::numeric) AS faturamento_global
    FROM orders
)
SELECT 
    o.status,
    COUNT(o.id) AS total_pedidos,
    ROUND(SUM(o.discount_amount::numeric), 2) AS total_descontos_rs,
    ROUND(SUM(o.total::numeric), 2) AS receita_total_rs,
    ROUND((SUM(o.total::numeric) / tg.faturamento_global) * 100, 2) AS peso_percentual_receita
FROM orders o, total_geral tg
GROUP BY o.status, tg.faturamento_global
ORDER BY receita_total_rs DESC;
-- somados os valores pagos e as compras confirmadas temos cerca de 85%

-- DESEMPENHO REAL ANO A ANO (Apenas vendas efetivadas)
SELECT 
    EXTRACT(YEAR FROM placed_at::timestamp) AS ano_venda,
    COUNT(id) AS qtd_pedidos_faturados,
    ROUND(SUM(discount_amount::numeric), 2) AS total_descontos_concedidos,
    ROUND(SUM(total::numeric), 2) AS receita_liquida_rs
FROM orders
WHERE status IN ('paid', 'confirmed') -- Filtro de Performance Real
  AND placed_at::timestamp <= CURRENT_TIMESTAMP -- Sanitização de datas futuras
GROUP BY EXTRACT(YEAR FROM placed_at::timestamp)
ORDER BY ano_venda ASC;
-- observa-se um crescimento no quantitativo de vendas e na receita líquida ano após ano.
/*
==============================================================================
1. RECONHECIMENTO & DATA QUALITY (ENGINEERING NOTES - orders)
==============================================================================
- TIPAGEM PENDENTE: As colunas de valor (subtotal, discount_amount, total) estão 
  armazenadas como TEXT e exigem conversão explícita (::numeric).
- INTEGRIDADE TEMPORAL: A coluna 'placed_at' exige sanitização com a trava 
  WHERE placed_at::timestamp <= CURRENT_TIMESTAMP para eliminar registros com 
  datas futuras geradas na massa de testes original.
- REGRA DE NEGÓCIO PARA TABELA FATO: Pedidos com status 'draft' ou 'cancelled' 
  devem ser segregados na camada Silver/Gold. Apenas 'paid' e 'confirmed' 
  devem compor o faturamento oficial.

==============================================================================
2. RESUMO EXECUTIVO & INSIGHTS DE NEGÓCIO (ANALYTICS SUMMARY)
==============================================================================
- CONVERSIBILIDADE DA RECEITA: Vendas efetivas ('paid' + 'confirmed') correspondem 
  a ~85% do faturamento global. O volume restante (~15%) refere-se a cancelamentos 
  e rascunhos que não devem inflar a métrica de desempenho real.
- TRAJETÓRIA DE CRESCIMENTO (YoY): A análise temporal ano a ano confirma uma 
  trajetória consistente de expansão, com crescimento sustentado tanto na 
  quantidade de pedidos faturados quanto na receita líquida gerada.
- IMPACTO DE DESCONTOS: Acompanhar o percentual concedido em 'discount_amount' 
  em relação à receita bruta por ano para avaliar o impacto na margem operacional.
==============================================================================
*/
