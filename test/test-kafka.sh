#! /bin/bash

kubectl exec kafka-0 -- bash bin/kafka-topics.sh --list --bootstrap-server kafka:9092

if [ $? -ne 0 ]; then
    echo "Error: kafka-topics.sh --list failed"
    exit 1
fi
