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
