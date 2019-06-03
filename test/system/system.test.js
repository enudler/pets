const should = require('should');

const { APP_URL } = process.env;
const apiRequest = require('../utils/apiRequest');

describe('System test', function() {
    describe('/some-path', function() {
        it('should return 200', async function() {
            const response = await apiRequest.get(`${APP_URL}/some-path`);
            should(response.statusCode).eql(200);
        });
    });

    it('should return 404 when endpoint not exists', async function() {
        await apiRequest.get(`${APP_URL}/not-found`)
            .should.be.rejected()
            .then(err => {
                const { statusCode, error } = err;
                should({ statusCode, error }).match({
                    statusCode: 404,
                    error: { details: ['Not Found'] }
                });
            });
    });
});