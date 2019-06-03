const { registerShutdownEvent } = require('graceful-shutdown-express');

const logger = require('../service/logger');
const { NEW_CONNECTIONS_TIMEOUT, SHUTDOWN_TIMEOUT } = require('../../config/env');

module.exports = function registerShutdown(server) {
    registerShutdownEvent({
        server,
        newConnectionsTimeout: NEW_CONNECTIONS_TIMEOUT,
        shutdownTimeout: SHUTDOWN_TIMEOUT,
        events: ['SIGINT', 'SIGTERM'],
        logger
    });
};