-- Reconhecimento da tabela
SELECT *
FROM locations 
LIMIT 100;
-- coluna quantity_receibed registrada como texto
-- registro de datas futuras

-- Mapeando endereços/locais criados ou atualizados no futuro
SELECT 
    id,
    city,
    state,
    created_at::timestamp AS data_criacao,
    updated_at::timestamp AS data_atualizacao
FROM locations
WHERE created_at::timestamp > CURRENT_TIMESTAMP 
   OR updated_at::timestamp > CURRENT_TIMESTAMP
ORDER BY updated_at DESC;

