SELECT *
FROM purchase_order_items poi
LIMIT 100;
--tabela de items solicitados aos fornecedores

SELECT 
    COUNT(*) AS total_itens_pedido,
    
    -- 1. Quantidades zeradas ou negativas
    COUNT(*) FILTER (
        WHERE NULLIF(quantity_ordered, '')::numeric <= 0
    ) AS qtd_invalida,
    
    -- 2. Custos zerados ou negativos
    COUNT(*) FILTER (
        WHERE NULLIF(unit_cost, '')::numeric <= 0
    ) AS custo_invalido,
    
    -- 3. Inconsistência de cálculo: (Qtd * Custo Unitário) != Total da Linha
    COUNT(*) FILTER (
        WHERE ABS(
            (NULLIF(quantity_ordered, '')::numeric * NULLIF(unit_cost, '')::numeric) - 
            NULLIF(line_total, '')::numeric
        ) > 0.01
    ) AS divergencia_calculo_total

FROM purchase_order_items;
-- Idenficação de items pedidos, não consta inconsistência no banco
