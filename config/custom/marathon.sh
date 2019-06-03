function getMarathonAppName() {
    if [[ $CI_COMMIT_REF_NAME = "master" || $CI_COMMIT_TAG ]]; then
        echo $ENVIRONMENT-$(getAppName)
    else
        echo $(echo $CI_COMMIT_REF_NAME | cut -c 1-30 | sed 's/-*$//')
    fi
}

function getServiceId() {
    [ ! -z "$MARATHON_GROUP_NAME" ] && SERVICE_ID=$MARATHON_GROUP_NAME
    [ "$IS_REVIEW" = true ] && SERVICE_ID=$SERVICE_ID/review/$(getAppName)
    [ ! -z "$SERVICE_ID" ] && SERVICE_ID=$SERVICE_ID/$MARATHON_APP_NAME || SERVICE_ID=$MARATHON_APP_NAME
    echo $(toLowerCase $SERVICE_ID)
}
function getAppUrl() {
    if [[ $(isMacOS) == true && "$LOCAL_APP" == true ]];then
        echo http://$DOCKER_IP:$PORT
    else
        APP_URL=http://$(echo $SERVICE_ID | tr '/' '\n' | tac | tr '\n' '.')
        echo $APP_URL$(getAppDcosUrl)
    fi
}

function getAppInternalUrl() {
    echo $(echo $(getAppUrl) | sed 's|dcos|dcos-internal|')
}

export MARATHON_APP_NAME=$(getMarathonAppName)
export MARATHON_GROUP_NAME=$(getAppName)
export SERVICE_ID=$(getServiceId)
export APP_URL=$(getAppUrl)
export APP_INTERNAL_URL=$(getAppInternalUrl)

echo MARATHON_APP_NAME=$MARATHON_APP_NAME
echo MARATHON_GROUP_NAME=$MARATHON_GROUP_NAME
echo SERVICE_ID=$SERVICE_ID
echo APP_URL=$APP_URL
echo APP_INTERNAL_URL=$APP_INTERNAL_URL