const logger = require('../service/logger');
const { NOT_FOUND, INTERNAL_SERVER_ERROR, getStatusText } = require('http-status-codes');
const INTERNAL_SERVER_ERROR_MESSAGE = getStatusText(INTERNAL_SERVER_ERROR);
const NOT_FOUND_ERROR_MESSAGE = getStatusText(NOT_FOUND);

module.exports.throwNotFoundError = function (req, res, next) {
    const response = buildResponse(NOT_FOUND, NOT_FOUND_ERROR_MESSAGE);
    res.status(response.statusCode);
    res.json(response.body);
};

module.exports.handleUnexpectedError = function(err, req, res, next) {
    logInternalServerError(err, req);
    const response = buildResponse(
        INTERNAL_SERVER_ERROR,
        INTERNAL_SERVER_ERROR_MESSAGE,
        err.stack.toString()
    );

    res.status(response.statusCode);
    res.json(response.body);
};

function logInternalServerError(error, req) {
    const context = req.ctx || {};

    context.error = {
        name: error.name,
        message: error.message,
        stack: error.stack.toString(),
        details: error.data
    };
    logger.error(context, error.message);
}

function buildResponse(statusCode, details, moreInfo) {
    return {
        statusCode,
        body: {
            details: [details],
            more_info: moreInfo
        }
    };
}