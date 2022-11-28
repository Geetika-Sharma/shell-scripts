# delete_all_versions_lambda

delete_all_versions_lambda.sh - This script deletes all the versions except the $LATEST of the versioned Lambda Functions. 

The objective is to free storage as each function version and layer version consumes storage. Default storage for uploaded functions (.zip file archives) and layers is 75 GB only.

### Prerequisite
1. You will need to set "AWS_PROFILE" environment variable and configure AWS Credentials to create ~/.aws/credentials file. These credentials are used by script to work with AWS services


2. You will also need to set "AWS_REGION" environment variable. This variable will be used to locate the functions in the specified region
```
export AWS_REGION=<region with versioned staging functions>

e.g export AWS_REGION=eu-west-1  
```

### Usage
The script is dynamic and can be used to delete the versions of the functions of different environments (dev/stg/prd). For now, this script will allow only to delete the functions of the **staging** environment. 

Execute the following command:

```
./delete_all_versions_lambda.sh <Environment name> (Allowed values - stg|staging)

e.g ./delete_all_versions_lambda.sh stg
```