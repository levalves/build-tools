# Kubernetes

This library helps deploy application on EKS cluster.

Available methods:
- [kubectl_apply](#kubectl_apply)

## kubectl_apply

Deploy application.

### Inputs

|Name|Description|Default|Required|
|----|-----------|-------|--------|
|CLUSTER_NAME|EKS cluster name.|N/A|yes|
|REGION|The region to exist EKS cluster.|N/A|yes|
|AWS_ROLE_ARN|AWS role ARN.|N/A|yes|
|NAMESPACE|The namespace to deploy application in cluster.|N/A|yes|
|K8S_WORKING_DIR|Path to kubernetes artifacts folder.|N/A|yes|

### Outputs

None.

### Example

```
kubectl_apply 'credito-eks-paas-staging' 'us-east-1' 'arn:aws:iam::000000000000:role/account-name' 'example-app' "$PWD/k8s"
```
