if [[ "$CLUSTER" == "prd" ]];then
    export EXTERNAL_API_URL=https://api.paymentsos.com
else
    export EXTERNAL_API_URL=https://api-${CLUSTER}.paymentsos.com
fi

echo EXTERNAL_API_URL=$EXTERNAL_API_URL