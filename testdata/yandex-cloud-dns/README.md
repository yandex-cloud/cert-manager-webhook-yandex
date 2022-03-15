# Solver testdata directory

create config.json file
```json
{
  "folder": "<folder_id>",
  "serviceAccountSecretRef": {
    "name": "secret",
    "key": "iamkey.json"
  }
}
```

and secret.yaml file

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: secret
data:
  iamkey.json: >-
    ***
type: Opaque
```
