# operator-knowledge-hub

A knowledge hub for k8s/oc operators. This includes documentations and utility scripts.

## SEE ALSO

* [cryostat-operator](https://github.com/cryostatio/cryostat-operator): A Kubernetes Operator to automate deployment of Cryostat.

* [Cryostat](https://cryostat.io/): The official Cryostat website.

## DOCUMENTATIONS

Note that documentations are updated to work with [cryostat-operator](https://github.com/cryostatio/cryostat-operator) and primarily Openshift platform.


## SCRIPTS

Below is the list of currently supported functionalities/workflows:

| Script | Descriptions |
|--------|--------------|
|[install-operator-sdk.sh](./scripts/install-operator-sdk.sh)| Install a specific operator-sdk version|
|[run-ci-test.sh](./scripts/run-ci-test.sh)| Run the OperatorHub test suite (default: all) |
|[watch-containers.sh](./scripts/watch-containers.sh)| Periodically poll containers in namespace (default: default)|

**Note**: Please check scripts for system package prerequisites.
