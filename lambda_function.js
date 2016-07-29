var aws = require('aws-sdk');
var ecs = new aws.ECS({apiVersion: '2014-11-13'});

exports.handler = function(event, context) {
    console.log('Recieved event:');
    console.log(JSON.stringify(event, null, ' '));

    var params = {
        taskDefinition: 'arn:aws:ecs:<aws_region>:<aws_account>:task-definition/s3-repo-sync',
        cluster: 'default',
        count: 1,
        overrides: {
            containerOverrides: [
                {
                    name: 's3-repo-sync',
                    environment: [
                        {
                            name: 'S3_BUCKET',
                            value: event.Records[0].s3.bucket.name
                        },
                        {
                            name: 'REGION',
                            value: event.Records[0].awsRegion
                        }
                    ]
                }
            ]
        },
        startedBy: 'lambda'
    };
    ecs.runTask(params, function(err, data) {
        if (err) console.warn(err, err.stack);
        else     console.info(data);
    });
};
