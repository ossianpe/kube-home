## A Helm chart for setting up ShinobiCCTV
This chart let you set up [ShinobiCCTV](https://shinobi.video/) on your kubernetes cluster with helm package manager.

## Usage
Just checkout this repository and run `helm install shinobi`

```bash
git clone https://gitlab.com/neatori18/ShinobiHelm.git shinobi
helm install shinobi
```

You will get the output message similler to the following
and you can get access to the app.

```txt
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app=shinobi,release=wobbly-meerkat" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:80
```

## Variables
You can tweek your ShinobiCCTV release with several variables.
Notable settings are the following.

- shinobi.app.super.mail: Super user's email address
- shinobi.app.super.pass: MD5 of super user's password

You can run the release with those variables by for e.g.

```bash
helm install shinobi \
--set shinobi.app.super.mail=admin_email_address \
--set shinobi.app.super.pass=md5_of_admin_password
```

## IMPORTANT: setup

Must navigate to `http://127.0.0.1/super` and create user
before being able to use service.

For more details, please read `values.yaml`.

## License
MIT
