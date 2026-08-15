-- Reconhecimento da tabela
SELECT *
FROM payments  
LIMIT 100;
-- valores numericos registrados como texto

-- valores numericos como texto
-- pagamento pix pendende
-- cruzar pedido da tabela order com pagamento
-- Reconhecimento detalhado: payments
-- Reconhecimento detalhado: payments (Tratado contra strings vazias)
SELECT 
    id,
    order_id,
    method AS metodo_pagamento,
    NULLIF(installments, '')::integer AS qtd_parcelas,
    NULLIF(amount, '')::numeric AS valor_pago,
    status AS status_pagamento,
    NULLIF(paid_at, '')::timestamp AS data_pagamento,
    NULLIF(created_at, '')::timestamp AS data_criacao
FROM payments
LIMIT 100;
-- pagamento parcelado, o valor pago é referente a parcela ou ao valor todo, penso que pagamentos em transito deveriam estar separados

-- CRUZAMENTO: Métodos de pagamento e receita (com tratamento de tipo e data)
SELECT 
    p.method AS metodo_pagamento,
    COUNT(DISTINCT p.order_id) AS total_pedidos,
    ROUND(SUM(CASE WHEN p.status = 'approved' THEN NULLIF(p.amount, '')::numeric ELSE 0 END), 2) AS receita_aprovada_rs,
    ROUND(SUM(CASE WHEN p.status <> 'approved' OR NULLIF(p.paid_at, '') IS NULL THEN NULLIF(p.amount, '')::numeric ELSE 0 END), 2) AS valor_pendente_ou_estornado_rs
FROM payments p
INNER JOIN orders o ON p.order_id = o.id
WHERE o.status IN ('paid', 'confirmed')
GROUP BY p.method
ORDER BY receita_aprovada_rs DESC;
--pix é o meio de pagamento mais utilizado

/*
==============================================================================
DATA QUALITY AUDIT & TRATAMENTO DE BUGS (payments)
==============================================================================
1. STRING VAZIA vs NULL (paid_at / created_at / amount):
   - A base armazena ausência de dado como texto vazio ('') em vez de NULL.
   - Aplicação obrigatoria de NULLIF(coluna, '') antes dos castings de tipo 
     (::timestamp, ::numeric, ::integer) para evitar exceções de runtime (SQL state 22007).
   - Na camada Staging/dbt: Tratar essa sanitização na limpeza inicial da view/tabela.
==============================================================================
*/