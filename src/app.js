const express = require('express');
const bodyParser = require('body-parser');
const uuid = require('uuid/v4');
const requestLogger = require('./middlewares/logger');
const { health } = require('./controllers/health');
const { handleUnexpectedError, throwNotFoundError } = require('./middlewares/errorHandler');
const { init } = require('./initialization/init');
const products = require('./service/petsProducts');
const orders = require('./service/orders');

let tokenId = 'd62c3cd2-e8d0-4299-901f-cadce0f77529';
module.exports = async () => {
    await init();

    const app = express();

    // common middlewares
    app.disable('x-powered-by');
    app.use(bodyParser.json());
    app.use(requestLogger);

    // routers
    app.get('/products', (req, res) => {
        return res.status(200).json(products);
    });
    app.post('/orders', (req, res) => {
        if (req.headers['response-status'] === '500') {
            return res.status(500).json({ error: 'Internal error' });
        }  else {
            let randomOrder = orders.orders[getRandomInt(orders.orders.length - 1)].order_id;
            return res.status(201).json({ order_id: randomOrder });
        }
    });

    app.get('/orders', (req, res) => {
        return res.status(200).json(orders);
    });

    app.get('/orders/:id', (req, res) => {
        let orderDetails = orders.orders.filter(function(order) {
            return order.order_id === req.params.id;
        });
        return res.status(200).json(orderDetails);
    });

    app.patch('/products/:id', (req, res) => {
        if (req.headers.token_id === tokenId) {
            return res.status(201).json({ product_id: req.params.id, quantity: getRandomInt(200) });
        } else {
            return res.status(401).json({ error: 'Unauthorized' });
        }
    });

    app.post('/products', (req, res) => {
        if (req.headers.token_id === tokenId) {
            return res.status(201).json({ product_id: uuid() });
        } else {
            return res.status(401).json({ error: 'Unauthorized' });
        }
    });

    app.post('/login', (req, res) => {
        if (req.body.user && req.body.password) {
            return res.status(201).json({ token: tokenId });
        } else {
            return res.status(400).json({ error: '"user" or "password" are missing' });
        }
    });

    // error handler
    app.use(throwNotFoundError);
    app.use(handleUnexpectedError);
    return app;
};

function getRandomInt(max) {
    return Math.floor(Math.random() * Math.floor(max));
}
