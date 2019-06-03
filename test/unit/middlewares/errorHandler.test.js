const sinon = require('sinon');
const httpMock = require('node-mocks-http');

const { throwNotFoundError, handleUnexpectedError } = require('../../../src/middlewares/errorHandler');
const logger = require('../../../src/service/logger');

describe('error handler', function() {
    const sandbox = sinon.createSandbox();
    const { req, res } = httpMock.createMocks({ headers: { 'x-zooz-request-id': 'request-id' } });
    const next = sandbox.stub();

    beforeEach(function() {
        res.json = sandbox.stub();
        res.status = sandbox.stub();
        sandbox.stub(logger, 'error');
    });
    afterEach(function(){
        sandbox.restore();
    });

    describe('handle not found error', function() {
        it('should return not found error', function() {
            const { status, json } = res;

            throwNotFoundError(req, res, next);
            sinon.assert.calledOnce(status);
            sinon.assert.calledWithMatch(status, 404);
            sinon.assert.calledOnce(json);
            sinon.assert.calledWithMatch(json, {
                details: ['Not Found'],
                more_info: undefined
            });
        });
    });

    describe('handle unexpected error', function() {
        it('should return internal server error', function() {
            const { status, json } = res;
            const err = new Error('some error');

            handleUnexpectedError(err, req, res, next);
            sinon.assert.calledOnce(status);
            sinon.assert.calledWithMatch(status, 500);
            sinon.assert.calledOnce(json);
            sinon.assert.calledWithMatch(json, {
                details: ['Server Error'],
                more_info: err.stack
            });
        });
    });
});