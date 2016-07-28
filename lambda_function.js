var aws = require('aws-sdk');
var ecs = new aws.ECS({apiVersion: '2014-11-13'});

exports.handler = function(event, context) {
  console.log('Recieved event:');
  console.log(JSON.stringify(event, null, ' '));

  var params = {
    taskDefinition: 's3-repo-sync',
    cluster: 'default',
    count: 1,
    startedBy: 'lambda'
  };
  ecs.runTask(params, function(err, data) {
    if (err) console.log(err, err.stack);
    else     console.log(data);
  });
};
