const {
    APP_NAME,
    PORT = 3000,
    CLUSTER,
    BUILD,
    NEW_CONNECTIONS_TIMEOUT = 7500,
    SHUTDOWN_TIMEOUT = 10000,
    LOG_LEVEL = 'info',
    
} = process.env;

const env = {
    APP_NAME,
    PORT,
    CLUSTER,
    BUILD,
    NEW_CONNECTIONS_TIMEOUT,
    SHUTDOWN_TIMEOUT,
    LOG_LEVEL,
    
};

module.exports = env;

Object.assign(process.env, env);
