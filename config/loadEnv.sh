#!/bin/bash -e
if [ $1 ];then
    export CLUSTER=$1
elif [ -z "$CLUSTER" ];then
    export CLUSTER=$CI_ENVIRONMENT_NAME
fi

# Get to the project's root directory
# while [ ! -f package.json ];do cd ..; done

function setLocalEnvVars() {
    isLocalApp
    setCommitRef
    setRegistry
}

function setCommonEnvVars() {
    # Commont
    export IS_REVIEW=$(getIsReview)
    export APP_NAME=$(getAppName)
    export BRANCH_NAME=$(getBranchName)
    export BUILD=$(getBuild)
    export CLUSTER=$(getCluster)
    export ENV=$(getEnvironment)
    export DOCKER_IP=$(getDockerIp)
    export APP_IMAGE=$(getAppImage)
    export DOCKER_URI=$(getDockerUri)
    
    reportEnvVars
}



function isMacOS() {
    [ $(uname) = "Darwin" ] && echo true || echo false
}

function setCommitRef() {
    if [[ $(isMacOS) == true ]];then
        export CI_COMMIT_REF_NAME=$(cat .git/HEAD | cut -d'/' -f3)
    fi
}

function setRegistry() {
    if [[ $(isMacOS) == true ]];then
        CI_REGISTRY_IMAGE=$(cat .git/config | grep "url =" | cut -d'=' -f2 | sed 's| git@git.zooz.co:|docker-registry.zooz.co:4567/|' | sed 's|\.git||')
        export CI_REGISTRY_IMAGE=$(toLowerCase $CI_REGISTRY_IMAGE)
    fi
}

function getIsReview() {
    [[ "$CLUSTER" == review* ]] && echo true || echo false
}

function getAppName() {
    if [ $CI_PROJECT_NAME ];then
        echo $(toLowerCase $CI_PROJECT_NAME)
    else
        echo $(cat .git/config | grep "url =" | rev | cut -d'/' -f1 | rev | cut -d'.' -f1)
    fi
}

function getBranchName() {
    if [ $CI_COMMIT_REF_NAME != master ] && [[ -z "$CI_COMMIT_TAG" ]];then
        echo $CI_COMMIT_REF_NAME
    fi
}

function getBuild() {
    if [[ $CI_COMMIT_REF_NAME = master ]]; then
        echo $CI_PIPELINE_ID
    else
        echo $CI_COMMIT_REF_NAME
    fi
}

function getAppImage() {
    # App image
    if [[ $CI_COMMIT_REF_NAME = master ]]; then
        echo $CI_REGISTRY_IMAGE/master:$CI_PIPELINE_ID
    elif [[ $CI_COMMIT_TAG ]]; then
        echo $CI_REGISTRY_IMAGE/tags:$CI_COMMIT_REF_NAME
    else
        echo $CI_REGISTRY_IMAGE/branches:$CI_COMMIT_REF_NAME
    fi
}

function getDockerIp() {
    if [[ $(isMacOS) == true ]];then
        echo $(ifconfig en0 | grep 'inet ' | cut -d' ' -f2)
    else
        echo $DOCKER_PORT | cut -d':' -f2 | tr -d '\/\/'
    fi
}

# function getCluster() {
#     if  [ -z "$ENVIRONMENT" ] || [ $IS_REVIEW = true ];then
#         echo qa
#     else
#         echo $(toLowerCase $(echo $ENVIRONMENT | cut -d "-" -f1))
#     fi
# }

function getCluster() {
    if  [[ "$CLUSTER" = review/dev* ]];then
        echo dev
    elif  [[ "$CLUSTER" = review/qa* ]];then
        echo qa
    else
        echo $(toLowerCase $(echo $CLUSTER | cut -d "-" -f1))
    fi
}

# function getEnvironment() {
#     if [ $IS_REVIEW = true ];then
#         echo sandbox
#     else
#         echo $(toLowerCase $(echo $ENVIRONMENT | cut -s -d "-" -f2))
#     fi
# }

function getEnvironment() {
    if [ $IS_REVIEW = true ];then
        echo sandbox
    else
        echo $(toLowerCase $(echo $ENVIRONMENT | cut -s -d "-" -f2))
    fi
}

function getDockerUri() {
  if  [[ "$CLUSTER" = prd ]];then
    echo https://s3.eu-central-1.amazonaws.com/zooz-marathon-assets-prod/docker.tar.gz
  else
    echo https://s3.eu-central-1.amazonaws.com/zooz-marathon-assets/docker.tar.gz
  fi
}

function getServicesDcosUrlGeneral() {
    if [[ $(isMacOS) == true ]];then
        dcos=dcos
    else
        dcos=dcos-internal
    fi
    dev=$dcos.dev-fra-apps.zooz.co
    qa=$dcos.qa-fra-apps.zooz.co
    mars=$dcos.mars-fra-apps.zooz.co
    prd=dcos-internal.prd-fra-apps.zooz.co
    prd_pci=dcos-internal.prd-fra-apps-pci.zooz.co

    echo $(eval echo \"\$$(getCluster)\")
}

# function getAppDcosUrl() {
#     getServicesDcosUrlGeneral

#     if [ $IS_REVIEW = true ];then
#         echo $qa
#     else
#         echo $(eval echo \"\$$CLUSTER\")
#     fi
# }

function getAppDcosUrl() {
    echo $(getServicesDcosUrlGeneral)
}

function getServicesDcosUrl() {
    echo $(getServicesDcosUrlGeneral)
}

function getServicesDcosUrlInternal() {
    echo $(getServicesDcosUrl) | sed 's|dcos|dcos-internal|'
}

function reportEnvVars() {
    echo "************************************************"
    echo "*        Loading common variables"
    echo "************************************************"
    echo APP_NAME=$APP_NAME
    echo BRANCH_NAME=$BRANCH_NAME
    echo BUILD=$BUILD
    echo APP_IMAGE=$APP_IMAGE
    echo DOCKER_IP=$DOCKER_IP
    echo CLUSTER=$CLUSTER
    echo ENV=$ENV
    echo IS_REVIEW=$IS_REVIEW
    echo ENVIRONMENT=$ENVIRONMENT
}

function loadCustomScripts() {
    echo "************************************************"
    echo "*        Loading custom scripts"
    echo "************************************************"
    for file in $(find "config/custom" -type f);do
        source $file
    done
}

function loadServices() {
    echo "************************************************"
    echo "*        Loading services related variables"
    echo "************************************************"
    for file in $(find "config/services" -type f);do
        source $file
    done
}

function loadClusterVars() {
    echo "************************************************"
    echo "*        Loading cluster specific variables"
    echo "************************************************"
    
    if [ -f config/env/$ENVIRONMENT/$CI_JOB_STAGE.sh ];then
        source config/env/$ENVIRONMENT/$CI_JOB_STAGE.sh
    fi
}

function toLowerCase() {
    echo $(echo $1 | tr '[:upper:]' '[:lower:]')
}

function isLocalApp() {
    if [[ $(isMacOS) == true ]];then
        echo "MacOS machine detected. Should I use local application address for tests? (Y/n)"
        read ANS
        [ "$ANS" != "n" ] && export LOCAL_APP=true || export LOCAL_APP=false
    fi
}

setLocalEnvVars
loadCustomScripts
setCommonEnvVars
loadClusterVars
loadServices
source config/helpers/marathon.sh