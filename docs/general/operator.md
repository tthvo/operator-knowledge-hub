# General guide on Operator Pattern


## Basic terminology

| Term | Definition |
|------|------------|
| `Groups` | Basically, a Group is a collection of related functionalities. |
| `Version` | Each group has one or more version (i.e. v2.0.0, beta, alpha). |
| `Kind` | Each API group-version contains one or more API types, which we call Kinds.  |
| `Resource` | A resource is simply a use of a Kind in the API. For instance, the pods resource corresponds to the Pod Kind. With CRDs, each Kind will correspond to a single resource. Resources are always lowercase, and by convention are the lowercase form of the Kind.|
| `GroupVersionKind` (GVK) | It refers to a kind in a particular group-version. Each GVK corresponds to a root Go type in a package. |
| `Scheme` | A way to keep track of what Go type corresponds to a given GVK |
| `CustomResourceDefinition` (CRD)| They are a definition of our customized Objects. |
| `CustomResource` (CR)| They are an instance of CRD. |
| `Controller` | Ensure, for any given object, the actual state of the world (both the cluster state, and potentially external state like running containers for Kubelet or loadbalancers for a cloud provider) matches the desired state in the object. Each controller focuses on one root Kind, but may interact with other Kinds. |
| `Reconciler` | The logic that implements the reconciling for a specific kind.  A reconciler takes the name of an object, and returns whether or not we need to try again (e.g. in case of errors or periodic controllers, like the HorizontalPodAutoscaler). |
## Understanding API Markers

For example, you might notice:

```go
// A ConfigMap containing a .jfc template file
type TemplateConfigMap struct {
	// Name of config map in the local namespace
	// +operator-sdk:csv:customresourcedefinitions:type=spec,xDescriptors={"urn:alm:descriptor:io.kubernetes:ConfigMap"}
	ConfigMapName string `json:"configMapName"`
	// Filename within config map containing the template file
	Filename string `json:"filename"`
}
```

Check out links below for information on these annotations:

- API Markers: https://sdk.operatorframework.io/docs/building-operators/golang/references/markers/
- Struct tags: https://stackoverflow.com/questions/10858787/what-are-the-uses-for-tags-in-go
- OLM Descriptors: https://github.com/openshift/console/blob/master/frontend/packages/operator-lifecycle-manager/src/components/descriptors/reference/reference.md

**Tips**:
- To mark a field as optional, you need specify as follow:
    ```go
    type SomeSpecFields struct {
        // + optional
        OptionalField Type `json:"optionalField, omitempty"`
    }
    ```
    > Optional tells the Kubernetes API server that this field is not required, such as before the secret is created.
    
    > omitempty is similar, but functions on the JSON level. If the field is missing, it won't be transmitted in the JSON body.
