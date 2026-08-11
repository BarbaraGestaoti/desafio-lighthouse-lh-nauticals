# -*- coding: utf-8 -*-
"""
Created on Mon Aug 10 21:58:35 2026

@author: Admin
"""

##Considere todos os CSV como arquivos de fonte.
## Utilizar obrigatoriamente Python 3.
## Utilizar bibliotecas padrao do Python 3 (csv, os, dateatime, etc.) e Python puro
## Considere o banco de destino como sendo um PostgreSQL


# -*- coding: utf-8 -*-
"""LH NAUTICALS - DESAFIO LIGHTHOUSE

Questão 2: Gerador Automático de Schema PostgreSQL (schema.sql)
"""

import csv
import glob
import os

print("bibliotecas implantadas com sucesso")


def gerar_schema_sql(diretorio_dados="data", arquivo_saida="schema.sql"):
    # 1. Mapeamento de caminhos
    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_dir = os.path.join(script_dir, diretorio_dados)
    output_path = os.path.join(script_dir, arquivo_saida)

    # 2. Localizar arquivos CSV
    csv_files = glob.glob(os.path.join(data_dir, "*.csv"))

    if not csv_files:
        print(f"❌ Nenhum arquivo CSV encontrado na pasta '{data_dir}'.")
        return

    # 3. Estrutura inicial do DDL
    ddl_statements = [
        "-- DDL DE CRIAÇÃO AUTOMÁTICA DAS TABELAS NO POSTGRESQL (CAMADA BRONZE)",
        "-- GERADO AUTOMATICAMENTE VIA SCRIPT PYTHON PURO\n",
    ]

    # 4. Leitura dos CSVs e construção das tabelas
    for file_path in sorted(csv_files):
        file_name = os.path.basename(file_path)

        if file_name.startswith("."):
            continue

        table_name = (
            os.path.splitext(file_name)[0].lower().strip().replace("-", "_")
        )

        with open(file_path, mode="r", encoding="utf-8") as f:
            reader = csv.reader(f)
            headers = next(reader, None)

            if not headers:
                continue

            clean_headers = [
                col.lower().strip().replace("-", "_").replace(" ", "_")
                for col in headers
            ]

            drop_stmt = f'DROP TABLE IF EXISTS "{table_name}" CASCADE;'
            cols_definition = ",\n    ".join(
                [f'"{col}" TEXT' for col in clean_headers]
            )
            create_stmt = f'CREATE TABLE "{table_name}" (\n    {cols_definition}\n);'

            ddl_statements.append(drop_stmt)
            ddl_statements.append(create_stmt)
            ddl_statements.append("")

    # 5. Escrita no arquivo schema.sql
    with open(output_path, mode="w", encoding="utf-8") as out_file:
        out_file.write("\n".join(ddl_statements))

    print(
        f"✅ Arquivo '{arquivo_saida}' gerado com sucesso em: {output_path}"
    )


# Execução direta da função
if __name__ == "__main__":
    gerar_schema_sql()