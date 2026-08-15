-- Reconhecendo a tabela
SELECT *
FROM brands b 
LIMIT 100;

-- A tabela tem 12 linhas, verifico nas datas, registros futuros, investigando melhor
-- 1. Verificando registros com data de criação no futuro (considerando hoje)
-- 2. As datas estão registradas como texto, será necessária a transformação para timestamp
-- 1. Verificando registros com data de criação no futuro (fazendo o CAST para timestamp)
SELECT 
    id, 
    name, 
    created_at, 
    updated_at
FROM brands
WHERE created_at::timestamp > CURRENT_TIMESTAMP;
-- Ocorreu o registro do id 1 - Yamaha Marine registrado com data futura, verificar com o time de negócios se houve uso de dados sintéticos ou descompasso do relógio da aplicação de origem. Recomenda-se aplicar filtros temporais na camada de analytics.
