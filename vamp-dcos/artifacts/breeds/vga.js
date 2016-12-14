'use strict';

var _ = require('highland');
var http = require('request-promise');
var vamp = require('vamp-node-client');

var api = new vamp.Api();
var http = new vamp.Http();

api.config().each(function (config) {
  var mesos = config['vamp.container-driver.mesos.url'];
  var marathon = config['vamp.container-driver.marathon.url'];
  var zookeeper = config['vamp.persistence.key-value-store.zookeeper.servers'];
  var haproxy = config['vamp.gateway-driver.haproxy.version'];
  var logstash = config['vamp.gateway-driver.logstash.url'];

  _(http.get(mesos + '/master/slaves').then(JSON.parse)).each(function (response) {

    var instances = response.slaves.length;

    var vga = {
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
          "image": "magneticio/vamp-gateway-agent:katana",
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

    console.log('checking if deployed: /vamp/vamp-gateway-agent');

    _(http.get(marathon + '/v2/apps/vamp/vamp-gateway-agent').then(JSON.parse).catch(function () {
      return null;
    })).each(function (app) {

      if (app) {
        console.log('already deployed, checking number of instances...');
        console.log('deployed instances: ' + app.app.instances);
        console.log('expected instances: ' + instances);

        if (app.app.instances == instances) {
          console.log('done.');
          return;
        }
      }

      console.log('deploying...');

      http.request(marathon + '/v2/apps', {method: 'POST'}, JSON.stringify(vga)).then(function () {
        console.log('done.');
      }).catch(function (response) {
        console.log('error - ' + response.statusCode);
        return null;
      })
    });
  });
});
