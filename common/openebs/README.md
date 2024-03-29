# OpenEBS

If you just want to deploy the local path provisioner you can adjust the values file for the OpenEBS helm chart to the following:

```yaml
localprovisioner:
  enabled: true
  deviceClass:
    enabled: false
  hostpathClass:
    isDefaultClass: true
snapshotOperator:
  enabled: false
ndm:
  enabled: false
ndmOperator:
  enabled: false
```
