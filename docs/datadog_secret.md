# Retrieve Datadog Secret

This library helps to retrieve Datadog's secret.

Available methods:
- [get_dd_secret](#get_dd_secret)

<a name="get_dd_secret"></a>

## get_dd_secret

Retrieves Datadog's secret from AWS Secrets Manager.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|ENV|Application environment|N/A|yes|
|REGION|The secret's AWS region.|N/A|yes|

### Outputs

The variables `___DD_API_KEY` and `___DD_AGENT_VERSION` will be filled with the secret value.

### Example:

```
get_dd_secret staging sa-east-1
export DD_API_KEY=$___DD_API_KEY
export DD_AGENT_VERSION=$___DD_AGENT_VERSION
```
