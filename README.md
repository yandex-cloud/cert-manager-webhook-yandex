# Yandex Cloud DNS ACME webhook

## Usage
### Setup Kubernetes
You can use [Yandex Cloud Managed Service for Kubernetes](https://cloud.yandex.com/en/docs/managed-kubernetes/quickstart) or another Kubernetes service\
[Install cert-manager](https://cert-manager.io/docs/installation/) \
[Install helm](https://v2.helm.sh/docs/using_helm/#installing-helm)

### Install webhook
```shell
git clone https://github.com/Ditmarscehen/cert-manager-webhook-yandex
```

```shell
helm install -n cert-manager yandex-webhook ./deploy/cert-manager-webhook-yandex
```

### Create Secret

Create [iam key](https://cloud.yandex.ru/docs/cli/cli-ref/managed-services/iam/key/create) with `--format=json`

Create secret:
```shell
kubectl create secret generic ycdnssercret \
   --from-file=iamkey.json \
   --namespace=$NAMESPACE
```
NAMESPACE for Issuer is default, for ClusterIssuer is cert-manager (пока не разбирался, еще потестить надо)

### Create Issuer or ClusterIssuer

Create an [Issuer or ClusterIssuer](https://cert-manager.io/docs/configuration/acme/) with [webhook](https://cert-manager.io/docs/configuration/acme/dns01/webhook/) with next parameters

```yaml
solverName: yandex-solver
```
`groupName` is defined in deploy/cert-manager-webhook-yandex/values.yaml

Issuer example:
```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: issuer
  namespace: default
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: your@email.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: secret-ref
    solvers:
      - dns01:
          webhook:
            config:
              # The ID of the folder
              folder: folderid
              # This is the secret used to access the service account
              serviceAccountSecretRef:
                name: ycdnssercret
                key: iamkey.json
            groupName: acme.mycompany.example
            solverName: yandex-solver
```

ClusterIssuer example:
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: clusterissuer
  namespace: default
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: your@email.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: secret-ref
    solvers:
      - dns01:
          webhook:
            config:
              # The ID of the folder
              folder: folderid
              # This is the secret used to access the service account
              serviceAccountSecretRef:
                name: ycdnssercret
                key: iamkey.json
            groupName: acme.mycompany.example
            solverName: yandex
```

### Create Certificate

Create [Certificate](https://cert-manager.io/docs/usage/certificate/)

Certificate with Issuer example:
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-com
  namespace: default
spec:
  secretName: example-com-secret
  issuerRef:
    # The issuer created previously
    name: issuer
    kind: Issuer
  dnsNames:
    - example.com
```

Certificate with ClusterIssuer example:
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-com
  namespace: default
spec:
  secretName: example-com-secret
  issuerRef:
    # The issuer created previously
    name: clusterissuer
    kind: ClusterIssuer
  dnsNames:
    - example.com
```
