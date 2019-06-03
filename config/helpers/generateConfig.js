const {INSTANCES, CPU, MEM, SERVICE_ID, APP_IMAGE, DOCKER_URI, HEALTH_PATH, CI_COMMIT_TAG, CI_BUILD_REF_NAME, VAULT_APP_ID} = process.env;
const serviceEnv = require('../env');
const FORCE_FETCH = CI_BUILD_REF_NAME !== 'master' && !CI_COMMIT_TAG;

delete serviceEnv.PORT;
Object.keys(serviceEnv).forEach(key => {
    if (!isNaN(serviceEnv[key])) {
        // Covert numeric env variables to strings
        serviceEnv[key] = serviceEnv[key].toString();
    }
});

serviceEnv.DEPLOY_TIME = new Date().toISOString();

function generate() {
    console.log(JSON.stringify({
        volumes: null,
        id: SERVICE_ID,
        constraints: [['hostname', 'UNIQUE']],
        cmd: null,
        args: null,
        user: null,
        env: serviceEnv,
        instances: Number(INSTANCES) || 1,
        cpus: Number(CPU) || 0.5,
        mem: Number(MEM) || 512,
        disk: 0,
        gpus: 0,
        executor: null,
        fetch: [
            {
                uri: DOCKER_URI
            }
        ],
        backoffSeconds: 1,
        backoffFactor: 1.15,
        maxLaunchDelaySeconds: 3600,
        container: {
            docker: {
                image: APP_IMAGE,
                forcePullImage: FORCE_FETCH,
                privileged: false,
                network: 'HOST',
                parameters: [
                    {
                        key: 'log-opt=max-size',
                        value: '10m'
                    },
                    {
                        key: 'log-opt=max-file',
                        value: '5'
                    }
                ]
            }
        },
        healthChecks: [
            {
                protocol: 'HTTP',
                path: HEALTH_PATH,
                gracePeriodSeconds: 60,
                intervalSeconds: 10,
                timeoutSeconds: 30,
                maxConsecutiveFailures: 3,
                ignoreHttp1xx: false
            }
        ],
        readinessChecks: null,
        dependencies: null,
        upgradeStrategy: {
            minimumHealthCapacity: 1,
            maximumOverCapacity: 0
        },
        labels: {
            VAULT_APP_ID: VAULT_APP_ID
        },
        acceptedResourceRoles: null,
        residency: null,
        secrets: null,
        taskKillGracePeriodSeconds: null,
        portDefinitions: [
            {
                protocol: 'tcp',
                port: 10129
            }
        ],
        requirePorts: false
    }));
}

module.exports = {
    generate
};

generate();