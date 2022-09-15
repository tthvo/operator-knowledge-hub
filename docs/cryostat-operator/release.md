# Release on OperatorHub

Cryostat Operator is released on [OperatorHub](https://operatorhub.io/operator/cryostat-operator). Please check out the [latest tag](https://github.com/cryostatio/cryostat-operator/tags). To speed up the release process, you can run the test suite locally before opening the PR.

All `cryostat-operator` OperatorHub release Github issues and associated pull requests are listed below.


| Operator Version | GitHub Issue                                               | OperatorHub PR                                                   |
|------------------|------------------------------------------------------------|------------------------------------------------------------------|
| 2.1.1            | https://github.com/cryostatio/cryostat-operator/issues/396 | https://github.com/k8s-operatorhub/community-operators/pull/1365 |
| 2.0.0            | https://github.com/cryostatio/cryostat-operator/issues/279 | https://github.com/k8s-operatorhub/community-operators/pull/481  |

The testing steps are listed [below](#full-steps-for-passing-all-operatorhub-tests) for convenience.

### Full steps for passing all OperatorHub tests

**Environment**

- Fedora 35
- `kind v0.11.0` in `PATH` (specifically `/usr/local/bin/kind`)
- `podman v3.4.7`
- `docker v.20.10.17`
- `ansible v.2.9.27`
- ` kubernetes-kubeadm v1.22.7`
- `curl`
- `openssl`
- `git`

**To setup environment**
```bash
# Installing dependencies
sudo dnf install git openssl curl # If not yet installed
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
sudo dnf install podman
sudo dnf install moby-engine docker-compose
sudo dnf install ansible
sudo dnf install kubernetes-kubeadm

# Create and add yourself to docker group
# This avoids typing sudo on docker command
# Might need to log out and in again for effect to take place.
sudo groupadd docker
sudo usermod -aG docker $USER

# Start docker
sudo systemctl start docker

# Start kubelet
sudo swapoff -a # disable swap for kubelet to work -> https://stackoverflow.com/a/52196985
systemctl enable kubelet.service # (Kubernetes v1.22.7)
systemctl start kubelet
```

**Run test suites**
```bash
# Run this as one command (with release version and GitHub user name replaced)
OPP_CONTAINER_TOOL=docker OPP_AUTO_PACKAGEMANIFEST_CLUSTER_VERSION_LABEL=1 OPP_PRODUCTION_TYPE=k8s \
bash <(curl -sL https://raw.githubusercontent.com/redhat-openshift-ecosystem/community-operators-pipeline/ci/latest/ci/scripts/opp.sh) \
all \
operators/cryostat-operator/$CRYOSTAT_RELEASE_VERSION \
$GITHUB_USERNAME/community-operators \
cryostat-operator
```

**Note**: 
- Please fork the `community-operators` and clone the fork repository to your local machine.
- Create/Checkout a new branch `cryostat-operator`. When done with creating a new release bundle, commit your changes (signed-off) `git commit -s` and push your branch to your fork.
- Replace `GITHUB_USERNAME` with your GitHub username and `CRYOSTAT_VERSION` with new release version.
- Run this script directly under `community-operators` directory. 

**Clean up after tests**
```bash
bash <(curl -sL https://raw.githubusercontent.com/redhat-openshift-ecosystem/community-operators-pipeline/ci/latest/ci/scripts/opp.sh) \
clean
```

**Troubleshooting**
If OLM resource error occurs, test resources might not have been cleaned. Follow step above to clean resources or run
```
/tmp/operator-test/operator-sdk olm uninstall
```


The content of the new release is under `bundle/` directory (on appropriate tag). You might need to rename and make some changes. Please check out previous release for references.
