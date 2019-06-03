const _app = require('./app');
const shutdownHandler = require('./service/shutdown');
const logger = require('./service/logger');
const port = process.env.PORT || 3000;

_app().then(app => {
    const server = app.listen(port, function () {
        logger.info(`App listening on port ${port}...`);
    });

    shutdownHandler(server);

    process.on('uncaughtException', function (reason) {
        logger.error('Possibly Uncaught Exception at: ', reason);
    });

    process.on('unhandledRejection', function (reason, p) {
        logger.error('Possibly Unhandled Rejection at: Promise ', p, ' reason: ', reason);
    });
}).catch(e => {
    logger.error(e, 'Application failed to initialize');
    process.exit(1);
});