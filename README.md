## IoT

### Instructions for the different parts of the projects:

For the projects to work properly, git clone the repo directly in the VM.

#### P1:

In order to set up the 2 VMs with vagrant (cbernazeS & cbernazeSW) you need to run the commands with "sudo":

`sudo vagrant up`

`sudo vagrant destroy`

`sudo vagrant global-status`

`sudo vagrant ssh <vm-name>`

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

#### P3

To create a k3d cluster use this command:
```k3d cluster create mycluster```

To delete a k3d cluster use this command:
```k3d cluster delete mycluster```

Current error
> {"level":"fatal","msg":"rpc error: code = Unknown desc = error getting server version: failed to get server version: Get \"https://0.0.0.0:36515/version?timeout=32s\": dial tcp 0.0.0.0:36515: connect: connection refused","time":"2025-09-30T15:23:25+02:00"} argocd

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
- [Argo CD - Doc](https://argo-cd.readthedocs.io/en/stable/)
- [Argo CD - Blog](https://une-tasse-de.cafe/blog/argocd/)
- [Argo CD - Sokube](https://www.sokube.io/en/blog/gitops-on-a-laptop-with-k3d-and-argocd-en)


sudo kubectl get nodes -o wide
sudo cat /var/lib/rancher/k3s/server/token
sudo journalctl -u k3s
sudo journalctl -u k3s-agent
ip a show eth1

sudo kubectl delete deployments --all && sudo kubectl delete services --all && sudo kubectl delete configmaps --all && sudo kubectl delete pods --all && sudo kubectl delete ingress --all && sudo kubectl delete ingressclass --all
