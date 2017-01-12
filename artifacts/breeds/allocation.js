'use strict';

let _ = require('highland');
let vamp = require('vamp-node-client');

let api = new vamp.Api();
let logger = new vamp.Log();

function publish(deployment, allocation) {
  logger.log('allocation for [' + deployment.name + ']: ' + JSON.stringify(allocation));
  api.event(['allocation', 'deployments:' + deployment.name], allocation, 'allocation');
}

api.deployments().each(function (deployment) {
  let allocation = {cpu: 0, memory: 0, instances: 0};
  for (let name in deployment.clusters) {
    if (deployment.clusters.hasOwnProperty(name)) {
      _(deployment.clusters[name].services).each(function (service) {
        let scale = service.scale;
        allocation.instances += scale.instances;
        allocation.cpu += scale.instances * scale.cpu;
        allocation.memory += scale.instances * parseInt(scale.memory, 10);
      });
    }
  }
  publish(deployment, allocation);
});
