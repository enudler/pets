#!/bin/bash -e

function deploy() {
    echo "Info: Deploying a new application instance..."
    URL=$BASE_MARATHON_URL/v2/apps/$SERVICE_ID?force=true

    JSON=$(node config/helpers/generateConfig.js)

    HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X PUT $URL -d $JSON -H "Content-Type: application/json")
    HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
    if [[ ! $HTTP_STATUS -eq 201 && ! $HTTP_STATUS -eq 200 ]]; then
        echo "Error: Failed to deploy the application to $URL"
        echo HTTP status: $HTTP_STATUS
        echo HTTP message: $HTTP_BODY
        exit 1
    else
        echo "Info: Successfully created deployment of the application to $URL"
        echo HTTP status: $HTTP_STATUS
        echo HTTP message: $HTTP_BODY
    fi
    deploymentId=$(echo $HTTP_BODY  | grep -o '\w\{8\}\-\w\{4\}-\w\{4\}-\w\{4\}-\w\{12\}')
    checkDeployment $deploymentId
}

function destroy() {
    echo "Info: Destroying existing application deployment..."
    URL=$BASE_MARATHON_URL/v2/apps/$SERVICE_ID\?force=true
    HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X DELETE $URL)
    HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

    if [[ $HTTP_STATUS -ne 200 && -z $(echo $HTTP_BODY | grep "does not exist") ]]; then
        echo "Error: Failed to destroy the application in $URL"
        echo HTTP status: $HTTP_STATUS
        echo HTTP message: $HTTP_BODY
        exit 1
    fi
}

function health() {
    HEALTH_CHECK_TIMEOUT=20;
    HEALTH_CHECK_INTERVAL=1;
    URL=$APP_URL$HEALTH_PATH
    echo "Info: Application health check URL $URL"
    while [[ ($HTTP_STATUS -ne 200 || -z $(echo $HTTP_BODY | egrep "build.*$BUILD")) && $HEALTH_CHECK_TIMEOUT -gt 0 ]]; do
        echo "Info: Performing health check..."
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X GET $URL)
        HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
        echo HTTP status: $HTTP_STATUS
        echo HTTP message: $HTTP_BODY
        let HEALTH_CHECK_TIMEOUT=HEALTH_CHECK_TIMEOUT-1
        sleep $HEALTH_CHECK_INTERVAL
    done

    if [[ $HTTP_STATUS -ne 200 ]]; then
        echo "Error: Timeout waiting for status code 200 from the application"
        exit 1

    elif [[ -z $(echo $HTTP_BODY | egrep "build.*$BUILD") ]]; then
        echo "Error: Timeout waiting for new application to load with version $BUILD"
        exit 1
    else
        echo "Info: Application in DC/OS health check is successful"
    fi
}

function checkDeployment() {
    DEPLOYMENT_CHECK_TIMEOUT=180;
    DEPLOYMENT_CHECK_INTERVAL=1;
    URL=$BASE_MARATHON_URL/v2/deployments
    echo "Info: Getting deployments from $URL..."
    deploymentId=$1
    DEPLOYMENT_FINISHED=false
    echo HTTP_STATUS=$HTTP_STATUS
    echo DEPLOYMENT_FINISHED=$DEPLOYMENT_FINISHED
    echo DEPLOYMENT_CHECK_TIMEOUT=$DEPLOYMENT_CHECK_TIMEOUT
    while [[ $DEPLOYMENT_FINISHED == false && $DEPLOYMENT_CHECK_TIMEOUT -gt 0 ]]; do
        echo "Info: Looking for deployment $deploymentId in the response"
        HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X GET $URL)
        HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
        echo HTTP status: $HTTP_STATUS
        echo HTTP message: $HTTP_BODY
        DEPLOYMENT_FINISHED=$([ -z $(echo $HTTP_BODY | grep $deploymentId) ] && echo true || echo false)
        echo DEPLOYMENT_FINISHED=$DEPLOYMENT_FINISHED
        let DEPLOYMENT_CHECK_TIMEOUT=DEPLOYMENT_CHECK_TIMEOUT-1
        echo DEPLOYMENT_CHECK_TIMEOUT=$DEPLOYMENT_CHECK_TIMEOUT
        sleep $DEPLOYMENT_CHECK_INTERVAL
    done

    if [[ $DEPLOYMENT_FINISHED == true ]];then
        echo "Info: Deployment $deploymentId was ended successfully"
    else
        echo "Error: Deployment $deploymentId was not ended successfully"
        deleteDeployment $deploymentId
        exit 1
    fi
}

function deleteDeployment() {
    DEPLOYMENT_CHECK_TIMEOUT=20;
    DEPLOYMENT_CHECK_INTERVAL=1;
    deploymentId=$1
    URL=$BASE_MARATHON_URL/v2/deployments/$deploymentId
    echo "Deleting deployment using URL $URL"
    HTTP_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -X DELETE $URL)
    HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
    echo HTTP status: $HTTP_STATUS
    echo HTTP message: $HTTP_BODY

    if [[ $HTTP_STATUS -ne 200 ]];then
        echo "Error: Failed to delete deployment $deploymentId"
        exit 1
    fi
}

function marathon() {
    echo "Info: Running marathon script for applcation $SERVICE_ID"
    for option in ${@}; do
        case $option in
        --deleteDeployment)
            deleteDeployment $2
            ;;
        --destroy)
            destroy
            ;;
        --deploy)
            deploy
            ;;
        --health)
            health
            ;;
        *)
            echo "Usage: ./marathon.sh <deleteDeployment|deploy|destroy|health>"
            ;;
        esac
    done
}