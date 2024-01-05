# Terraform

This library helps working with Terraform to stand up AWS infrastructure as code.

Available methods:
- [terraform_init](#terraform_init)
- [terraform_testplan](#terraform_testplan)
- [terraform_plan](#terraform_plan)
- [terraform_apply](#terraform_apply)
- [terraform_destroy_testplan](#terraform_destroy_testplan)
- [terraform_destroy_plan](#terraform_destroy_plan)
- [terraform_destroy](#terraform_destroy)
- [get_current_asg_desired_value](#get_current_asg_desired_value)

<a name="terraform_init"></a>

## terraform_init

Initializes Terraform.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|WORKSPACE|Terraform workspace to be created or used.|N/A|yes|
|TF_WORKING_DIR|Root path of the Terraform template files.|N/A|yes|
|BACKEND_CONFIG_PATH|Path to the file with the backend configuration|Will assume backend configuration is defined within the template files|no|

### Outputs

None.

### Example

```
terraform_init production deployment/terraform
```

<a name="terraform_testplan"></a>

## terraform_testplan

Initializes Terraform (if not already done) and runs the plan action.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|WORKSPACE|Terraform workspace to be created or used.|N/A|yes|
|TF_WORKING_DIR|Root path of the Terraform template files.|N/A|yes|

### Outputs

None.

### Example

```
terraform_testplan production deployment/terraform
```

<a name="terraform_plan"></a>

## terraform_plan

Initializes Terraform (if not already done) and creates an execution plan file.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|WORKSPACE|Terraform workspace to be created or used.|N/A|yes|
|TF_WORKING_DIR|Root path of the Terraform template files.|N/A|yes|
|COMMIT_HASH|Plan file unique identifier sufix.|N/A|yes|

### Outputs

- A plan file with the name pattern `tfplan-WORKSPACE-COMMIT_HASH` created on the `TF_WORKING_DIR`.
- A plan output file with the name pattern `tfplan-WORKSPACE-COMMIT_HASH.out` created on the `TF_WORKING_DIR`.

### Example

```
terraform_plan production deployment/terraform a5s3gr6
```

<a name="terraform_apply"></a>

## terraform_apply

Initializes Terraform (if not already done) and applies a previously created plan.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|WORKSPACE|Terraform workspace to be created or used.|N/A|yes|
|TF_WORKING_DIR|Root path of the Terraform template files.|N/A|yes|
|COMMIT_HASH|Plan file unique identifier sufix.|N/A|yes|
|POST_APPLY_FN|A function to be invoked after a successful apply.|N/A|no|

### Outputs

None.

### Example

```
post_apply() {
  terraform output
}
terraform_apply production deployment/terraform a5s3gr6 post_apply
```

<a name="terraform_destroy_testplan"></a>

## terraform_destroy_testplan

Initializes Terraform (if not already done) and runs the plan action (to destroy the infrastructure).

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|WORKSPACE|Terraform workspace to be created or used.|N/A|yes|
|TF_WORKING_DIR|Root path of the Terraform template files.|N/A|yes|

### Outputs

None.

### Example

```
terraform_destroy_testplan production deployment/terraform
```

<a name="terraform_destroy_plan"></a>

## terraform_destroy_plan

Initializes Terraform (if not already done) and creates an execution plan file to destroy the infrastructure.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|WORKSPACE|Terraform workspace to be created or used.|N/A|yes|
|TF_WORKING_DIR|Root path of the Terraform template files.|N/A|yes|
|COMMIT_HASH|Plan file unique identifier sufix.|N/A|yes|

### Outputs

- A plan file with the name pattern `tfplan-WORKSPACE-destroy-COMMIT_HASH` created on the `TF_WORKING_DIR`.
- A plan output file with the name pattern `tfplan-WORKSPACE-destroy-COMMIT_HASH.out` created on the `TF_WORKING_DIR`.

### Example

```
terraform_destroy_plan production deployment/terraform a5s3gr6
```

<a name="terraform_destroy"></a>

## terraform_destroy

Initializes Terraform (if not already done) and applies a previously created plan to destroy the infrastructure.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|WORKSPACE|Terraform workspace to be created or used.|N/A|yes|
|TF_WORKING_DIR|Root path of the Terraform template files.|N/A|yes|
|COMMIT_HASH|Plan file unique identifier sufix.|N/A|yes|
|POST_APPLY_FN|A function to be invoked after a successful apply.|N/A|no|

### Outputs

None.

### Example

```
post_destroy() {
  echo "Infrastructure destroyed"
}
terraform_destroy production deployment/terraform a5s3gr6 post_destroy
```

<a name="get_current_asg_desired_value"></a>

## get_current_asg_desired_value

Inspects an Auto Scaling Group to retrieve it's current desired value. This is used to keep the existing desired value during a new deployment on applications that have auto scaling enabled.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|WORKSPACE|Terraform workspace to be created or used.|N/A|yes|
|TF_WORKING_DIR|Root path of the Terraform template files.|N/A|yes|
|REGION|The ASG's AWS region.|N/A|yes|
|F_GET_ASG_NAME|A function to be invoked to return the Auto Scaling Group name.|N/A|yes|

### Outputs

The variable `___ASG_DESIRED` will be filled with the retrieved value.

### Example

```
get_asg_name() {
  echo "$(terraform output asg_name)"
}
get_current_asg_desired_value production deployment/terraform sa-east-1 get_asg_name
echo $___ASG_DESIRED
```
