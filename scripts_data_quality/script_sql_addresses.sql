-- Visualizando o banco
SELECT *
FROM addresses a
LIMIT 10;
-- codigo postal sem padronização
-- id do endereço e do cliente corretamente identificado como texto
-- espaço e branco antes do texto na coluna street
-- number - número da residência identificado como texto

-- Verificando duplicidades
SELECT
    a.customer_id,
    COUNT(*) AS qtd_repeticoes
FROM addresses a 
GROUP BY a.customer_id
HAVING COUNT(*) > 1;
-- não há registro de endereços ducplicado no id endereço
-- há duplicidade de endereço por cliente, trata-se de registro de clientes que realmente possuem mais de um endereço ou atualizações no banco que persistiram?
