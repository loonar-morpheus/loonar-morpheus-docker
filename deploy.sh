#!/bin/bash

set -e

# Verifica se há parâmetros
if [ "$#" -lt 2 ]; then
    echo "Uso: $0 /caminho/desejado VAR1=valor1 VAR2=valor2 ..."
    exit 1
fi

# Executa o script de verificação para cada variável que termina com _PORT
for arg in "$@"; do
    var_name="${arg%%=*}"
    var_value="${arg#*=}"
    if [[ "$var_name" =~ _PORT$ ]]; then
        sudo ./utils/check-tcpport.sh "$var_value"
    fi
done

# Obtém o caminho do primeiro parâmetro e muda para o diretório
TARGET_PATH="$1"
shift

if [ ! -d "$TARGET_PATH" ]; then
    echo "Erro: O diretório $TARGET_PATH não existe."
    exit 1
fi

cd "$TARGET_PATH" || exit 1

# Define o nome do arquivo .env no diretório de destino
ENV_FILE=".env"

# Processa os argumentos e atualiza o arquivo .env
for arg in "$@"; do
    # Verifica se o argumento está no formato esperado
    if [[ "$arg" =~ ^[A-Za-z_][A-Za-z0-9_]*=.*$ ]]; then
        var_name="${arg%%=*}"
        var_value="${arg#*=}"
        
        # Exporta a variável
        export "$var_name"="$var_value"
        echo "Exportado: $var_name=$var_value"
        
        # Atualiza ou adiciona a variável ao arquivo .env
        if grep -q "^$var_name=" "$ENV_FILE"; then
            sed -i "s/^$var_name=.*/$var_name=$var_value/" "$ENV_FILE"
        else
            echo "$var_name=$var_value" >> "$ENV_FILE"
        fi
    else
        echo "Ignorando argumento inválido: $arg"
    fi

done

# Executa o Docker Compose
docker compose up -d
