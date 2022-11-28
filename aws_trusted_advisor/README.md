# aws_trusted_advisor

getFlaggedResources.sh - This script is used to get all the resources flagged by Trusted Advisor 

## About AWS Trusted Advisor
Trusted Advisor draws upon best practices learned from serving hundreds of thousands of AWS customers. Trusted Advisor inspects your AWS environment, and then makes recommendations when opportunities exist to save money, improve system availability and performance, or help close security gaps.

### Commands
You will need to set "AWS_PROFILE" environment variable and configure AWS Credentials to create ~/.aws/credentials file. These credentials are used by script to work with AWS services 

Install awscli
```
python3 -m venv .env
source .env/bin/activate
pip3 install -r requirements.txt
```

Execute the script
```
chmod +x getFlaggedResources.sh
./getFlaggedResources.sh
```

### Additional Commands
#### Get only Ids
```
aws support describe-trusted-advisor-checks --language "en" | grep '"id":' | cut -d':' -f2 | tr -d ', ' | tr '\n' ' '
```

#### Workaround for S3 bucket flagged resources
List of Check-Id - https://aws.amazon.com/premiumsupport/ta-iam/

The following commands returns all the resources - even with status == ok and green.
> aws support describe-trusted-advisor-check-result --check-id R365s2Qddf --query 'result.sort_by(flaggedResources[?status!="ok"],&metadata[1])[].metadata' --output table

Hence, use the following command to show only those resources which are marked "Yellow"
```
aws support describe-trusted-advisor-check-result --check-id <id> --query 'result.sort_by(flaggedResources[?status!="ok"],&metadata[1])[].metadata' --output table | grep "Yellow"

e.g aws support describe-trusted-advisor-check-result --check-id R365s2Qddf --query 'result.sort_by(flaggedResources[?status!="ok"],&metadata[1])[].metadata' --output table | grep "Yellow"
```
