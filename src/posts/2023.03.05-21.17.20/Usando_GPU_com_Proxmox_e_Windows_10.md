# Usando GPU com Proxmox e Windows 10
05/Mar/2023

Eu montei um PC novo, com um HW razoável para poder brincar com proxmox e umas VMs. Veio então a ideia de rodar uma VM com windows e uns jogos. E aproveitando já testar como é o compartilhamento dessas GPUs. Meus testes foram com GtX 1050Ti.

Existem muitos procedimentos na web, coisas novas e antigas misturadas, passos configurando coisas que eu não sei se fazem alguma diferença. No fim, funcionou e essas notas tem o objetivo de economizar tempo para o meu eu futuro.




# Install Proxmox
Baixei a versão mais atual do PVE: Proxmox virtual environment 7.1 (https://www.proxmox.com/en/downloads/item/proxmox-ve-7-1-iso-installer)

Começamos com o proxmox já não reconhecendo alguns dispositivos da minha placa mãe (bluetooth, wifi...).




### Sources
```bash
root@munaia:~# cat /etc/apt/sources.list:
deb http://ftp.de.debian.org/debian bullseye main contrib
deb http://ftp.de.debian.org/debian bullseye-updates main contrib
# security updates
deb http://security.debian.org bullseye-security main contrib
# Free PVE repo:
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
```

Comentei esse porque não uso a versão paga:
```bash
root@munaia:~# cat /etc/apt/sources.list.d/pve-enterprise.list
#deb https://enterprise.proxmox.com/debian/pve bullseye pve-enterprise
```




### Criando o ZFS
Primeiro, apagar todas as informações de partição dos discos usados (`fdisk /dev/sdc`)

Depois, com os discos zerados, vai em `Create ZFS` e adiciona eles. Escolhi `RAIDZ` e 4 SSDs de 1 TB resultou em espaço usável de 3TB.




### Habilitando VLAN
Em network, selecionar a bridge e marcar o checkbox "VLAN aware"




### Adicionei um network share
Nesse share tem imagens e arquivos que vou precisar depois.
Tive problema com o acesso, é um samba share em outro linux. Para testar a conectividade pode ser usado o seguinte comando:
```bash
/usr/bin/smbclient //<server>/share -d 0 -m smb3 -U <username> -c echo 1 0
```

E para ver quais realmente são os usuários no samba:
```bash
sudo pdbedit -L -v
```




## IOMMU Precisa ser habilitado
### Na BIOS
- IOMMU = enabled
- NX mode = enabled
- SVM mode = enabled
- VTx ou VTd também.

### No grub
```bash
root@munaia:~# cat /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'

GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
#GRUB_CMDLINE_LINUX_DEFAULT="quiet"
#GRUB_CMDLINE_LINUX_DEFAULT="amd_iommu=on" # esta linha devia ser suficiente, mas nao tive tempo de testar entao estou usando a abaixo (que ja divide os PCIs):
GRUB_CMDLINE_LINUX_DEFAULT="amd_iommu=on pcie_acs_override=downstream,multifunction video=efifb:off quiet splash"

(demais linhas ocultas)
```

### Blacklist drivers
Verificar que os seguintes drivers não serão carregados
```bash
root@munaia:~# cat /etc/modprobe.d/pve-blacklist.conf
# This file contains a list of modules which are not supported by Proxmox VE

# nidiafb see bugreport https://bugzilla.proxmox.com/show_bug.cgi?id=701
blacklist nvidiafb

root@munaia:~# cat /etc/modprobe.d/vfio.conf
blacklist nouveau
blacklist nvidia
blacklist nvidiafb
```

Por via das dúvidads desativamos o output da placa

Rodar o seguinte scripts e anotar o id da placa:
```bash
root@munaia:~# cat show-pci.sh
#!/bin/bash
shopt -s nullglob
for g in /sys/kernel/iommu_groups/*; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```

No meu caso:
```
IOMMU Group 10:
        01:00.1 Audio device [0403]: NVIDIA Corporation GP107GL High Definition Audio Controller [10de:0fb9] (rev a1)
IOMMU Group 9:
        01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GP107 [GeForce GTX 1050 Ti] [10de:1c82] (rev a1)
```

Então:
```bash
root@munaia:~# echo "options vfio-pci ids=10de:1c82,10de:0fb9 disable_vga=1" >> /etc/modprobe.d/vfio.conf
```

Finalmente:
```bash
root@munaia:~# update-initramfs -u
root@munaia:~# reboot
```

### Criar a VM de windows
- Machine: q35
- BIOS UEFI
- Display: Default
- Adicionar o PCI Device com id da GTX (não precisa o da placa de som)
- Marcar "All functions" & "PCI-Express". Não marcar no "Primary GPU" (apenas depois do windows estar instalado para evitar ficar sem video)

# Importate
Por algum motivo, o driver de som (que é da NVIDIA na VM) as vezes dá uma engasgada (ao usar diretamente a saída HDMI da VM) mas acessando por RDP funciona bem.