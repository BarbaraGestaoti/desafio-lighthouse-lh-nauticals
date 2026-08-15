--Reconhecimento do banco
SELECT *
FROM product_suppliers ps 
LIMIT 100;
--numeros como textos
-- dá o tempo entre compra do produto e a chegada, vejo que há compras com mais de 30 dias, é possível agilizar este processo?

--Um mesmo produto pode ter mais de um fornecedor, verifico quais são os produtos, o total de fornecedores e o tempo de entrega
-- Considerar o estoque em mãos, as vezes um fornecedor pode demorar mais para entregar mas praticar preços melhores, necessario discutir com o time de negocio
SELECT 
    product_variant_id,
    COUNT(supplier_id) AS total_fornecedores,
    MIN(lead_time_days) AS menor_lead_time,
    MAX(lead_time_days) AS maior_lead_time
FROM product_suppliers
GROUP BY product_variant_id
HAVING COUNT(supplier_id) > 1
ORDER BY total_fornecedores DESC;

-- Identificando produtos com prazo superior a 30 dias para entrega, estes produtos necessitam de atenção para o estoque, produtos com alto giro necessitam ser monitorados para tempo hábil de reposição e vantagem na negociação
SELECT 
    product_variant_id,
    supplier_id,
    last_quoted_cost,
    lead_time_days,
    is_preferred
FROM product_suppliers
WHERE lead_time_days > '30'
ORDER BY lead_time_days DESC;

-- checando duplicidades
SELECT 
    product_variant_id, 
    supplier_id, 
    COUNT(*) AS duplicados
FROM product_suppliers
GROUP BY product_variant_id, supplier_id
HAVING COUNT(*) > 1;
-- nao constam duplicidades

