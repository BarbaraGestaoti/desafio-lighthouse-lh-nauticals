SELECT *
FROM purchase_orders po 
LIMIT 100;
-- nesta tabela consta um maior detalhamento de quem foi o funcionário responsável pela compra
-- fornecedor do item
-- status da compra
-- moeda em que foi adquirido o produto ** veja, nas demais tabelas não está identificado o tipo de moeda, a premissa que trabalhei até então era em R$

SELECT 
    -- 1. Total de Pedidos de Compra
    COUNT(*) AS total_pedidos,
    
    -- 2. Distribuição por Moeda (Quantidade e Subtotal)
    COUNT(*) FILTER (WHERE currency = 'BRL') AS pedidos_brl,
    COUNT(*) FILTER (WHERE currency = 'USD') AS pedidos_usd,
    COUNT(*) FILTER (WHERE currency IS NULL OR currency NOT IN ('BRL', 'USD')) AS moedas_invalidas_ou_nulas,
    
    -- 3. Pedidos sem comprador (buyer_id) ou sem fornecedor (supplier_id)
    COUNT(*) FILTER (WHERE buyer_id IS NULL) AS sem_comprador,
    COUNT(*) FILTER (WHERE supplier_id IS NULL) AS sem_fornecedor,
    
    -- 4. Status Rascunho/Não Finalizado (Draft)
    COUNT(*) FILTER (WHERE status = 'draft') AS pedidos_em_rascunho

FROM purchase_orders;
-- houve 2000 pedidos, sendo 1882 em reais, 71 em dólar, 47 em moedas inválidas/nulas e 99 pedidos em rascunho