# Installing AiaB using Fleet

This README describes the steps for installing AiaB for developers on a node using Fleet.

On GitHub, create a public clone this repo and make the following changes:

* Edit the `deploy-2.*.yaml` files and replace the `repo:` with the name of your cloned repo.

* In each of the `aether-2.*` directories, edit the file `sd-core-5g/sd-core-5g-values.yaml`
  and replace the IP address `128.105.145.197` with the IP address of the node where you will
  install AiaB.

On your AiaB node, check out the `aether-in-a-box` repo and run:

```bash
make node-prep
make router-pod
```

Next, check out your clone of this repo and run the following (where `<version>` is either 2.0
or 2.1-alpha):

```bash
./install-fleet.sh
kubectl apply -f deploy-<version>.yaml
```

To see the progress of your install:

```bash
kubectl -n fleet-local get fleet
```

