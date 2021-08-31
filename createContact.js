const AWS = require('aws-sdk');
const fetch = require('node-fetch');
var jsforce = require('jsforce');

//for running locally
//main({ "Records" : [  {"key" : "key1"}, {"key" : "key2"} ]});
exports.handler = async function main(event) {
    var topics = []
    event.Records.forEach(record => {
        const { key  } = record;
        topics.push(key);
    });
    
    const conn = new jsforce.Connection({});
    
    //login to Salesforce instance
    const user = await conn.login(process.env.USERNAME, process.env.PASSWORD);
    
    //Print connection details
    console.log(user);
    console.log(conn.accessToken);
    console.log(conn.instanceUrl);
    
    console.log("creating contact in salesforce... ");
    // create Contact in Salesforce
    for (const contact of topics) {  
        const output= await conn.sobject("Contact").create({"LastName": contact});
        console.log("salesforce response: " + output);
    }

    
    console.log("Put the object in S3 bucket... ");
 
    //publish the contact in S3 bucket
    try{
        const s3bucket = new AWS.S3({region: 'us-east-1'});
        const params = {
            Bucket: "create-contact-bucket",
            Key:   topics[0] + "-" + topics[1],
            Body:  '{"message" :  "the ticket is raised via users"}',
            ContentType: "application/json",
        };

        const result = await s3bucket.putObject(params).promise();
        console.log("File uploaded successfully");
    }
    catch(error) {
        console.log("File uploaded fails" + error );
        return "File Uploaded fails";
    }

    return "It might take upto 5 minutes for the reocrd(s) to be fully uploaded"
}