#! /bin/bash -e


POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=authorization-server,app.kubernetes.io/instance=authorization-server" -o jsonpath="{.items[0].metadata.name}")

kubectl exec $POD_NAME -- curl -s -X POST -u messaging-client:secret -d "client_id=messaging-client" -d "username=user" -d "password=password" \
    -d "grant_type=password" \
    http://localhost:9000/oauth2/token | jq -r .access_token 