#!/bin/bash

# Define a pasta a ser verificada (a pasta "Downloads" da home do usuário)
folder="$HOME/Downloads"

# Variável para armazenar a opção de exclusão automática
excluir_automaticamente=false

# Verifica se o parâmetro de exclusão automática foi fornecido
if [[ "$1" == "-e" && "$2" == "sim" ]]; then
    excluir_automaticamente=true
fi

# Array associativo para armazenar os hashes e caminhos dos arquivos duplicados
declare -A file_hashes

# Contador de arquivos duplicados
num_duplicados=0

# Contador de arquivos excluidos
num_excluidos=0

# Percorre todos os arquivos na pasta
while IFS= read -r file; do
    # Calcula o hash MD5 do arquivo
    hash=$(md5sum "$file" | awk '{print $1}')

    # Verifica se o hash já existe no array de hashes
    if [[ -n "${file_hashes[$hash]}" ]]; then
        echo "Arquivo duplicado encontrado:"
        echo "  Arquivo 1: ${file_hashes[$hash]}"
        echo "  Arquivo 2: $file"
        ((num_duplicados++))

        if $excluir_automaticamente; then
            # Excluindo arquivo duplicado
            rm "$file"
            ((num_excluidos++))
            echo "Arquivo excluído."
        fi
    else
        # Armazena o hash e o caminho do arquivo no array de hashes
        file_hashes[$hash]=$file
    fi
done < <(find "$folder" -type f)

echo "Verificação concluída. Total de arquivos duplicados encontrados: $num_duplicados."