-- QUESTÃO 5.1: Dimensão de Calendário + Vendas por Dia da Semana
WITH limites AS (
    -- 1. Encontra a menor e a maior data de venda das lojas físicas ('pos')
    SELECT 
        MIN(created_at::date) AS data_inicio,
        MAX(created_at::date) AS data_fim
    FROM orders
    WHERE channel = 'pos'
),
calendario AS (
    -- 2. Gera todos os dias consecutivos do período (sem pular nenhum dia)
    SELECT 
        generate_series(data_inicio, data_fim, '1 day'::interval)::date AS data_dia
    FROM limites
),
vendas_diarias AS (
    -- 3. Soma as vendas reais por dia das lojas físicas ('pos')
    SELECT 
        created_at::date AS data_dia,
        SUM(total::NUMERIC) AS total_vendas
    FROM orders
    WHERE channel = 'pos'
    GROUP BY created_at::date
),
calendario_com_vendas AS (
    -- 4. Cruza o calendário completo com as vendas, substituindo dias sem venda por 0
    SELECT 
        c.data_dia,
        -- Mapeia o dia da semana em português
        CASE EXTRACT(ISODOW FROM c.data_dia)
            WHEN 1 THEN 'Segunda-feira'
            WHEN 2 THEN 'Terça-feira'
            WHEN 3 THEN 'Quarta-feira'
            WHEN 4 THEN 'Quinta-feira'
            WHEN 5 THEN 'Sexta-feira'
            WHEN 6 THEN 'Sábado'
            WHEN 7 THEN 'Domingo'
        END AS dia_semana,
        EXTRACT(ISODOW FROM c.data_dia) AS num_dia_semana,
        COALESCE(v.total_vendas, 0) AS faturamento_dia
    FROM calendario c
    LEFT JOIN vendas_diarias v ON c.data_dia = v.data_dia
)
-- 5. Calcula a média real de vendas por dia da semana
SELECT 
    dia_semana,
    COUNT(*) AS total_dias_no_periodo,
    ROUND(AVG(faturamento_dia), 2) AS media_vendas_diaria,
    SUM(faturamento_dia) AS faturamento_total
FROM calendario_com_vendas
GROUP BY dia_semana, num_dia_semana
ORDER BY num_dia_semana;