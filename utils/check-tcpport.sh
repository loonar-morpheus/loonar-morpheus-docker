#!/bin/bash

if [ -z "$1" ]; then
    echo "Uso: $0 <porta>"
    exit 1
fi

PORT=$1

if [ "$EUID" -ne 0 ]; then
    echo "Este script precisa ser executado como root. Use sudo."
    exit 1
fi

if command -v lsof &> /dev/null; then
    PIDS=$(lsof -i :"$PORT" -t)
elif command -v ss &> /dev/null; then
    PIDS=$(ss -tulnp | grep ":$PORT " | awk '{print $7}' | cut -d',' -f2 | cut -d'=' -f2)
elif command -v netstat &> /dev/null; then
    PIDS=$(netstat -tulnp 2>/dev/null | grep ":$PORT " | awk '{print $7}' | cut -d'/' -f1)
else
    echo "Necessário lsof, ss ou netstat para continuar"
    exit 1
fi

if [ -n "$PIDS" ]; then
    echo "A porta $PORT já está em uso pelos seguintes processos:"

    for PID in $PIDS; do
        PROCESS_NAME=$(ps -p "$PID" -o comm= 2>/dev/null)

        if [ -e "/proc/$PID/exe" ]; then
            EXEC_PATH=$(readlink -f /proc/"$PID"/exe)
        else
            EXEC_PATH="Caminho não encontrado (pode ser um processo de sistema ou protegido)"
        fi

        if [[ "$PROCESS_NAME" == "docker-proxy" ]]; then
            CONTAINER_ID=$(docker ps --format "{{.ID}} {{.Ports}}" | grep ":$PORT" | awk '{print $1}')
            CONTAINER_NAME=$(docker ps --filter "id=$CONTAINER_ID" --format "{{.Names}}")
            
            if [ -n "$CONTAINER_NAME" ]; then
                echo "🔹 PID: $PID (Encaminhado pelo Docker)"
                echo "🔹 Container: $CONTAINER_NAME (ID: $CONTAINER_ID)"
            else
                echo "🔹 PID: $PID (docker-proxy sem container identificado)"
            fi
        else
            echo "🔹 PID: $PID"
            echo "🔹 Nome: $PROCESS_NAME"
            echo "🔹 Caminho do Executável: $EXEC_PATH"
        fi

        echo "---------------------------------------"
    done

    exit 1
else
    echo "A porta $PORT está livre para uso."
    exit 0
fi
