#!/bin/bash

# Extracted values from resolve-env.ts
WAN='BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha'
WIL='BLskRTInXnMxWaGqcpSyMgo0nYbalW99cGZESrz3zapM'
WES='BIKKuvBwpmDVA4Ds-EpL5bt9OqPzWPja2LigFYZN2YfX'

# Check if TEST_ENVIRONMENT is set
if [ -z "$TEST_ENVIRONMENT" ]; then
    # Default values for 'docker' environment
    : "${SIGNIFY_SECRETS:=D_PbQb01zuzQgK-kDWjqy,BTaqgh1eeOjXO5iQJp6mb,Akv4TFoiYeHNqzj3N8gEg,CbII3tno87wn3uGBP12qm}"
    : "${TEST_ENVIRONMENT:=docker}"
    : "${ID_ALIAS:=EBADataSubmitter}"
    : "${REG_PILOT_API:=http://127.0.0.1:8000}"
    : "${REG_PILOT_PROXY:=http://127.0.0.1:3434}"
    : "${VLEI_VERIFIER:=http://127.0.0.1:7676}"
    : "${KERIA:=http://127.0.0.1:3901}"
    : "${KERIA_BOOT:=http://127.0.0.1:3903}"
    : "${WITNESS_URLS:=http://witness-demo:5642,http://witness-demo:5643,http://witness-demo:5644}"
    : "${WITNESS_IDS:=$WAN,$WIL,$WES}"
    : "${VLEI_SERVER:=http://vlei-server:7723}"
    : "${SECRETS_JSON_CONFIG:=singlesig-single-aid}"
fi

# Export environment variables
export SIGNIFY_SECRETS TEST_ENVIRONMENT ID_ALIAS REG_PILOT_API REG_PILOT_PROXY VLEI_VERIFIER KERIA KERIA_BOOT WITNESS_URLS WITNESS_IDS VLEI_SERVER SECRETS_JSON_CONFIG

# Print environment variable values
echo "SIGNIFY_SECRETS=$SIGNIFY_SECRETS"
echo "TEST_ENVIRONMENT=$TEST_ENVIRONMENT"
echo "ID_ALIAS=$ID_ALIAS"
echo "REG_PILOT_API=$REG_PILOT_API"
echo "REG_PILOT_PROXY=$REG_PILOT_PROXY"
echo "VLEI_VERIFIER=$VLEI_VERIFIER"
echo "KERIA=$KERIA"
echo "KERIA_BOOT=$KERIA_BOOT"
echo "WITNESS_URLS=$WITNESS_URLS"
echo "WITNESS_IDS=$WITNESS_IDS"
echo "VLEI_SERVER=$VLEI_SERVER"

# Check if the only argument is --all
if [[ $# -eq 1 && $1 == "--all" ]]; then
    set -- --docker=proxy-verify --build --data --report --verify --proxy
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --docker=*)
            docker_action="${1#*=}"
            case $docker_action in
                deps | verify | proxy-verify)
                    docker compose down -v
                    docker compose up "$docker_action" -d --pull always
                    ;;
                *)
                    echo "Unknown docker action: $docker_action"
                    ;;
            esac
            shift # past argument
            ;;
        --build)
            npm run build
            shift # past argument
            ;;
        --data)            
            export GENERATE_TEST_DATA=true
            export WORKFLOW="${WORKFLOW}"
            npx jest ./run-vlei-issuance-workflow.test.ts
            ;;      
        *)
            echo "Unknown argument: $1"
            shift # past argument
            ;;
    esac
done