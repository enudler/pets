const { BUILD } = require('../../config/env');

module.exports.health = (req, res, next) => {
    return res.json({
        status: 'UP',
        build: BUILD
    });
};