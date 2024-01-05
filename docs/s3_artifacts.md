# S3 Artifacts

This library handles artifacts at levalves-artifacts S3 bucket.

Available methods:
- [up_artifact_to_s3](#up_artifact_to_s3)
<a name="up_artifact_to_s3"></a>
- [rm_s3_artifact](#rm_s3_artifact)
<a name="rm_s3_artifact"></a>

## up_artifact_to_s3

Uploads an artifact to levalves-artifacts S3 bucket.

Artifacts are renamed to be stored in a ordered way that can be used by automation scripts to install them, as follows:

s3://levalves-artifacts/APP_NAME/APP_NAME-ENV-COMMIT_HASH

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|APP_NAME|Application name.|N/A|yes|
|ARTIFACT|Complete artifact name.|N/A|yes|
|COMMIT_HASH|Unique identifier sufix.|N/A|yes|

### Outputs

None.

### Example

```bash
f_up_app() {
  COMMIT_HASH=56bff87
  APP_NAME=dummy-app
  ARTIFACT_NAME=customerCode-dummy-app.jar
  up_artifact_to_s3 $APP_NAME ../build/libs/$ARTIFACT_NAME $COMMIT_HASH
}
```

## rm_s3_artifact

Removes an artifact previously uploaded by `up_artifact_to_s3` function from levalves-artifacts S3 bucket.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|APP_NAME|Application name.|N/A|yes|
|ARTIFACT|Complete artifact name.|N/A|yes|
|COMMIT_HASH|Unique identifier sufix.|N/A|yes|

### Outputs

None.

### Example

```bash
rm_artifact() {
  COMMIT_HASH=56bff87
  APP_NAME=dummy-app
  ARTIFACT_NAME=customerCode-dummy-app.jar
  rm_s3_artifact $APP_NAME $ARTIFACT_NAME $COMMIT_HASH
}
```
