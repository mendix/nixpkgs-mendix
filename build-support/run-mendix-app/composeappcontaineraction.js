#!/usr/bin/env node

var fs = require('fs');

var config = JSON.parse(fs.readFileSync(process.argv[2]));
var result = {
  action: "update_appcontainer_configuration",
  params: config
};

console.log(JSON.stringify(result));
