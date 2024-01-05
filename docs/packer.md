# Packer

This library helps creating AWS AMIs using Packer.

Available methods:
- [build_ami](#build_ami)

<a name="build_ami"></a>

## build_ami

Builds an AMI running an Ansible provisioner.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|REGION|The AMI's destination AWS region.|N/A|yes|
|AMI_NAME|An unique AMI name within the AWS region.|N/A|yes|
|ANSIBLE_GALAXY_REQ_PATH|An Ansible Galaxy requirements file path.|N/A|yes|
|VARIABLES_FILE|A Packer variables file path.|N/A|yes|
|TEMPLATE_FILE|A Packer template file path.|N/A|yes|

### Outputs

None.

### Example

```
build_ami sa-east-1 unique-ami-name "playbooks/requirements.yml" "packer-variables.json" "ami-builder/packer_template.json"
```
