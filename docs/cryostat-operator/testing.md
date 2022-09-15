# Testing

An example of test framework setup: https://onsi.github.io/ginkgo/#separating_creation_and_configuration_

**Tips**:
- To skip tests, set:
    ```bash
    export SKIP_TESTS=true
    ```
- To run all tests (unit tests and scorecards):
    ```bash
    make test
    ```

## Unit Test

Run `make test-envtest`. This will run controller tests using `ginkgo` if installed, or `go test` if not, requiring no cluster connection.

## Scorecard Test

Run `make test-scorecard`. This will run the Operator SDK's scorecard test suite. 

This requires a Kubernetes/OpenShift cluster to be available and logged in with your `kubectl` or `oc` client. Check out this [guide](../general/clusters.md) on how to set up local clusters.

## OperatorSDK Tests

Currently, `make bundle` will run the default general testsuite as `operator-sdk bundle validate ./bundle`.

To run tests with a specific suite (e.g `operator-framework`), run:

```bash
# This will run against test suite to release to OperatorHub
operator-sdk bundle validate /path/to/bundle --select-optional suite=operatorframework
```

Source: https://github.com/operator-framework/operator-sdk/issues/4376
