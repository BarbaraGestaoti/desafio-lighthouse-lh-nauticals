-- Reconhecimento da tabela
SELECT *
FROM goods_receipt_items gri 
LIMIT 100;
-- coluna quantity_receibed registrada como texto

--
-- Reconhecimento inicial de quantidade e totais recebidos
-- Conversão para numeric/integer para permitir agregações matemáticas
SELECT 
    COUNT(*) AS total_registros,
    SUM(quantity_received::numeric) AS total_pecas_recebidas,
    ROUND(AVG(quantity_received::numeric), 2) AS media_por_item,
    MIN(quantity_received::numeric) AS menor_quantidade,
    MAX(quantity_received::numeric) AS maior_quantidade
FROM goods_receipt_items;
-- A tabela assim fica difícil identificar o item, o tamanho, o valor, realizo join (a seguir) para ter uma visão melhor dos dados

-- Com o LEFT JOIN a seguir consigo nomear os produtos que foram recebidos
SELECT 
    gri.id AS item_recebido_id,
    p.name AS produto_nome,
    gri.quantity_received::numeric AS quantidade_recebida
FROM goods_receipt_items gri
LEFT JOIN purchase_order_items poi ON gri.purchase_order_item_id = poi.id
LEFT JOIN product_variants pv ON poi.product_variant_id = pv.id  -- ou liga direto em products dependendo da FK
LEFT JOIN products p ON pv.product_id = p.id;
-- me chamou a atenção ao percorrer a tabela (curiosidade) o registro asdf na linha 774

-- Investigando produtos com nomes inválidos ou de teste
SELECT id, name, created_at
FROM products
WHERE LOWER(name) LIKE '%asdf%' 
   OR LOWER(name) LIKE '%test%'
   OR LENGTH(name) < 3;
-- há dois registros desta forma

-- Identificando data de chegada e valor dos produtos
-- Identificando data de chegada e valor dos produtos
SELECT 
    p.name AS produto_nome,
    gr.received_at::timestamp AS data_recebimento,
    gri.quantity_received::numeric AS quantidade_recebida,
    poi.unit_cost::numeric AS custo_unitario,
    ROUND(gri.quantity_received::numeric * poi.unit_cost::numeric, 2) AS custo_total_lote
FROM goods_receipt_items gri
LEFT JOIN goods_receipts gr ON gri.goods_receipt_id = gr.id
LEFT JOIN purchase_order_items poi ON gri.purchase_order_item_id = poi.id
LEFT JOIN product_variants pv ON poi.product_variant_id = pv.id
LEFT JOIN products p ON pv.product_id = p.id
ORDER BY data_recebimento DESC;


/* 
==============================================================================
OBSERVAÇÕES DE DATA QUALITY (DQ) - TABELA: goods_receipts / goods_receipt_items
==============================================================================
1. ANOMALIA TEMPORAL (ENTRADAS FUTURAS):
   - Identificados recebimentos físicos (`received_at`) com datas em 2027 
     (ex: Motor de Popa recebido em 22/01/2027).
   - Inconsistência de processo: a tabela representa recebimento REAL/EFETIVADO 
     e não previsão de entrega (`expected_delivery_date`).
   - Reforça a necessidade de aplicar trava temporal nas camadas de transformação 
     (`WHERE gr.received_at::timestamp <= CURRENT_TIMESTAMP`).
==============================================================================
*/
