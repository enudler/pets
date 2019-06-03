const expressLogger = require('express-requests-logger');

const logger = require('../service/logger');

module.exports = expressLogger({
    logger: logger.child({type: 'northbound'}),
    excludeURLs: ['health', 'metrics'],
    prepFunc: (req, res) => {
        req.additionalAudit = {
            x_zooz_request_id: req.headers['x-zooz-request-id']
        };
    }
});