# Docker

This library helps building and pushing Docker Images to the ECR service on AWS.

Available methods:
- [build_image](#build_image)
- [push_image](#push_image)

<a name="build_image"></a>

## build_image

Builds a Docker Image.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|DOCKER_FILE_PATH|Path to the Dockerfile with the image specification|N/A|yes|
|TAG|The tag to be applied on the built image.|N/A|yes|
|REGION|The region to be applied on the built image.|N/A|yes|
|ARG|The argument to be applied on the built image.|N/A|no|

### Outputs

None.

### Example

```

REPO_NAME="327667905059.dkr.ecr.us-east-1.amazonaws.com/my-repo"
REGION=$(find . -iname "$ENV.tfvars" | xargs -I {} cat {} | grep -e ^region | cut -d \= -f2 | sed 's/ "//g;s/"//g')
IMAGE_TAG="$REPO_NAME:staging-3h6ddf6"
build_image ./Deckerfile $IMAGE_TAG $REGION "REGION=$REGION ENVIRONMENT=staging"
```

<a name="push_image"></a>

## push_image

Pushes an image to an ECR repository.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|TAG|The tag to be pushed.|N/A|yes|
|REGION| 
The region where the image will be pushed.
|N/A|yes|


### Outputs

None.

### Example

```
REPO_NAME="327667905059.dkr.ecr.$REGION.amazonaws.com/my-repo"
IMAGE_TAG="$REPO_NAME:$COMMIT_HASH"
push_image $IMAGE_TAG $REGION
```
