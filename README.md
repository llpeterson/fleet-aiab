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

To track the progress of your install in Fleet:

```bash
kubectl -n fleet-local get bundles
```

The install is successful when all pods in the `aether-roc` and `omec` namespaces have status `Running`.
(Note that, with the `aether-2.1-alpha` install, the `metricfunc` pod remains in `CrashLoopBackoff` state;
this needs to be investigated.)  Even after a successful install, it is likely that not all of the bundles
will show as Ready in Fleet.  For example, after installing `aether-2.0` you will likely see something like:

```
$ kubectl -n fleet-local get bundles
NAME                       BUNDLEDEPLOYMENTS-READY   STATUS
aether-roc-umbrella        0/1                       Modified(1) [Cluster fleet-local/local]; kind.topo.onosproject.org aether-roc/aether modified {"spec":{"aspects":{}}}; kind.topo.onosproject.org aether-roc/plproxy modified {"spec":{"aspects":{}}}
aiab-aether-2-0-4e093411   1/1
atomix-controller          1/1
atomix-raft-storage        1/1
fleet-agent-local          1/1
onos-operator              1/1
sd-core-5g                 1/1
```

After Fleet has successfully installed all the Aether components, to validate the setup
run the following commands in the `aether-in-a-box` directory.

For `aether-2.1-alpha` install:

```bash
touch build/milestones/roc build/milestones/5g-core
make roc-5g-models 5g-test
```

For `aether-2.0` install:

```bash
touch build/milestones/roc build/milestones/5g-core
CHARTS=release-2.0 make roc-5g-models 5g-test
```

In both cases the 5G test should succeed.
