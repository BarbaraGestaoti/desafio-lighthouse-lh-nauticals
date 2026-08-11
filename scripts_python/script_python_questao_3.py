# -*- coding: utf-8 -*-
"""LH NAUTICALS - DESAFIO LIGHTHOUSE
Questão 3: Carregamento de Dados (ETL) para a Camada Bronze
"""

import glob
import os
import psycopg2

print("Iniciando o processo de carregamento...")
# %%

# Configuração da conexão
DB_CONFIG = {
    "dbname": "postgres",
    "user": "postgres",
    "password": "",  
    "host": "localhost",
    "port": "5433",  # Porta utilizada no seu DBeaver
}
# %%

# Mapeamento de caminhos
pasta_script = os.path.dirname(os.path.abspath(__file__))
pasta_dados = os.path.join(pasta_script, "data")
arquivos_csv = glob.glob(os.path.join(pasta_dados, "*.csv"))
# %%

# Execução do carregamento
conexao = psycopg2.connect(**DB_CONFIG)
cursor = conexao.cursor()

print(f"Encontrados {len(arquivos_csv)} arquivos para carregar.")

for caminho_arquivo in sorted(arquivos_csv):
    nome_arquivo = os.path.basename(caminho_arquivo)

    if nome_arquivo.startswith("."):
        continue

    nome_tabela = (
        os.path.splitext(nome_arquivo)[0].lower().strip().replace("-", "_")
    )

    with open(caminho_arquivo, mode="r", encoding="utf-8") as arquivo:
        next(arquivo)  # Pula o cabeçalho do CSV
        comando_copy = f'COPY "{nome_tabela}" FROM STDIN WITH (FORMAT csv, DELIMITER \',\', HEADER false);'
        cursor.copy_expert(sql=comando_copy, file=arquivo)
        print(f" -> Tabela '{nome_tabela}' carregada com sucesso!")

conexao.commit()
cursor.close()
conexao.close()

print("\n🎉 Carregamento concluído com sucesso!")