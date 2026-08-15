-- Reconhecimento da tabela
SELECT *
FROM employees e 
LIMIT 30;
-- coluna 'full name' tem ocorrência de pronome de tratamento e espaço antes do início do nome
-- 16 registros de empregados
SELECT 
    id, 
    full_name, 
    created_at, 
    updated_at
FROM employees e  
WHERE created_at::timestamp > CURRENT_TIMESTAMP;
-- Há 1 registro em data futura nas colunas created_at e updated_at
-- Possível geração sintética de dados (mock dataset) ou erro no relógio do sistema de origem.

-- A coluna 'created_at' e updated_at encontram-se com tipo TEXT, requer conversão para timestamp para consultas temporais