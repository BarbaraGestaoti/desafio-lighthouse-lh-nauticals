-- Reconhecimento da tabela
SELECT *
FROM goods_receipts gr 
LIMIT 100;
-- coluna quantity_receibed registrada como texto

-- Testando a unicidade do ID na tabela goods_receipts
SELECT 
    COUNT(*) AS total_linhas,
    COUNT(DISTINCT id) AS ids_unicos,
    COUNT(*) - COUNT(DISTINCT id) AS diferenca_duplicados
FROM goods_receipts;
-- sem duplicidade

-- Mapeando todos os tipos de observações registradas na coluna 'notes'
SELECT 
    notes,
    COUNT(*) AS qtd_ocorrencias
FROM goods_receipts
WHERE notes IS NOT NULL
GROUP BY notes
ORDER BY qtd_ocorrencias DESC;
-- A maioria das notas não tem registro algum, mas há a ocorrência de textos sem padronização

--buscando novamente informações sobre os funcionarios
SELECT *
FROM employees e 

--auditando
-- Auditando recebimentos com tratamento para funcionários ativos (sem data de demissão)
SELECT 
    gr.id AS recebimento_id,
    gr.received_at::timestamp AS data_recebimento,
    e.full_name AS funcionario_nome,
    e.role AS cargo,
    NULLIF(e.hire_date, '')::date AS data_admissao,
    NULLIF(e.termination_date, '')::date AS data_demissao
FROM goods_receipts gr
LEFT JOIN employees e ON gr.received_by_employee_id = e.id
ORDER BY gr.received_at DESC;

-- AUDITORIA FINANCEIRA: O que os ex-funcionários receberam e o valor total movimentado
-- AUDITORIA: Lista de produtos e valor acumulado recebidos APÓS o desligamento (Renan da Paz)
-- DETALHAMENTO: Produtos recebidos EXCLUSIVAMENTE APÓS a data de demissão
SELECT 
    e.full_name AS ex_funcionario,
    e.role AS cargo,
    NULLIF(e.termination_date, '')::date AS data_demissao,
    gr.received_at::timestamp AS data_recebimento_apos_demissao,
    p.name AS produto_recebido,
    gri.quantity_received::numeric AS qtd_recebida,
    poi.unit_cost::numeric AS custo_unitario,
    ROUND(gri.quantity_received::numeric * poi.unit_cost::numeric, 2) AS custo_total_lote
FROM goods_receipts gr
INNER JOIN employees e ON gr.received_by_employee_id = e.id
INNER JOIN goods_receipt_items gri ON gr.id = gri.goods_receipt_id
LEFT JOIN purchase_order_items poi ON gri.purchase_order_item_id = poi.id
LEFT JOIN product_variants pv ON poi.product_variant_id = pv.id
LEFT JOIN products p ON pv.product_id = p.id
WHERE e.id = '3'
  AND gr.received_at::date > NULLIF(e.termination_date, '')::date
ORDER BY gr.received_at desc;


-- RESUMO FINANCEIRO: Total em R$ movimentado APÓS a demissão
SELECT 
    e.full_name AS ex_funcionario,
    NULLIF(e.termination_date, '')::date AS data_demissao,
    COUNT(DISTINCT gr.id) AS total_notas_pos_demissao,
    SUM(gri.quantity_received::numeric) AS total_itens_recebidos,
    ROUND(SUM(gri.quantity_received::numeric * poi.unit_cost::numeric), 2) AS valor_total_irregulares_rs
FROM goods_receipts gr
INNER JOIN employees e ON gr.received_by_employee_id = e.id
INNER JOIN goods_receipt_items gri ON gr.id = gri.goods_receipt_id
LEFT JOIN purchase_order_items poi ON gri.purchase_order_item_id = poi.id
WHERE e.id = '3'
  AND gr.received_at::date > NULLIF(e.termination_date, '')::date
GROUP BY e.full_name, NULLIF(e.termination_date, '')::date;

/*
==============================================================================
DIAGNÓSTICO DE GOVERNANÇA E IMPACTO FINANCEIRO (goods_receipts):
==============================================================================
1. IMPACTO MONETÁRIO DE CREDENCIAIS INATIVAS:
   - A falha no revogamento do acesso do ex-funcionário Renan da Paz (ID: 3) 
     permitiu o processamento de 105 notas de recebimento pós-demissão.
   - Volume total afetado: 7.280,77 itens de estoque.
   - Exposição financeira total da anomalia: R$ 7.096.625,21.

2. RECOMENDAÇÃO TÉCNICA (CAMADA DE TRANSFORMACAO / DBT):
   - Para a construção dos data marts de estoque/compras (Gold Layer), 
     é necessário filtrar apenas lançamentos de usuários ativos na data do registro, 
     evitando contaminação das métricas operacionais e de auditoria.
==============================================================================
*/

/* 
==============================================================================
ACHADO DE AUDITORIA E SEGURANÇA (SECURITY & DATA QUALITY AUDIT)
TABELA: goods_receipts x employees
==============================================================================
1. USO DE CREDENCIAIS DE EX-FUNCIONÁRIOS (GHOST USERS):
   - Identificados recebimentos de mercadorias registrados por usuários 
     com contrato já encerrado.
   - CASO CRÍTICO: O estoquista Renan da Paz (demitido em 10/07/2023) possui 
     registros de recebimento de materiais realizados em 2026.
   - RECOMENDAÇÃO DE GOVERNANÇA: Bloqueio imediato do usuário no Identity/Access 
     Management (IAM) e reatribuição dos registros operacionais aos logins ativos.
==============================================================================
*/

