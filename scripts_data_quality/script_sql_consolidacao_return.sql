SELECT *
FROM return_items ri 
LIMIT 100;
--esta tabela apresenta as devoluções dos produtos

SELECT *
FROM "returns" r 
LIMIT 100;
-- esta tabela detalha mais as questões de devolução, os detalhes


-- fazendo a join para verificar aspectos de duas tabelas e obter respostas
SELECT 
    r.reason AS motivo_devolucao,
    COUNT(DISTINCT r.id) AS total_solicitacoes_devolucao,
    COUNT(ri.id) AS total_itens_devolvidos,
    ROUND(SUM(NULLIF(r.total_refund_amount, '')::numeric), 2) AS valor_total_reembolsado
FROM "returns" r
LEFT JOIN return_items ri ON ri.return_id = r.id
GROUP BY r.reason
ORDER BY total_solicitacoes_devolucao DESC;
-- observo que houve desistencia pura e simples (muito comum em e-commerce), dois registros de compra duplicada, registro de causas evitáveis para a devolução?

