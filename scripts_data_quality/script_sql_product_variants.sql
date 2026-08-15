
SELECT *
FROM product_variants pv 
LIMIT 100;
-- esta tabela dá o valor de venda, o valor de custo, o peso, impostos e dimensão de data

SELECT 
    -- 1. Total de registros analisados
    COUNT(*) AS total_variantes,
    
    -- 2. Verificação de Código de Barras (EAN) Ausente/Nulo
    COUNT(*) FILTER (WHERE barcode_ean IS NULL OR barcode_ean = '') AS ean_nulos,
    
    -- 3. Inconsistência de Preços (Custo Maior que Venda = Prejuízo)
    COUNT(*) FILTER (
        WHERE NULLIF(cost_price, '')::numeric > NULLIF(sale_price, '')::numeric
    ) AS variantes_com_prejuizo,
    
    -- 4. Preços ou Custos Zerados/Negativos
    COUNT(*) FILTER (
        WHERE NULLIF(sale_price, '')::numeric <= 0 OR NULLIF(cost_price, '')::numeric <= 0
    ) AS precos_invalidos,
    
    -- 5. Pesos Nulos ou Incorretos
    COUNT(*) FILTER (
        WHERE weight_kg IS NULL OR weight_kg = '' OR NULLIF(weight_kg, '')::numeric <= 0
    ) AS pesos_invalidos,
    
    -- 6. Margem Bruta Média Geral (%)
    ROUND(
        AVG(
            (NULLIF(sale_price, '')::numeric - NULLIF(cost_price, '')::numeric) / 
            NULLIF(NULLIF(sale_price, '')::numeric, 0)
        ) * 100, 
        2
    ) AS margem_bruta_media_pct
FROM product_variants;

-- Detalhamento dos 157 produtos sem EAN para plano de ação
SELECT 
    pv.id AS variant_id,
    p.name AS produto_nome,
    pv.sku,
    pv.sale_price::numeric AS preco_venda,
    pv.cost_price::numeric AS preco_custo
FROM product_variants pv
LEFT JOIN products p ON p.id = pv.product_id
WHERE pv.barcode_ean IS NULL OR pv.barcode_ean = ''
ORDER BY pv.id ASC;
-- A ausência de EAN em 157 variantes obriga a identificação e baixa manual de estoque. Isso gera risco de inversão de baixas entre produtos de mesmo valor, acarretando furos de estoque (stockout ou inventário fantasma) e falhas na rastreabilidade logística.