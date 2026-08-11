"""SCRIPT DE INGESTÃO DINÂMICA AUTOMÁTICA NO POSTGRESQL

Cria as tabelas no PostgreSQL com base nos cabeçalhos reais dos CSVs
e realiza a carga de todos os arquivos da pasta 'data'.
"""

import csv
import glob
import os
import psycopg2

# Configurações de Conexão com o PostgreSQL
DB_CONFIG = {
    "dbname": "postgres",
    "user": "postgres",
    "password": "",  # Senha em branco
    "host": "localhost",
    "port": "5433",
}


def main():
    script_dir = os.getcwd()
    data_dir = os.path.join(script_dir, "data")

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = False
        cursor = conn.cursor()
        print("🔌 Conectado ao PostgreSQL com sucesso!")

        csv_files = glob.glob(os.path.join(data_dir, "*.csv"))
        if not csv_files:
            print(f"❌ Nenhum CSV encontrado na pasta '{data_dir}'.")
            return

        print(f"\n🚀 Processando {len(csv_files)} arquivos CSV...")

        for file_path in sorted(csv_files):
            file_name = os.path.basename(file_path)
            table_name = (
                os.path.splitext(file_name)[0].lower().replace("-", "_")
            )

            # Ignorar arquivos sem dados válidos
            if file_name.startswith("."):
                continue

            with open(file_path, mode="r", encoding="utf-8") as f:
                reader = csv.reader(f)
                headers = next(reader, None)

                if not headers:
                    continue

                # Tratar nomes de colunas para padrão SQL
                clean_headers = [
                    col.lower().strip().replace("-", "_").replace(" ", "_")
                    for col in headers
                ]

                # 1. Recriar tabela dinamicamente com as colunas do CSV
                cols_schema = ", ".join([f'"{col}" TEXT' for col in clean_headers])
                drop_sql = f'DROP TABLE IF EXISTS "{table_name}" CASCADE;'
                create_sql = f'CREATE TABLE "{table_name}" ({cols_schema});'

                cursor.execute(drop_sql)
                cursor.execute(create_sql)

                # 2. Inserir registros em lotes
                cols_str = ", ".join([f'"{col}"' for col in clean_headers])
                rows_count = 0
                insert_rows = []

                for row in reader:
                    rows_count += 1
                    formatted_values = []
                    for val in row:
                        val_clean = val.strip()
                        if val_clean == "":
                            formatted_values.append("NULL")
                        else:
                            val_escaped = val_clean.replace("'", "''")
                            formatted_values.append(f"'{val_escaped}'")

                    insert_rows.append(f"({', '.join(formatted_values)})")

                    if len(insert_rows) >= 1000:
                        values_block = ",\n".join(insert_rows)
                        cursor.execute(
                            f'INSERT INTO "{table_name}" ({cols_str}) VALUES\n{values_block};'
                        )
                        insert_rows = []

                if insert_rows:
                    values_block = ",\n".join(insert_rows)
                    cursor.execute(
                        f'INSERT INTO "{table_name}" ({cols_str}) VALUES\n{values_block};'
                    )

            print(
                f'  📥 Tabela "{table_name}": criada e populada com {rows_count} registros.'
            )

        conn.commit()
        print(
            "\n🎉 Carga concluída com sucesso! Todas as tabelas foram criadas no PostgreSQL."
        )

    except Exception as e:
        if "conn" in locals() and conn:
            conn.rollback()
        print(f"\n❌ Erro durante o processo: {e}")

    finally:
        if "cursor" in locals() and cursor:
            cursor.close()
        if "conn" in locals() and conn:
            conn.close()


if __name__ == "__main__":
    main()