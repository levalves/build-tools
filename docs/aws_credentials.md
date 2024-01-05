# AWS Credentials

This lib allow setup of multiple AWS accounts during build process.

Available methods:

- [set_aws_credentials](#set_aws_credentials)
- [reset_aws_credentials](#reset_aws_credentials)

<a name="set_aws_credentials"></a>

## set_aws_credentials

Set AWS account via assume role method.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|ROLE|AWS role ARN.|N/A|yes|
|AUTOMATION_USER|CI/CD user.|jenkins|no|
|APP_NAME|Application name. Sets the `role-session-name` prefix of the call.|AUTOMATION_USER|no|
|COMMIT_HASH|Application version. Sets the `role-session-name` suffix of the call.|AAAA-mm-dd-HH-MM-SS|no|

### Outputs

None.

### Example

```bash
__BUILD_TOOLS_PATH="./build-tools"
source "$__BUILD_TOOLS_PATH/scripts/aws_credentials.sh"

# SET AUTOMATION USER
AUTOMATION_USER="jenkins"

# SET COMMIT_HASH
COMMIT_HASH="${COMMIT_HASH:-$(git log --pretty=format:%h -n 1)}"

# AWS SETUP
if [ "$ENV" == "stg" ]; then
  ROLE="arn:aws:iam::000000000001:role/Account-Name_NonProd"
  AWS_ACCOUNT="000000000001"
else
  ROLE="arn:aws:iam::000000000002:role/Account-Name_Prod"
  AWS_ACCOUNT="000000000002"
fi

# SET AWS CREDENTIALS
set_aws_credentials $ROLE $AUTOMATION_USER $APP_NAME $COMMIT_HASH

```

<a name="reset_aws_credentials"></a>

## reset_aws_credentials

Resets AWS credentials to prior `set_aws_credentials` utilization.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|AUTOMATION_USER|Usuário utilizado na ferramenta de automação|jenkins|no|

### Outputs

None.

### Example

```bash
__BUILD_TOOLS_PATH="./build-tools"
source "$__BUILD_TOOLS_PATH/scripts/aws_credentials.sh"

# SET AUTOMATION USER
AUTOMATION_USER="jenkins"

source "$__BUILD_TOOLS_PATH/scripts/aws_credentials.sh"
reset_aws_credentials $AUTOMATION_USER
```
