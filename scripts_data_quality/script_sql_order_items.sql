-- Reconhecimento da tabela
SELECT *
FROM order_items oi 
LIMIT 100;
-- coluna quantity_receibed registrada como texto
-- coluna unit_price registrada como texto
-- coluna icms rate registrada como texto
-- coluna ipi rate registrada como texto
-- coluna line_total registrada como texto
-- difícil visualização sem o nome do produto

SELECT *
FROM orders o  
LIMIT 100;
--- preparando para lembrar o nome das colunas, para fazer a JOIN

SELECT *
FROM customers c 
LIMIT 5
--- preparando para lembrar o nome das colunas, para fazer a JOIN

--Levantamento nominal dos clientes que mais compraram
SELECT 
  c.legal_name  AS cliente,
    SUM(oi.quantity::numeric) AS total_itens_comprados,
    ROUND(SUM(oi.quantity::numeric * oi.unit_price::numeric), 2) AS valor_total_gasto
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.id
INNER JOIN customers c ON o.customer_id = c.id
GROUP BY c.legal_name 
ORDER BY valor_total_gasto DESC
LIMIT 10;


--levantamento de cliente x produto x vendedor
SELECT 
    p.name AS produto,
    c.legal_name AS cliente_empresa,
    COALESCE(e.full_name, 'Venda Online / Ecommerce') AS vendedor,
    o.channel AS canal_venda,
    oi.quantity::numeric AS qtd_itens,
    oi.unit_price::numeric AS preco_unitario,
    ROUND(oi.quantity::numeric * oi.unit_price::numeric, 2) AS valor_total_item
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.id
INNER JOIN customers c ON o.customer_id = c.id
LEFT JOIN employees e ON o.salesperson_id = e.id
LEFT JOIN product_variants pv ON oi.product_variant_id = pv.id
LEFT JOIN products p ON pv.product_id = p.id
ORDER BY valor_total_item DESC;

-- vendedores campeões
SELECT 
    COALESCE(e.full_name, 'Venda Online / Ecommerce') AS vendedor,
    COUNT(DISTINCT o.id) AS total_pedidos,
    SUM(oi.quantity::numeric) AS volume_itens_vendidos,
    ROUND(SUM(oi.quantity::numeric * oi.unit_price::numeric), 2) AS faturamento_total_rs
FROM orders o
INNER JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN employees e ON o.salesperson_id = e.id
GROUP BY e.full_name
ORDER BY faturamento_total_rs DESC;
-- observe que 3 vendedores detém um quantitativo de vendas maior que o valor das vendas vendas online, no que tange o faturamento

-- produtos campeões
SELECT 
    p.id AS product_id,
    p.name AS produto,
    SUM(oi.quantity::numeric) AS total_unidades_vendidas,
    COUNT(DISTINCT oi.order_id) AS total_pedidos
FROM order_items oi
INNER JOIN product_variants pv ON oi.product_variant_id = pv.id
INNER JOIN products p ON pv.product_id = p.id
GROUP BY p.id, p.name
ORDER BY total_unidades_vendidas DESC
LIMIT 10;
--- demonstração dos produtos vendidos por quantidade

--produtos campeoes
SELECT 
    p.id AS product_id,
    p.name AS produto,
    ROUND(SUM(oi.quantity::numeric * oi.unit_price::numeric), 2) AS faturamento_total_rs,
    SUM(oi.quantity::numeric) AS total_unidades_vendidas
FROM order_items oi
INNER JOIN product_variants pv ON oi.product_variant_id = pv.id
INNER JOIN products p ON pv.product_id = p.id
GROUP BY p.id, p.name
ORDER BY faturamento_total_rs DESC
LIMIT 10;

/*
==============================================================================
RESUMO EXECUTIVO & RECOMENDAÇÕES DE NEGÓCIO (BUSINESS INSIGHTS)
==============================================================================
1. COMPORTAMENTO DE PORTFÓLIO (TICKET MÉDIO vs. VOLUME):
   - Ticket Alto (Curva A Financeira): 'Bateria Náutica 5523' lidera receita 
     (R$ 8,37M), mas não entra no Top 10 de volume (item de alto valor agregado).
   - Volume/Giro (Chafariz): 'Âncora Bruce 831' lidera em unidades (2.745 un.), 
     porém não entra no Top 10 de faturamento.
   - Produto Estrela (Core): 'Colete Salva-Vidas 2374' é o mais equilibrado 
     (2º em receita com R$ 7,82M e 6º em volume com 2.668 un.).

2. OPORTUNIDADES & PRÓXIMOS PASSOS:
   - Bundling / Cross-Selling: Potencial para montar kits combinando 
     eletrônicos/manutenção (GPS, Baterias) + segurança (Coletes).
   - Modelagem Gold / dbt: Incorporar cálculo de Curva ABC (flags A, B, C) 
     diretamente no Data Mart comercial para alimentar os dashboards de estoque.
==============================================================================
*/
