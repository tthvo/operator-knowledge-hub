# Cryostat Operator Local Development

Here are some useful things to know if you are working on https://github.com/cryostatio/cryostat-operator.

### Local Manual Deployment

Any changes to go source files requires building a operator image and modify `OPERATOR_IMG`. The recommended way to test your local changes is manual deployment with `make deploy`.

> If you make changes to the Go sources, you'd need to build and push a custom operator image and pass that to make deploy with the OPERATOR_IMG variable. 

```bash
# Before building and deploying, you need to set up env vars
# If not set, they are default to values defined in Makefile
export IMAGE_VERSION="2.2.0-dev" # Tag
export IMAGE_NAMESPACE="quay.io/$YOUR_QUAY_USERNAME" # Quay registry, e.g. "quay.io/thvo" or "quay.io/macao"
export OPERATOR_NAME="cryostat-operator"
export DEPLOY_NAMESPACE="default" 

# Build and push the image to remote registry
make oci-build && \
podman image prune -f && \
podman push $IMAGE_NAMESPACE/$OPERATOR_NAME:$IMAGE_VERSION

# Deploy to the running cluster
make OPERATOR_IMG=$IMAGE_NAMESPACE/$OPERATOR_NAME:$IMAGE_VERSION deploy # or just `make deploy` if env variables were exported
```

### Local Bundle Deployment

1. Make sure you have a configured running cluster. If not, follow this [guide](../general/clusters.md).

2. Run scripts with your changes in `cryostat-operator` directory.
	```bash
    # Set env variables again
    export IMAGE_VERSION="2.2.0-dev" # current operator version
    export OPERATOR_IMG="quay.io/$YOUR_QUAY_USERNAME/cryostat-operator:$IMAGE_VERSION"
    export BUNDLE_IMG="quay.io/$YOUR_QUAY_USERNAME/cryostat-operator-bundle:$IMAGE_VERSION"

    # Build and push image to remote registry if changed
    make oci-build && \
    podman push $OPERATOR_IMG

    # Build and push bundle image to remote registry
    make bundle && \
    make bundle-build && \
    podman image prune -f && \
    podman push $BUNDLE_IMG

    # Deploy bundle to the running cluster
    make deploy_bundle  

    # Then finally create a Cryostat CR
    make create_cryostat_cr 
	```

	Congratulations! You can now see your deployed `Cryostat Operator` under the `Operators` tab under `Installed Operators`.

	![operator-installed-seen-on-console](../img/openshift-cryostat-bundle.png)  

### Notes

For `crc` as local cluster, it is known to be very CPU and memory intensive.

Repositories containing the required images under your Quay namespace must be "public". Otherwise, a `401 UNAUTHORIZED` error will occur when deploying the bundle.

## Local Manual Bundle Deployment

This guide will show you how to deploy the operator in bundle format without running `operator-sdk run <image>`.


1. Built the controller image (tagged 2.2.0-dev) and bundle image (tagged 2.2.0-dev) as [above](#local-bundle-deployment).

2. Built catalog image with cryostat-operator 2.1.2-dev and new bundle image.
	```bash
	make catalog-build CATALOG_IMG=quay.io/thvo/cryostat-operator-catalog:latest \
	BUNDLE_IMGS='quay.io/cryostat/cryostat-operator-bundle:2.1.2-dev,quay.io/thvo/cryostat-operator-bundle:2.2.0-dev'
	```

3. All images pushed to my quay.io/thvo registry in public mode.

4. Created a CatalogSource pointing to that index image and channel set to alpha.
	```bash
	cat <<EOF | oc apply -f -
	apiVersion: operators.coreos.com/v1alpha1
	kind: CatalogSource
	metadata:
	name: cryostat-catalog
	namespace: openshift-marketplace
	spec:
	sourceType: grpc
	image: quay.io/thvo/cryostat-operator-catalog:latest
	displayName: Cryostat Catalog
	publisher: Cryostat Authors
	updateStrategy:
		registryPoll:
		interval: 10m
	EOF
	```
5. Created a OperatorGroup with targetNamespace to default or your namespace of choice.
	```bash
	cat <<EOF | oc apply -f -
	apiVersion: operators.coreos.com/v1
	kind: OperatorGroup
	metadata:
	name: cryostat-operator-group
	namespace: default
	spec:
	targetNamespaces:
	- default
	EOF
	```
6. Created a Subscription with Manual approval plan in default namespace and startingCSV to 2.1.2-dev.
	```bash
	cat <<EOF | oc apply -f -
	apiVersion: operators.coreos.com/v1alpha1
	kind: Subscription
	metadata:
	name: sub-to-cryostat-operator
	namespace: default
	spec:
	channel: alpha
	name: cryostat-operator
	source: cryostat-catalog
	sourceNamespace: openshift-marketplace
	installPlanApproval: Manual
	EOF
	```
	Note that `installPlanApproval` is deliberately set as `Manual` so you can see the `InstallPlan` created and awaiting approval.

7. Approve the plan via:
	- **Console**: You should be a pop up for `Upgrade Available` inside Cryostat Operator view in `Install Operator` tab.
	- **kubectl/oc**:
		```bash
		$ oc get ip -n default
		NAME            CSV                           APPROVAL     APPROVED
		install-abcd   cryostat-operator.v2.2.0-dev   Automatic    false

		$ oc edit ip install-abcd -n default
		```
		Then, change `spec.approved` from false to true.

8. Now, if successful, you will see the operator up and running as if running `operator-sdk run <image>`.

Sources:
- https://olm.operatorframework.io/docs/tasks/install-operator-with-olm/#example-install-a-specific-version-of-an-operator
- https://docs.openshift.com/container-platform/4.10/operators/user/olm-installing-operators-in-namespace.html#olm-installing-specific-version-cli_olm-installing-operators-in-namespace

## Monitoring

**Note**: `oc` will be the primary cluster client here. To get help, run `oc help`.

To get basic information on the running pods:

```bash
oc get pods [pod-id]
```

To get "top" information (resource metrics):

```bash
oc adm top pods [pod-id] [--containers] # Container flag to check individual containers
```

To get basic information on nodes:

```bash
oc describe nodes [node-id]
```

To get basic information on deployment (i.e. mostly likely the manager deployment):

```bash
oc describe deploy [deploy-id]
```

**Tips**: Any command above can be prefixed with `watch`. For example, `watch oc get pods`. This way you can periodically check cluster information without rerunning the command.


## Project Structure

Use this link here: https://book.kubebuilder.io/

With the underlying `Kubebuilder` as said in [FAQ](https://sdk.operatorframework.io/docs/faqs/):

> Operator SDK uses Kubebuilder under the hood to do so for Go projects, such that the operator-sdk CLI tool will work with a project created by kubebuilder. 

The project structure should be similar. Furthermore, some operator sdk commands are compatible in behavior with its kubebuilder counterpart:

> Just keep in mind that when you see an instruction such as "kubebuilder \<command\>", you will use "operator-sdk \<command\>".

### api/v1beta1

Basically, we define our `Kind`s in this directory.

> Kubernetes functions by reconciling desired state (Spec) with actual cluster state (other objects’ Status) and external state, and then recording what it observed (Status). Thus, every functional object includes spec and status. A few types, like ConfigMap don’t follow this pattern, since they don’t encode desired state, but most types do.
	
Kinds are defined in source files as `<kind>_types.go`. Each kind will be defined as its own along with its `Spec`, `Status` and `<Kind>_List` type (a collection of instances of that `Kind`).

Others (you won't have to edit):
- `groupversion_info.go`: contains common metadata about the group-version (see tags at the top). Also defines commonly useful variables that help us set up our Scheme.
- `zz_generated.deepcopy.go`: contains the autogenerated implementation of the `runtime.Object interface`, which marks all of our root types as representing Kinds. The core of the runtime.Object interface is a deep-copy method, DeepCopyObject.

### internal/

Here we define implementations for our operator controller. This directory is deployed as a Go package that is referenced in `main.go`, which will be compiled into a running binary.

#### internal/test

We define our test resources, structs to be used in test files for controllers. Most importantly is the `resources.go`, which defines functions to create Cryostat CR with test specs.

#### internal/controller/common

This directory include utilities and resource definitions used in operator controller logics. For example, some network configurations:

#### internal/controller (TODO)
