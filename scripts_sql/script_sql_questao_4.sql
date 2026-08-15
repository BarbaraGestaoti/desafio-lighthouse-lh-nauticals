-- Calcular Ticket Médio e Diversidade para cada cliente
SELECT 
    o.customer_id,
    SUM(o.total::NUMERIC) / COUNT(DISTINCT o.id) AS ticket_medio,
    COUNT(DISTINCT p.category_id) AS total_categorias
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN product_variants pv ON oi.product_variant_id = pv.id
JOIN products p ON pv.product_id = p.id
GROUP BY o.customer_id;

-- MINI-PASSO 2: Filtrar os Top 10 Clientes de Elite
SELECT 
    o.customer_id,
    SUM(o.total::NUMERIC) / COUNT(DISTINCT o.id) AS ticket_medio,
    COUNT(DISTINCT p.category_id) AS total_categorias
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN product_variants pv ON oi.product_variant_id = pv.id
JOIN products p ON pv.product_id = p.id
GROUP BY o.customer_id
HAVING COUNT(DISTINCT p.category_id) >= 13
ORDER BY ticket_medio DESC, o.customer_id ASC
LIMIT 10;

-- MINI-PASSO 3: Identificar a categoria mais vendida para esses 10 clientes
WITH top_10_clientes AS (
    SELECT 
        o.customer_id,
        SUM(o.total::NUMERIC) / COUNT(DISTINCT o.id) AS ticket_medio
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN product_variants pv ON oi.product_variant_id = pv.id
    JOIN products p ON pv.product_id = p.id
    GROUP BY o.customer_id
    HAVING COUNT(DISTINCT p.category_id) >= 13
    ORDER BY ticket_medio DESC, o.customer_id ASC
    LIMIT 10
)
SELECT 
    p.category_id,
    c.name AS nome_categoria,
    SUM(oi.quantity::NUMERIC) AS total_itens_comprados
FROM top_10_clientes t10
JOIN orders o ON t10.customer_id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN product_variants pv ON oi.product_variant_id = pv.id
JOIN products p ON pv.product_id = p.id
LEFT JOIN categories c ON p.category_id = c.id
GROUP BY p.category_id, c.name
ORDER BY total_itens_comprados DESC
LIMIT 1;