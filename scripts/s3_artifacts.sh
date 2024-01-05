set -eo pipefail

source "$__BUILD_TOOLS_PATH/scripts/log.sh"

up_artifact_to_s3() {
__APP_NAME=$1
__ARTIFACT=$2
__COMMIT_HASH=$3
__ARTIFACT_EXT=${__ARTIFACT##*.}

aws s3 cp "$__ARTIFACT" s3://levalves-artifacts/"$__APP_NAME"/"$__APP_NAME"-"$__COMMIT_HASH"."$__ARTIFACT_EXT" --region us-east-1 --only-show-errors

}

rm_s3_artifact() {
__APP_NAME=$1
__ARTIFACT=$2
__COMMIT_HASH=$3
__ARTIFACT_EXT=${__ARTIFACT##*.}

aws s3 rm s3://levalves-artifacts/"$__APP_NAME"/"$__APP_NAME"-"$__COMMIT_HASH"."$__ARTIFACT_EXT" --region us-east-1 --only-show-errors

}