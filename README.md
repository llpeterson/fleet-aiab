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

The install is successful when all pods in the `aether-roc` and `omec` namespaces have status `Running`.
(Note that, with the `2.1-alpha` install, the `metricfunc` pod remains in `CrashLoopBackoff` state;
this needs to be investigated.)  Even after a successful install, it is likely that you'll see some errors
in Fleet.  For example, after installing `2.1-alpha` you will likely see something like:

```
$ kubectl -n fleet-local get fleet
NAME                           REPO                                       COMMIT                                     BUNDLEDEPLOYMENTS-READY   STATUS
gitrepo.fleet.cattle.io/aiab   https://github.com/andybavier/fleet-aiab   2367ed4fa43f0c82929d548f8628565db3b126ac   3/5                       Modified(1) [Bundle aether-roc-umbrella]; NotReady(1) [Bundle sd-core-5g]; configmap.v1 aether-roc/onos-consensus-store extra; deployment.apps omec/metricfunc [progressing] Deployment does not have minimum availability., Available: 0/1; kind.topo.onosproject.org aether-roc/aether modified {"spec":{"aspects":{}}}; kind.topo.onosproject.org aether-roc/enterprise modified {"spec":{"aspects":{}}}; service.v1 aether-roc/onos-consensus-store extra

NAME                                   CLUSTERS-READY   BUNDLES-READY   STATUS
clustergroup.fleet.cattle.io/default   0/1 (local)      4/6             Modified(1) [Bundle aether-roc-umbrella]; NotReady(1) [Bundle sd-core-5g]; configmap.v1 aether-roc/onos-consensus-store extra; deployment.apps omec/metricfunc [progressing] Deployment does not have minimum availability., Available: 0/1; kind.topo.onosproject.org aether-roc/aether modified {"spec":{"aspects":{}}}; kind.topo.onosproject.org aether-roc/enterprise modified {"spec":{"aspects":{}}}; service.v1 aether-roc/onos-consensus-store extra
```

After Fleet has successfully installed all the Aether components, to validate the setup
run the following commands in the `aether-in-a-box` directory:

```bash
touch build/milestones/roc build/milestones/5g-core
make roc-5g-models 5g-test
```

The 5G test should succeed.
