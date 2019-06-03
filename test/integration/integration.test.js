const supertest = require('supertest');
const should = require('should');

const app = require('../../src/app');

describe('Integration test', function() {
    let testApp;

    before(async function () {
        testApp = await app();
    });

    describe('/some-path', function() {
        it('should return 200', async function() {
            const response = await supertest(testApp).get('/some-path');
            should(response.status).eql(200);
        });
    });
});