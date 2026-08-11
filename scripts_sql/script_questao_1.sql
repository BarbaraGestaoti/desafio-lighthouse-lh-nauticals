-- Questão 1.1:
SELECT * -- selecao completa das colunas, já verifico o status das compras, se teve desconto, valor total (presumo que seja em Real), data registrada como datetime, subtotal, desconto e total registrados como texto
FROM  orders o -- conforme solicitado
LIMIT 10 -- uso de poucas linhas para não travar o banco

SELECT 
    MIN(created_at::TIMESTAMP) AS data_minima, -- para ser possivel destacar as datas, se a data tivesse formato brasileiro seria outro tipo de codigo
    MAX(created_at::TIMESTAMP) AS data_maxima -- a data maxima tem como registro um dia que ainda nao aconteceu, a tabela já fica pronta com essa disponibilidade?, ha registros nessas datas, foi um erro?
FROM orders;

SELECT 
    MIN(total::NUMERIC) AS valor_minimo,
    MAX(total::NUMERIC) AS valor_maximo,
     ROUND(AVG(total::NUMERIC), 2) AS valor_medio
FROM orders; -- verifiquei no inicio da consulta que há compras que constam como cancelados, mas consta no valor total, isso pode confundir o faturamento, será necessario verificar se há algum registro duplicado onde conste a por exemplo a atualização desta compra, conferir junto ao time de negocio os rotulos das colunas

-- Questão 1.1: Análise Exploratória e Métricas Agregadas da tabela orders
SELECT 
    COUNT(*) AS total_linhas,
    MIN(created_at::TIMESTAMP) AS data_minima,
    MAX(created_at::TIMESTAMP) AS data_maxima,
    MIN(total::NUMERIC) AS valor_minimo,
    MAX(total::NUMERIC) AS valor_maximo,
    ROUND(AVG(total::NUMERIC), 2) AS valor_medio
FROM orders; -- uma forma mais prática de criar a consulta e fazer um codigo limpo, assertivo, experimentei fazer desta forma para ter uma visao unica

