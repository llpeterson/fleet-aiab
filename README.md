# Installing AiaB using Fleet

This README describes the steps for installing [AiaB for developers](https://docs.aetherproject.org/master/developer/aiab.html#)
on a node using Fleet. It is intended to serve as an example of how Fleet can be used to install
and configure the Aether software stack.

On GitHub, create a public fork of this repo and make the following changes:

* Edit the `deploy-2.*.yaml` files and replace the `repo:` with the name of your cloned repo.

* In each of the `aether-2.*` directories, edit the file `sd-core-5g/sd-core-5g-values.yaml`
  and replace the IP address `128.105.145.197` with the IP address of the node where you will
  install AiaB.

On your AiaB node, clone the `aether-in-a-box` repo and install the dependencies:

```bash
git clone "https://gerrit.opencord.org/aether-in-a-box"
cd aether-in-a-box
make node-prep router-pod
```

Next, clone your fork of this repo and run the following (where `<version>` is either `2.0`
or `2.1-alpha`, based on which version of Aether you wish to install):

```bash
./install-fleet.sh
kubectl apply -f deploy-<version>.yaml
```

To see the status of your install in Fleet:

```bash
kubectl -n fleet-local get fleet
```
