# wetty-openshift
The wetty-openshift project contains materials that support the deployment of Wetty in a container but following OpenShift best practices.  This means not running as **root**.

When Wetty is run as the **root** user, Wetty executes **/bin/login** to log in to the host on which it is run.  OpenShift by default doesn't allow containers to be run as **root** for good reason.  In this case, Wetty will try to SSH to the localhost.  Now, we could tell Wetty to SSH elsewhere, but we know a trick.  When multiple containers are run in a single pod, they can reference each other as *localhost*.  Therefore, the deployment config deploys two containers in a pod:

1. nodejs:6 s2i container with the Wetty application
2. A Dockerfile built openssh container running as a non-privileged user.  This container has Maven and the OpenShift CLI tool installed.

## Theory of Operation
The *openssh* container image is built in the *openshift* project namespace making it available to all users.  Because the build process is a bit labor intensive from the standpoint of the host, it seems more practical to do it once.

The templates are added to the *openshift* namespace as well.  The users have a choice to deploy with ephemeral or persistant storage.  The *openssh* container gets pulled from the *openshift* namespace.  The container running Wetty* gets built and deployed in the user's project.

With the *wetty-persistant* template, the persistant storage gets mounted at **/home/default**.

## Security Notes
Use of wetty-openshift requires a new security context constraint to be added found in **openshift/wetty-scc.yaml**.  This allows a container to be run as a user with UID 2000.  Otherwise, the rules in the SCC match that of the *restricted* scc.

The other security consideration is in the *openssh* container itself.  The SSH server is bound to port 22 by default.  Ports below 1024 are typically only accessible by **root**.  The *openssh* container is not run as **root**.  There are a couple ways to handle this.  The first is binding the SSH server to port greater than 1024.  The second is to add the  CAP_NET_BIND_SERVICE capability to **/usr/sbin/sshd**.  This is the route chosen in this case.  This means that the **/usr/sbin/sshd** binary, and only the **sshd** binary, can bind to any port.

## Getting Started
### As an OpenShift Cluster Admin
1. Clone the repo.
```terminal
git clone https://github.com/kevensen/wetty-openshift.git
```
2. Add the security context constraint
```terminal
cd wetty-openshift/openshift
oc create -f wetty-scc.yaml
```
3. Build the *openssh* container in the *openshift* namespace
```terminal
oc process -f wetty-openssh.yaml -p WETTY_PASSWORD=wetty -n openshift | oc create -n openshift -f -
```
4. Add the Wetty templates to the *openshift* namespace
```terminal
oc create -f wetty-ephemeral.yaml -n openshift
oc create -f wetty-persistant.yaml -n openshift
```

### As an OpenShift User
1. Create a project
2. Choose either *wetty-ephemeral* or *wetty-persistant*
