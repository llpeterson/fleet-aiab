#!/bin/sh

helm -n cattle-fleet-system install --create-namespace --wait \
    fleet-crd https://github.com/rancher/fleet/releases/download/v0.5.0/fleet-crd-0.5.0.tgz
helm -n cattle-fleet-system install --create-namespace --wait \
    fleet https://github.com/rancher/fleet/releases/download/v0.5.0/fleet-0.5.0.tgz
