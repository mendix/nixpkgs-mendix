#!/usr/bin/env node

var fs = require('fs');

var config = JSON.parse(fs.readFileSync(process.argv[2]));

// Augment BasePath and RuntimePath
config.BasePath = process.argv[3];
config.RuntimePath = process.argv[4];

var result = {
  action: "update_configuration",
  params: config
};

console.log(JSON.stringify(result));
