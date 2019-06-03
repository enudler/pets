const bunyan = require('bunyan');

const { APP_NAME, CLUSTER, BUILD, LOG_LEVEL } = require('../../config/env');

module.exports = bunyan.createLogger({
    name: APP_NAME || 'test',
    cluster: CLUSTER,
    build: BUILD,
    level: LOG_LEVEL
});