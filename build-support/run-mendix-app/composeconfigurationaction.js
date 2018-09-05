#!/usr/bin/env node

var fs = require('fs');
var path = require('path');

var config = JSON.parse(fs.readFileSync(process.argv[2]));
var constants = JSON.parse(fs.readFileSync(process.argv[3]));

// Augment BasePath and RuntimePath
config.BasePath = process.argv[4];
config.RuntimePath = process.argv[5];

// Extract the default constants and augment them with the provided constants
var metadata = JSON.parse(fs.readFileSync(path.join(config.BasePath, "model", "metadata.json")));
var microflowConstants = {};

if(Array.isArray(metadata.Constants)) {
    for(var i = 0; i < metadata.Constants.length; i++) {
        var constant = metadata.Constants[i];
        microflowConstants[constant.Name] = constant.DefaultValue;
    }
}

for(var key in constants) {
    microflowConstants[key] = constants[key];
}

config.MicroflowConstants = microflowConstants;

// Compose update configuration JSON message
var result = {
  action: "update_configuration",
  params: config
};

console.log(JSON.stringify(result));
