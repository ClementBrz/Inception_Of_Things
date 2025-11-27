## IoT

### Instructions for the different parts of the projects:

For the projects to work properly, git clone the repo directly in the VM.

#### FYI

> The debian version used in the Vagrantfiles in p1 and p2 is not its latest version because the
> boxes found in the HashiCorp cloud go up to bookworm64 version of Debian.
> You can check here: https://portal.cloud.hashicorp.com/vagrant/discover/debian

#### P1:

Before starting p1 you need to run ```p1/scripts/startup.sh``` so that necessary dependencies are installed for the project!

In order to set up the 2 VMs with vagrant (cbernazeS & cbernazeSW), and interact with them, you need to run the commands below in the repo where the Vagrantfile is found:

- Startup the VMs
`vagrant up`

- Shut down the VMs
`vagrant destroy -g` (-g for grateful shutdown)

- Checkout existing VMs
`vagrant global-status`

- Connect to the specified VM using SSH
`vagrant ssh <vm-name>`

Uninstalling Servers
To uninstall K3s from a server node, run:

`/usr/local/bin/k3s-uninstall.sh`

Uninstalling Agents
To uninstall K3s from an agent node, run:

`/usr/local/bin/k3s-agent-uninstall.sh`

If you want to check that everything asked in the subject works, run this script:
```./scripts/p1_tests.sh```

> **If there a permission error :** "/opt/vagrant/embedded/gems/gems/vagrant-2.4.9/lib/vagrant/machine.rb:666:in 'write': Permission denied @ rb_sysopen - /home/iot/Inception_Of_Things/p1/.vagrant/machines/cbernazeSW/virtualbox/vagrant_cwd (Errno::EACCES)"
> **Delete the .vagrant file**

> **If there is this error :**
> ==> cbernazeS: Running 'pre-boot' VM customizations...A customization command failed:["modifyvm", :id, "--name", "cbernazeS"]The following error was experienced:#<Vagrant::Errors::VBoxManageError:"There was an error while executing `VBoxManage`, a CLI used by Vagrant\nfor controlling VirtualBox. The command and stderr is shown below.\n\nCommand: [\"modifyvm\", \"c5272bf6-a1c5-4783-95a1-7d5cb7e0932f\", \"--name\", \"cbernazeS\"]\n\nStderr: VBoxManage: error: Could not rename the directory '/home/iot/VirtualBox VMs/p1_cbernazeS_1758108675963_6431' to '/home/iot/VirtualBox VMs/cbernazeS' to save the settings file (VERR_ALREADY_EXISTS)\nVBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component SessionMachine, interface IMachine, callee nsISupports\nVBoxManage: error: Context: \"SaveSettings()\" at line 3640 of file VBoxManageModifyVM.cpp\n">Please fix this customization and try again.

> **Check also that all VMs are removed in VirtualBox**


#### P2

> Problem I ran into : unexpected "(" in my k3s_server.sh script, I ran that script with sh in the Vagrantfile, it was supposed to be ran by bash

In order to acces app1.com app2.com etc in the browser you need to add them to **/etc/hosts**
```
192.168.56.110 app1.com
192.168.56.110 app2.com
192.168.56.110 app3.com
```

Wait a little bit of time once the k3s is running, the pods need to be running, and connect to the different apps like shown below:
- "http://192.168.56.110" should show app3
- "http://192.168.56.110:app1.com" should show app1
- "http://192.168.56.110:app2.com" should show app2
- "http://192.168.56.110:app3.com" should show app3

#### P3

To create a k3d cluster use this command:
```k3d cluster create mycluster```

To delete a k3d cluster use this command:
```k3d cluster delete mycluster```

Run ```./scripts/setup-iot-p3.sh``` to start this part.

Logs for the app and ArgoCD are stored in there respective port-forward files.

#### Bonus

Helm is the package manager for Kubernetes
It has a CLI that allows you to add repositories from the ArtifactHub (like DockerHub but for Helm).
In our case we add gitlab's repository. Once this is done you have access to Helm charts.
You can then install whatever chart you want. A Helm chart is a package, it has all the dependencies,
necessary to run an app, a tool, etc.
A repository is like a database that gives you access to a bunch of charts (packages).

To compare with apt, it's like if you wanted to install python, you first had to get a repository
containing the existing python packages, then you could install whichever python package you want
from its repository.

Now with a chart you can create one or more releases. For example if you have MySQL chart, you can create
several release, each corresponding to a specific database, and you can configure them differently.

> The helm CLI has 3 main commands:
> - `helm repo add <repo_name>` allows you to add the repository of your choice to your local machine
> - `helm search hub` or `helm search repo`: the first searches all repositories on the hub, you can specify what repo you are looking for (for example: `helm search hub gitlab`)
>   the second one searches for repositories you added locally using `helm repo add`
> - `helm install <release_name> <chart_name>` is used to install a chart (package) contained in a repo you added to your local helm instance (for example: `helm install gitlab1 gitlab/gitlab`)

To see the status of a specific release you can use `helm status <release_name>`
`helm show values <chart_name>` shows you the element of configuration you can override for a chart.
If you want to edit some of those configuration you can write them in a yaml file and then add it to the helm command to install a chart.
For example `helm install -f value.yaml gitlab/gitlab --generate-name`, this command will create an release of gitlab/gitlab but will override
only the configurations specified in your yaml file, the rest of the configuration are the default one you were shown earlier using `helm show values [...]`
`--generate-name` automatically creates a name for your release.

You can upgrade an release, if there is an update on a chart or if you want to change the configuration using `helm upgrade`
For example: `helm upgrade -f value.yaml <release_name> <chart_name>`

If something breaks in an upgrade or doesn't work as expected you can always go back to a previous version using `helm rollback <release_name> <revision_number>`
The revision number is the version number of your release (1 correspond to its first version). To see a release's revisions you can use `helm history <release_name>`

`helm uninstall <release_name> -n <namespace>` uninstalls the specified release.

### Documentation
#### GLOBAL : Kubectl commands cheat sheet
- [Kubectl](https://spacelift.io/blog/kubernetes-cheat-sheet) & (https://spacelift.io/blog/kubectl-apply-vs-create) & (https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-strong-getting-started-strong-)
- [Deployments vs Services](https://zeet.co/blog/kubernetes-service-vs-deployment)

#### P1 : K3s and Vagrant
- [K3s](https://docs.k3s.io/)
- [Vagrant - Doc](https://developer.hashicorp.com/vagrant/tutorials/getting-started?product_intent=vagrant)
- [TechWhale](https://www.youtube.com/watch?v=5-PGV-r_684&pp=ygUYdmFncmFudCBjb21tZW50IHV0aWxpc2Vy)

#### P2 : K3s and three simple applications
- [K3s - First Deploy](https://k33g.gitlab.io/articles/2020-02-21-K3S-02-FIRST-DEPLOY.html)
- [K3s - Medium](https://medium.com/@samanazizi/how-to-deploy-a-simple-static-html-project-on-k3s-322667967ed4)
- [K3s - Blog](https://www.jeffgeerling.com/blog/2022/quick-hello-world-http-deployment-testing-k3s-and-traefik)

#### P3 : K3d and Argo CD
- [K3d](https://k3d.io/stable/)
- [ArgoCD - Doc](https://argo-cd.readthedocs.io/en/stable/)
- [ArgoCD - Blog](https://une-tasse-de.cafe/blog/argocd/)
- [ArgoCD - Sokube](https://www.sokube.io/en/blog/gitops-on-a-laptop-with-k3d-and-argocd-en)
- [ArgoCD - Tutorial](https://www.youtube.com/watch?v=MeU5_k9ssrs)
- [ArgoCD - Projects](https://argo-cd.readthedocs.io/en/stable/user-guide/projects/)

#### Bonus : GitLab in K3D
- [Helm](https://helm.sh/docs/intro/cheatsheet/)
- [GitLab - self-hosted installation](https://hepapi.github.io/knowledge-hub/devops/gitlab/gitlab-self-hosted-installation/#using-an-existing-cert-manager)
- [Gitlab k3g - gitlab in k3d](https://k3g.gitlab.io/)

sudo kubectl get nodes -o wide
sudo cat /var/lib/rancher/k3s/server/token
sudo journalctl -u k3s
sudo journalctl -u k3s-agent
ip a show eth1

sudo kubectl delete deployments --all && sudo kubectl delete services --all && sudo kubectl delete configmaps --all && sudo kubectl delete pods --all && sudo kubectl delete ingress --all && sudo kubectl delete ingressclass --all
