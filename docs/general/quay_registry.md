# Authentication with Quay.io

A [Quay.io](quay.io) account is needed to be able to pull, push, and store container images when running operator's make recipe. Red Hat associates should be able to create an account and sign in with their Red Hat email. Details can be followed [here](https://access.redhat.com/articles/5363231).

In order to pull images from the Quay.io repository, Podman needs to be signed in from a Quay account. More details about [podman-login](https://docs.podman.io/en/latest/markdown/podman-login.1.html).

```bash
$ podman login quay.io # should auto login without password if signed into SSO
Username: 
Password:
```
When successful:
```bash
Login Succeeded!
```