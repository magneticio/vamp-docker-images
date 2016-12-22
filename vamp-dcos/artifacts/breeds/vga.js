'use strict';

let _ = require('highland');
let vamp = require('vamp-node-client');

let api = new vamp.Api();
let http = new vamp.Http();
let logger = new vamp.Log();

api.config().each(function (config) {
  let mesos = config['vamp.container-driver.mesos.url'];
  let marathon = config['vamp.container-driver.marathon.url'];
  let zookeeper = config['vamp.persistence.key-value-store.zookeeper.servers'];
  let haproxy = config['vamp.gateway-driver.haproxy.version'];
  let logstash = config['vamp.gateway-driver.logstash.url'];

  _(http.get(mesos + '/master/slaves').then(JSON.parse)).each(function (response) {

    let instances = response.slaves.length;

    let vga = {
      "id": "/vamp/vamp-gateway-agent",
      "args": [
        "--storeType=zookeeper",
        "--storeConnection=" + zookeeper,
        "--storeKey=/vamp/gateways/haproxy/" + haproxy,
        "--logstash=" + logstash
      ],
      "cpus": 0.2,
      "mem": 256.0,
      "instances": instances,
      "acceptedResourceRoles": [
        "slave_public",
        "*"
      ],
      "container": {
        "type": "DOCKER",
        "docker": {
          "image": "magneticio/vamp-gateway-agent:0.9.2",
          "network": "HOST",
          "portMappings": [],
          "privileged": true,
          "parameters": []
        }
      },
      "env": {},
      "constraints": [
        ["hostname", "UNIQUE"]
      ],
      "labels": {}
    };

    logger.log('checking if deployed: /vamp/vamp-gateway-agent');

    _(http.get(marathon + '/v2/apps/vamp/vamp-gateway-agent').then(JSON.parse).catch(function () {
      return null;
    })).each(function (app) {

      if (app) {
        logger.log('already deployed, checking number of instances...');
        logger.log('deployed instances: ' + app.app.instances);
        logger.log('expected instances: ' + instances);

        if (app.app.instances == instances) {
          logger.log('done.');
          return;
        }
      }

      logger.log('deploying...');

      http.request(marathon + '/v2/apps', {method: 'POST'}, JSON.stringify(vga)).then(function () {
        logger.log('done.');
      }).catch(function (response) {
        logger.log('error - ' + response.statusCode);
        return null;
      })
    });
  });
});
