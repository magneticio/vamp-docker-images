
let delay = 0;

let failure = random();

if (failure > 0.5) {
  console.error('failed due to random event: ' + failure);
  process.exit(1)
}

let lines = log();

for (let i = 0; i < lines.length; i++) {
  setTimeout(function () {
    console.log(lines[i]);
  }, delay += 50);
}

function random() {
  let x = Math.sin(new Date().getTime()) * 10000;
  return x - Math.floor(x);
}

function log() {
  return [
    'API options: {"host":"http://192.168.99.100:8080","path":"/api/v1","headers":{"Accept":"application/json","Content-Type":"application/json"},"cache":true}',
    'API GET /gateways',
    'HTTP REQUEST [0] {"protocol":"http:","port":"8080","hostname":"192.168.99.100","method":"GET","headers":{"Accept":"application/json","Content-Type":"application/json"},"path":"/api/v1/gateways?page=1"}',
    'HTTP RESPONSE [0] 200',
    'API GET /config',
    'HTTP REQUEST [1] {"protocol":"http:","port":"8080","hostname":"192.168.99.100","method":"GET","headers":{"Accept":"application/json","Content-Type":"application/json"},"path":"/api/v1/config?page=1&flatten=true"}',
    'API GET /config [CACHED]',
    'API GET /config [CACHED]',
    'API GET /config [CACHED]',
    'HTTP REQUEST [2] {"protocol":"http:","port":"8080","hostname":"192.168.99.100","method":"GET","headers":{"Accept":"application/json","Content-Type":"application/json"},"path":"/api/v1/gateways?page=2"}',
    'HTTP RESPONSE [1] 200',
    'HTTP RESPONSE [2] 200',
    'ELASTICSEARCH AVERAGE {"term":{"ft":"4877cc92ae2ba1bbc96f0aea0572b725ce47d9fb"},"on":"Tt","seconds":30}',
    'HTTP REQUEST [0] {"protocol":"http:","port":"9200","hostname":"localhost","method":"POST","headers":{},"path":"/vamp-vga-*/log/_search"}',
    'ELASTICSEARCH AVERAGE {"term":{"ft":"b39db738817b6bdbab5cffbee23a235c1a3fc4b7"},"on":"Tt","seconds":30}',
    'HTTP REQUEST [1] {"protocol":"http:","port":"9200","hostname":"localhost","method":"POST","headers":{},"path":"/vamp-vga-*/log/_search"}',
    'ELASTICSEARCH AVERAGE {"term":{"ft":"c69c9130565094947cd78805f9c2e3ec74186907"},"on":"Tt","seconds":30}',
    'HTTP REQUEST [2] {"protocol":"http:","port":"9200","hostname":"localhost","method":"POST","headers":{},"path":"/vamp-vga-*/log/_search"}',
    'ELASTICSEARCH AVERAGE {"term":{"ft":"fef540f1c9e4eb21e045d935eac990d0d5d25825"},"on":"Tt","seconds":30}',
    'HTTP REQUEST [3] {"protocol":"http:","port":"9200","hostname":"localhost","method":"POST","headers":{},"path":"/vamp-vga-*/log/_search"}',
    'HTTP RESPONSE [1] 200',
    'metrics: [["gateways:sava/9050","routes:sava/sava/webport","route","metrics:rate"]] - 0',
    'API PUT /events {"tags":["gateways:sava/9050","routes:sava/sava/webport","route","metrics:rate"],"type":"metrics"}',
    'API POST /events',
    'HTTP REQUEST [3] {"protocol":"http:","port":"8080","hostname":"192.168.99.100","method":"POST","headers":{"Accept":"application/json","Content-Type":"application/json"},"path":"/api/v1/events"}',
    'metrics: [["gateways:sava/9050","routes:sava/sava/webport","route","metrics:responseTime"]] - 0',
    'API PUT /events {"tags":["gateways:sava/9050","routes:sava/sava/webport","route","metrics:responseTime"],"type":"metrics"}',
    'API POST /events',
    'HTTP REQUEST [4] {"protocol":"http:","port":"8080","hostname":"192.168.99.100","method":"POST","headers":{"Accept":"application/json","Content-Type":"application/json"},"path":"/api/v1/events"}',
    'HTTP RESPONSE [0] 200',
    'metrics: [["gateways:sava/9050","gateway","metrics:rate"]] - 0',
    'API PUT /events {"tags":["gateways:sava/9050","gateway","metrics:rate"],"type":"metrics"}',
    'API POST /events',
    'HTTP REQUEST [5] {"protocol":"http:","port":"8080","hostname":"192.168.99.100","method":"POST","headers":{"Accept":"application/json","Content-Type":"application/json"},"path":"/api/v1/events"}',
    'metrics: [["gateways:sava/9050","gateway","metrics:responseTime"]] - 0',
    'API PUT /events {"tags":["gateways:sava/9050","gateway","metrics:responseTime"],"type":"metrics"}',
    'API POST /events',
    'HTTP REQUEST [6] {"protocol":"http:","port":"8080","hostname":"192.168.99.100","method":"POST","headers":{"Accept":"application/json","Content-Type":"application/json"},"path":"/api/v1/events"}',
    'HTTP RESPONSE [2] 200',
    'metrics: [["gateways:sava/sava/webport","gateway","metrics:rate"]] - 0',
    'API PUT /events {"tags":["gateways:sava/sava/webport","gateway","metrics:rate"],"type":"metrics"}',
    'API POST /events',
    'HTTP REQUEST [7] {"protocol":"http:","port":"8080","hostname":"192.168.99.100","method":"POST","headers":{"Accept":"application/json","Content-Type":"application/json"},"path":"/api/v1/events"}',
    'metrics: [["gateways:sava/sava/webport","gateway","metrics:responseTime"]] - 0',
    'API PUT /events {"tags":["gateways:sava/sava/webport","gateway","metrics:responseTime"],"type":"metrics"}',
    'API POST /events',
    'HTTP REQUEST [8] {"protocol":"http:","port":"8080","hostname":"192.168.99.100","method":"POST","headers":{"Accept":"application/json","Content-Type":"application/json"},"path":"/api/v1/events"}',
    'HTTP RESPONSE [3] 200',
    'metrics: [["gateways:sava/sava/webport","routes:sava/sava/sava:1.0.0/webport","route","metrics:rate"]] - 0',
    'API PUT /events {"tags":["gateways:sava/sava/webport","routes:sava/sava/sava:1.0.0/webport","route","metrics:rate"],"type":"metrics"}',
    'API POST /events',
    'HTTP REQUEST [9] {"protocol":"http:","port":"8080","hostname":"192.168.99.100","method":"POST","headers":{"Accept":"application/json","Content-Type":"application/json"},"path":"/api/v1/events"}',
    'metrics: [["gateways:sava/sava/webport","routes:sava/sava/sava:1.0.0/webport","route","metrics:responseTime"]] - 0',
    'API PUT /events {"tags":["gateways:sava/sava/webport","routes:sava/sava/sava:1.0.0/webport","route","metrics:responseTime"],"type":"metrics"}',
    'API POST /events',
    'HTTP REQUEST [10] {"protocol":"http:","port":"8080","hostname":"192.168.99.100","method":"POST","headers":{"Accept":"application/json","Content-Type":"application/json"},"path":"/api/v1/events"}',
    'HTTP RESPONSE [5] 201',
    'HTTP RESPONSE [9] 201',
    'HTTP RESPONSE [10] 201',
    'HTTP RESPONSE [4] 201',
    'HTTP RESPONSE [3] 201',
    'HTTP RESPONSE [7] 201',
    'HTTP RESPONSE [6] 201',
    'HTTP RESPONSE [8] 201'
  ];
}