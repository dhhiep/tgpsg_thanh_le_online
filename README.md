
# TGPSG Thánh Lễ trực tuyến Fetcher

This project is a API wrapper for Youtube channel **[TGPSG Thánh Lễ trực tuyến](https://www.youtube.com/channel/UCc7qu2cB-CzTt8CpWqLba-g)** to expose APIs:

| Method | Endpoint                      | Description                                                                                  |
| ------ | ----------------------------- | -------------------------------------------------------------------------------------------- |
| GET    | /api/masses                   | List of masses 1 month ago, includes: upcoming, live and streamed (with response caching)    |
| GET    | /api/masses?reload_cache=true | List of masses 1 month ago, includes: upcoming, live and streamed (without response caching) |

## I. Setup

#### 1. Copy `.env.template` to `.env` and update your keys.

*Note:* This is current my AWS User permissions. However, I'll double check least permission I need.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        // Permissions is required
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "apigateway:PUT",
        "apigateway:POST",
        "apigateway:GET",
        "apigateway:TagResource",

        // AWSCloudFormationFullAccess
        "cloudformation:*",

        // AmazonS3FullAccess
        "s3:*",

        // AWSLambdaFullAccess
        "cloudformation:DescribeChangeSet",
        "cloudformation:DescribeStackResources",
        "cloudformation:DescribeStacks",
        "cloudformation:GetTemplate",
        "cloudformation:ListStackResources",
        "cloudwatch:*",
        "cognito-identity:ListIdentityPools",
        "cognito-sync:GetCognitoEvents",
        "cognito-sync:SetCognitoEvents",
        "dynamodb:*",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "events:*",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:GetRole",
        "iam:GetRolePolicy",
        "iam:ListAttachedRolePolicies",
        "iam:ListRolePolicies",
        "iam:ListRoles",
        "iam:PassRole",
        "iot:AttachPrincipalPolicy",
        "iot:AttachThingPrincipal",
        "iot:CreateKeysAndCertificate",
        "iot:CreatePolicy",
        "iot:CreateThing",
        "iot:CreateTopicRule",
        "iot:DescribeEndpoint",
        "iot:GetTopicRule",
        "iot:ListPolicies",
        "iot:ListThings",
        "iot:ListTopicRules",
        "iot:ReplaceTopicRule",
        "kinesis:DescribeStream",
        "kinesis:ListStreams",
        "kinesis:PutRecord",
        "kms:ListAliases",
        "lambda:*",
        "logs:*",
        "s3:*",
        "sns:ListSubscriptions",
        "sns:ListSubscriptionsByTopic",
        "sns:ListTopics",
        "sns:Publish",
        "sns:Subscribe",
        "sns:Unsubscribe",
        "sqs:ListQueues",
        "sqs:SendMessage",
        "tag:GetResources",
        "xray:PutTelemetryRecords",
        "xray:PutTraceSegments"
      ],
      "Resource": "*"
    }
  ]
}
```

#### 2. Follow these steps to get started

```shell
$ ./bin/bootstrap
$ ./bin/setup
$ ./bin/test
```

To deploy your Lambda do the following. This command assumes you have the AWS CLI configured with credentials located within your `~/.aws` directory.

```shell
$ STAGE_ENV=live ./bin/deploy
```

To test it works within the AWS Console, you can either send it a test event (Services -> Lambda -> MYLAMBDA -> Test) or if you opted for a basic HTTP API, you can see your Invoke URL by navigating to (Services -> API Gateway -> MYAPI -> Invoke URL) page.

## II. CI/CD with GitHub Actions

In order for GitHub to deploy your Lambda, it will need permission to do so. An admin should do the first deploy, however afterward GitHub Actions can do updates for you.

#### Create a Deploy User

In the AWS Console -> IAM -> Users -> Add User.

* Check "Programmatic access" option.
* Select "Attach existing policies directly" option.
* Select "AWSLambdaFullAccess" policy.
* Copy the "Access key ID" and "Secret access key"

#### AWS Credentials

In your GitHub repo page. Click Settings -> Secrets -> Add a new secret

* Name `AWS_ACCESS_KEY_ID` value (from step above)
* Name `AWS_SECRET_ACCESS_KEY` value (from step above)
