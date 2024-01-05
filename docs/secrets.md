# Secrets

This library helps handling secrets.

Available methods:
- [get_secrets_manager_value](#get_secrets_manager_value)

<a name="get_secrets_manager_value"></a>

## get_secrets_manager_value

Retrieves an AWS Secret Manager secret.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|SECRET_ID|The secret ID.|N/A|yes|
|REGION|The secret's AWS region.|N/A|yes|
|VERSION_STAGE|Which version stage to retrieve.|AWSCURRENT|no|

### Outputs

The variable `___SECRET_VALUE` will be filled with the secret value.

### Example

```
# Key/value secret type
get_secrets_manager_value some-json-secret-id sa-east-1
SECRET_FIELD_1=$(echo $___SECRET_VALUE | jq --raw-output '.SECRET_FIELD_1')
SECRET_FIELD_2=$(echo $___SECRET_VALUE | jq --raw-output '.SECRET_FIELD_2')
echo "SECRET_FIELD_1 is $SECRET_FIELD_1"
echo "SECRET_FIELD_2 is $SECRET_FIELD_2"

# plaintext secret type
get_secrets_manager_value some-plaintext-secret-id sa-east-1
echo "The secret is $___SECRET_VALUE"
```
