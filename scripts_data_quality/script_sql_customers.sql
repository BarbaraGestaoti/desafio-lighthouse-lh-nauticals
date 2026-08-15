-- Reconhecimento da tabela
SELECT *
FROM customers c 
LIMIT 50;
-- Ocorrência de pronome de tratamento na coluna legal_name
-- Ocorrência de datas no futuro;


-- 1. Contagem Geral e Integridade de IDs (Chave Primária)
SELECT 
    COUNT(*) AS total_clientes,
    COUNT(DISTINCT id) AS ids_unicos
FROM customers;
-- não há duplicidade de clientes

-- 2. Diagnóstico de Nulos e Qualidade do Cadastro
SELECT 
    COUNT(*) AS total,
    COUNT(email) AS com_email,
    COUNT(phone) AS com_telefone,
    COUNT(*) - COUNT(email) AS email_nulos
FROM customers;
-- não há registro de nulos 

-- 3. verificando as inconsistências de data
SELECT 
    id, 
    c.legal_name, 
    created_at, 
    updated_at
FROM customers c 
WHERE created_at::timestamp > CURRENT_TIMESTAMP;
-- Há 129 registros em datas futuras nas colunas created_at e updated_at
-- Possível geração sintética de dados (mock dataset) ou erro no relógio do sistema de origem.

-- A coluna 'created_at' e updated_at encontram-se com tipo TEXT, requer conversão para timestamp para consultas temporais