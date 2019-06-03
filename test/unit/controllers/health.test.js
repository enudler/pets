const sinon = require('sinon');
const httpMock = require('node-mocks-http');

const { health } = require('../../../src/controllers/health');
const logger = require('../../../src/service/logger');
const { BUILD } = require('../../../config/env');

describe('health check', function() {
    const sandbox = sinon.createSandbox();
    const { req, res } = httpMock.createMocks();
    const next = sandbox.stub();

    beforeEach(function() {
        res.json = sandbox.stub();
        res.status = sandbox.stub();
        sandbox.stub(logger, 'error');
    });
    afterEach(function(){
        sandbox.restore();
    });

    it('should return healthy app', function() {
        health(req, res, next);

        sinon.assert.calledOnce(res.json);
        sinon.assert.calledWithMatch(res.json, { status: 'UP', build: BUILD });
    });
});