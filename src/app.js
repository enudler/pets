const express = require('express');
const bodyParser = require('body-parser');
const uuid = require('uuid/v4');
const requestLogger = require('./middlewares/logger');
const { health } = require('./controllers/health');
const { handleUnexpectedError, throwNotFoundError } = require('./middlewares/errorHandler');
const { init } = require('./initialization/init');

module.exports = async () => {
    await init();

    const app = express();

    // common middlewares
    app.disable('x-powered-by');
    app.use(bodyParser.json());
    app.use(requestLogger);

    // routers
    app.get('/pets/:id', (req, res) => {
        return res.status(200).json()
    });
    app.post('/pets', (req, res) => {
        return res.status(201).json({id: uuid()})
    });

    app.get('/some-path', (req, res) => res.status(200).json());

    // error handler
    app.use(throwNotFoundError);
    app.use(handleUnexpectedError);
    return app;
};
