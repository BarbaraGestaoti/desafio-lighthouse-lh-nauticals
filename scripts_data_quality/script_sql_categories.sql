-- Reconhecendo a tabela
SELECT *
FROM categories c 
LIMIT 50;
-- 14 categorias
-- uso de letras maiúsculas e minúsculas, falta padronização
-- colete salva vidas não possui parent category id

-- Mapeando a hierarquia mantendo a sintaxe e nomes originais
SELECT 
   c1.id AS category_id,
   c1.name AS category_name,
   c1.parent_category_id,
   c2.name AS parent_category_name
FROM categories c1
LEFT JOIN categories c2 ON c1.parent_category_id = c2.id 
ORDER BY c1.id;

/* 
==============================================================================
OBSERVAÇÕES DE DATA QUALITY (DQ) - TABELA: categories
==============================================================================
1. ESTRUTURA E HIERARQUIA:
   - A tabela utiliza autorreferência (Self-Join) através da coluna 
     `parent_category_id` para criar a relação entre Categorias Principais e Subcategorias.
   - Categorias Principais (Pai): possuem `parent_category_id` igual a NULL (ex: 'Cabos', 'Coletes Salva-Vidas').
   - Subcategorias (Filho): possuem o ID da categoria pai mapeado.

2. INCONSISTÊNCIAS IDENTIFICADAS (BACKLOG DE TRATAMENTO / CAMADA SILVER):
   - Inconsistência de Negócio: Há erros na associação hierárquica na origem. 
     Exemplo: 'Motores' e 'Velas' estão associados ao ID 3 ('Coletes Salva-Vidas').
   - Despadronização de Formato: A coluna `name` mistura casing (ex: 'SEGURANÇA' em maiúsculo vs 'Pintura Marítima' em Title Case).
   - Erro no Slug: Falha na limpeza de acentuação na geração de slugs (ex: 'Âncoras' virou 'ncoras').

3. AÇÃO RECOMENDADA:
   - Manter a estrutura bruta (Bronze) sem alterações.
   - Tratar padronização de texto e regras de exceção na camada de transformação (Silver/dbt).
==============================================================================
*/