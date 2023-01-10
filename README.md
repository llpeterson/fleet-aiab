# Installing AiaB using Fleet

This README describes the steps for installing [AiaB for developers](https://docs.aetherproject.org/master/developer/aiab.html#)
on a node using Fleet. It is intended to serve as an example of how Fleet can be used to install
and configure the Aether software stack.

On GitHub, first create a public fork of this repo. The reason for this step is that Fleet is a
GitOps-based tool: you will point Fleet at your forked repo and your installation will be driven
from the contents of your repo. If you make changes to your repo then they will be automatically
reflected on your AiaB node.

On your AiaB node, clone the `aether-in-a-box` repo and install the dependencies:

```bash
git clone "https://gerrit.opencord.org/aether-in-a-box"
cd aether-in-a-box
make node-prep router-pod
```

Next, install Fleet on your AiaB node:

```bash
helm -n cattle-fleet-system install --create-namespace --wait \
    fleet-crd https://github.com/rancher/fleet/releases/download/v0.5.0/fleet-crd-0.5.0.tgz
helm -n cattle-fleet-system install --create-namespace --wait \
    fleet https://github.com/rancher/fleet/releases/download/v0.5.0/fleet-0.5.0.tgz
```

To install one of the Aether versions (`aether-2.0` or `aether-2.1-alpha`), add the
appropriate `GitRepo` resource. Below, replace the `repo:` line with the name of your
own repo:

```bash
cat > deploy.yaml << EOF
apiVersion: fleet.cattle.io/v1alpha1
kind: GitRepo
metadata:
  name: aiab
  namespace: fleet-local
spec:
  repo: "https://github.com/andybavier/fleet-aiab"  # Replace with your fork
  branch: main
  paths:
  - aether-2.0   # Specify one of "aether-2.0" or "aether-2.1-alpha"
EOF

kubectl apply -f deploy.yaml
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
