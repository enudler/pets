const env = require('../env');
const envString = Object.keys(env).map(key => `-e ${key}`);
console.info(envString.join(' '));