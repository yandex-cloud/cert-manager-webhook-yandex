# Yandex Cloud DNS ACME webhook

## Usage
### Setup Kubernetes
You can use [Yandex Cloud Managed Service for Kubernetes](https://cloud.yandex.com/en/docs/managed-kubernetes/quickstart) or another Kubernetes service\
[Install cert-manager](https://cert-manager.io/docs/installation/) \
[Install helm](https://v2.helm.sh/docs/using_helm/#installing-helm)

### Install webhook
```shell
git clone https://github.com/yandex-cloud/cert-manager-webhook-yandex.git
```

```shell
helm install -n cert-manager yandex-webhook ./deploy/cert-manager-webhook-yandex
```

### Create the AccessKey Secret

Obtain [iam key json file](https://cloud.yandex.ru/docs/cli/cli-ref/managed-services/iam/key/create)
```shell
yc iam key create iamkey \
 --service-account-id=<your service account ID> 
 --format=json \
 --output=iamkey.json
```
Note that service account needs permissions to create and delete records at your zone 

Create secret:
```shell
kubectl create secret generic cert-manager-secret --from-file=iamkey.json -n cert-manager
```
### Create Issuer or ClusterIssuer

Create an [Issuer or ClusterIssuer](https://cert-manager.io/docs/configuration/acme/) with [webhook](https://cert-manager.io/docs/configuration/acme/dns01/webhook/) with next parameters

```yaml
solverName: yandex-cloud-dns
groupName: acme.cloud.yandex.com
```

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
              # The ID of the folder where dns-zone located in
              folder: <your folder ID>
              # This is the secret used to access the service account
              serviceAccountSecretRef:
                name: cert-manager-secret
                key: iamkey.json
            groupName: acme.cloud.yandex.com
            solverName: yandex-cloud-dns
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
              # The ID of the folder where dns-zone located in
              folder: <your folder ID>
              # This is the secret used to access the service account
              serviceAccountSecretRef:
                name: cert-manager-secret
                key: iamkey.json
            groupName: acme.cloud.yandex.com
            solverName: yandex-cloud-dns
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
