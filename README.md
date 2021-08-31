# salesforce-integration

Starter template for  Node.js AWS Lambda deployed using Terraform. Lambda creates a Salesforce contact using JsForce and then puts the contact object in AWS S3 bucket. 

## Setup

Install the following tools before getting started:

- [ ] [Node.js](https://nodejs.org/en/)
- [ ] [pnpm](https://pnpm.io/)
- [ ] [aws-cli](https://aws.amazon.com/cli/)
- [ ] [Terraform](https://www.terraform.io/)

## Initialize

You only have to do this once after cloning.

Initialize AWS credentials:

```shell
$ aws configure
```

Initialize Node.js workspace:

```shell
$ cd salesforce-integration
$ npm install
```

Initialize Terraform workspace:

```shell
$ cd iac
$ terraform init
```

Set Salesforce connection parameters in terraform.tfvars file:
```shell
CLIENT_ID = ""
CLIENT_SECRET =""
USERNAME = ""
PASSWORD =  ""
REDIRECT_URL = ""
```

## Deploy

Use the shell script to create the lambda package and deploy to AWS:

```shell
$ ./deploy.sh
```

## Test

Invoke the lambda from AWS Management Console.
You can use the below example payload:

```json
{ "Records" : [  {"key" : "key1"}, {"key" : "key2"} ]}
```

