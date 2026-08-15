-- Reconhecimento da tabela
SELECT *
FROM fiscal_invoices fi 
LIMIT 100;
-- parece haver um rigor maior no cadastro das notas fiscais.

--Como nas outras tabelas identifiquei uma inconsistência de datas futuras, investigo esta tabela também
SELECT 
    id, 
    order_id, 
    fi.nfe_access_key,
    created_at,
    updated_at
FROM fiscal_invoices fi   
WHERE created_at::timestamp > CURRENT_TIMESTAMP;
-- Esta tabela tem mais de 30 mil linhas, opto pela contagem com códgio para identificar o quantitativo, a seguir:

--Contagem de notas em datas futuras
SELECT
    count(*) AS total_notas,
    count(CASE WHEN created_at::timestamp> current_timestamp THEN 1 end) AS notas_datas_futuras,
    round(
         100.0 * count(CASE WHEN created_at::timestamp > current_timestamp THEN 1 END) / count(*),
         2
   ) AS pct_datas_futuras
   FROM fiscal_invoices; 
-- registro de 34.365 notas, 
-- 2.945 notas identificadas com datas futuras.
-- 8,57% das notas com datas futuras.
--Possível geração sintética de dados (mock dataset) ou erro no relógio do sistema de origem.
-- A coluna 'created_at' e updated_at encontram-se com tipo TEXT, requer conversão para timestamp para consultas temporais

-- pesquisando o status das notas e o % por status
-- pesquisndo o valor máximo, mínimo e total por ano

SELECT 
    status,
    COUNT(*) AS total_notas,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_status
FROM fiscal_invoices
GROUP BY status
ORDER BY total_notas DESC;
--  Entendendo a distribuição de volume por Ano e Status
-- No geral há 92% de notas autorizadas, 5% de notas canceladas e 3% de notas rejeitadas, é necessário aprofundar mais para saber motivos de cancelamento e rejeição
-- Necessário saber não apenas as notas por status, mas quanto representam em valores

-- Cálculo de notas por status ao longo dos anos x o total geral
SELECT 
    EXTRACT(YEAR FROM issued_at::timestamp) AS ano,
    status,
    COUNT(*) AS total_notas,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_status
FROM fiscal_invoices
GROUP BY 
    EXTRACT(YEAR FROM issued_at::timestamp),
    status
ORDER BY ano, status;


-- Calculando a porcentagem de cada status DENTRO de cada ano
SELECT 
    EXTRACT(YEAR FROM issued_at::timestamp) AS ano,
    status,
    COUNT(*) AS total_notas,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY EXTRACT(YEAR FROM issued_at::timestamp)), 
        2
    ) AS pct_no_ano
FROM fiscal_invoices
GROUP BY 
    EXTRACT(YEAR FROM issued_at::timestamp),
    status
ORDER BY ano, status;


-- Cálculo da representatividade do valor das notas por ano
SELECT 
    EXTRACT(YEAR FROM issued_at::timestamp) AS ano,
    status,
    COUNT(*) AS total_notas,
    ROUND(SUM(total_amount::numeric), 2) AS valor_total,
    ROUND(
        100.0 * SUM(total_amount::numeric) / SUM(SUM(total_amount::numeric)) OVER(PARTITION BY EXTRACT(YEAR FROM issued_at::timestamp)), 
        2
    ) AS pct_valor_no_ano
FROM fiscal_invoices
GROUP BY 
    EXTRACT(YEAR FROM issued_at::timestamp),
    status
ORDER BY ano, status;

/*
==============================================================================
CONCLUSÃO DA ANÁLISE FINANCEIRA E DATA QUALITY (fiscal_invoices):
==============================================================================
1. QUALIDADE DOS DADOS TEMPORAIS:
   - Identificada presença de dados sintéticos ou erros de sistema (8,57% das 
     notas possuem datas futuras de criação/emissão, chegando até 2027).

2. IMPACTO FINANCEIRO DOS STATUS:
   - A análise cruzada por valor (R$) demonstra o peso real das notas canceladas 
     e rejeitadas sobre a receita potencial do negócio em cada ano.
   - Para cálculo de DRE e Faturamento Líquido, é MANDATÓRIO filtrar apenas 
     `status = 'authorized'` e desconsiderar registros com ano superior ao atual.
==============================================================================
*/

