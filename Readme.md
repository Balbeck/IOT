### SetUp de la VM VirtualBox avec Ubuntu Desktop 24.04.3 LTS

`https://ubuntu.com/download/desktop/thank-you?version=24.04.3&architecture=amd64&lts=true`

#### Activer la nested virtualization en CLI sur la machine Hote VirtualBox:

Par default sur Linux VirtualBox bugg et ne permet pas d'activer la virtualisation imbrique via l'interface graphique. Pour cela il faut l'activer via le CLI.
! La VM doit etre Off !

```bash
VBoxManage modifyvm "NomExactDeLaVM" --nested-hw-virt on
```

Verification:

```bash
VBoxManage showvminfo "NomExactDeLaVM" | grep -i nested
```

- > Nested VT-x/AMD-V: enabled

Puis verifier dans la VM:

```bash
lscpu | grep Virtualization
```

- > `Virtualization: VT-x`
  > -> la virtualisation imbriquee est bien activee

<br>

#### Installation VirtualBox (Ubuntu)

Verifier la version de la distro et du Kelnel Linux:

```bash
lsb_release -a
```

- > Description: Ubuntu 24.04.3 LTS
  > Release: 24.04
  > Codename: noble

```bash
uname -r
```

- > 6.17.0-14-generic

<!-- ```bash
sudo apt update
sudo apt install -y dkms linux-headers-$(uname -r)
``` -->

Ajout du depot Officiel Oracle:

```bash
sudo apt update
sudo apt install -y wget gpg
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo gpg --dearmor --yes --output /usr/share/keyrings/oracle-vbox.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-vbox.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
sudo apt update
```

Du coup on va installer virtualbox-7.0, les dependances et compiler les modules kernel:
`Le noyau 6.17 nécessite les en-têtes exacts (linux-headers-6.17.0-14-generic) pour compiler les modules VirtualBox.`

```bash
sudo apt install -y virtualbox-7.1
```

```bash
sudo apt install -y build-essential dkms linux-headers-6.17.0-14-generic
sudo /sbin/vboxconfig

```

(ou dynamiquement)

```bash
sudo apt install -y build-essential dkms linux-headers-$(uname -r)
sudo /sbin/vboxconfig
```

Verification:

```bash
vboxmanage --version
```

#### Installation Vagrant

Installer les dépendances nécessaires

```bash
sudo apt update
sudo apt install -y wget gpg software-properties-common
```

Ajouter la clé GPG officielle de HashiCorp

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

Ajouter le dépôt officiel

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Mettre à jour et installer Vagrant

```bash
sudo apt update
sudo apt install -y vagrant
```

Verification:

```bash
vagrant --version
```

#### Vagrant a besoin d’un provider (comme VirtualBox, VMware, etc.).

Pour vérifier que Vagrant détecte bien VirtualBox :

```bash
vagrant plugin list
```

On devrait voir `vagrant-vbguest` (ou au moins pas d’erreur).
sinon:

```bash
vagrant plugin install vagrant-vbguest
vagrant plugin list
```

#### Creer/Init vagrantfile:

Create a base Vagrantfile:

```bash
vagrant init hashicorp/bionic64
```

Create a minimal Vagrantfile (no comments or helpers):

```bash
vagrant init -m hashicorp/bionic64
```

Create a new Vagrantfile, overwriting the one at the current path:

```bash
vagrant init -f hashicorp/bionic64
```

or simply:

```bash
vagrant init
```

#### Eventuel Probleme kvm est chargé et bloque VirtualBox.

```bash
lsmod | grep kvm
```

si kvm_intel ou kvm_amd apparet, il faut décharger KVM avant de lancer Vagrant (temporaire):

```bash
sudo modprobe -r kvm_intel
sudo modprobe -r kvm
```

OU blacklister les modules kvm (Solution LT):

```bash
echo -e "blacklist kvm\nblacklist kvm_intel" | sudo tee /etc/modprobe.d/blacklist-kvm.conf
```

Puis relancer `vagrant up`

#### Verifier que K3s est bien installe et fonctionnel:

###### Sur Server(Master):

`vagrant ssh balbeckeS` : connection ssh a la Vm Master:

```bash
sudo systemctl status k3s
```

###### Sur Agent:

`vagrant ssh balbeckeSW` : connection ssh a la Vm Agent:

```bash
sudo systemctl status k3s-agent
```

###### Sur Master verifier que l'Agent est bien enregistre:

`vagrant ssh balbeckeS` : connection ssh a la Vm Master:

```bash
sudo k3s kubectl get nodes
sudo k3s kubectl get nodes -o wide
```

### Part 2: K3s and three simple applications
First we need to edit our hosts file (Ubuntu: /etc/hosts) on the Host machine and add
```bash
192.168.56.110 app1.com
192.168.56.110 app2.com
192.168.56.110 app3.com
```

#### Check that everything is running properly 
Firts `vagrant ssh` to connect to the vagrant Vm
```bash
kubectl get nodes -o wide
kubectl get services
kubectl get pods
```
