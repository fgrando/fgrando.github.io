# QEMU on Windows
05/Mar/2023

Steps to setup a running PPC vm in Windows with QEMU.

### Get QEMU
[Windows releases](https://qemu.weilnetz.de/w64/)

### Get Lubuntu 14
[Lubuntu 14 releases](http://mirror.datto.com/ubuntu-releases/lubuntu/releases/14.04.4/release/)

### Add QEMU to path
`set PATH=%PATH%;"C:\Program Files\qemu"`

### Create Disk
`qemu-img create -f qcow2 be1/lubuntu14.qcow2 16G`

Note: the disks is kept inside `./be1` folder.

### Install OS
`qemu-system-ppc -L pc-bios -boot d -M mac99,via=pmu -m 1024 -hda be1/lubuntu14.qcow2 -cdrom lubuntu-14.04.5-desktop-powerpc.iso`

### Run OS
`qemu-system-ppc -L pc-bios -boot c -prom-env "boot-device=hd:,\yaboot" -prom-env "boot-args=conf=hd:,\yaboot.conf" -M mac99,via=pmu -m 2048 -hda be1/lubuntu14.qcow2 -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::10022-:22`

### Connect via SSH
`ssh user@localhost -p 10022`


### ARM
Based on this post this are the commands for a quick ARM setup: https://gist.github.com/billti/d904fd6124bf6f10ba2c1e3736f0f0f7

`start.bat`:

```batch

REM Ubuntu & BIOS images: 
REM https://cloud-images.ubuntu.com/releases/xenial/release/
REM https://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/

REM Expanding the image size by 8GB
REM shutdown the vm
REM "c:\Program Files\qemu\qemu-img.exe" resize ubuntu-16.04-server-cloudimg-arm64-uefi1.img +8G
REM start the vm, ssh into it and enter the following command
REM sudo growpart /dev/vda 1
REM reboot

REM ssh -l ubuntu localhost -p 22022 asdfqwer

"c:\Program Files\qemu\qemu-system-aarch64.exe" ^
-m 2048 ^
-cpu cortex-a72 -smp 4 ^
-nographic ^
-M virt ^
-bios QEMU_EFI.fd ^
-drive if=none,file=ubuntu-16.04-server-cloudimg-arm64-uefi1.img,id=hd0 ^
-device virtio-blk-device,drive=hd0 ^
-drive file=user-data.img,format=raw ^
-device virtio-net-device,netdev=net0 ^
-netdev user,hostfwd=tcp:127.0.0.1:22022-:22,id=net0

```

### i386
```batch
REM Create disk
REM "c:\Program Files\qemu\qemu-img.exe" create hdd_i386.img 20G

REM Install commands
REM "c:\Program Files\qemu\qemu-system-i386.exe" ^
REM -m 2048 ^
REM -boot d -cdrom ubuntu-16.04.6-server-i386.iso ^
REM -hda hdd_i386.img ^
REM -device e1000,netdev=net0 ^
REM -netdev user,id=net0,hostfwd=tcp::22386-:22

REM ssh -l user localhost -p 22386 user

REM run
"c:\Program Files\qemu\qemu-system-i386.exe" ^
-m 2048 ^
-boot c ^
-nographic ^
-hda hdd_i386.img ^
-device e1000,netdev=net0 ^
-netdev user,id=net0,hostfwd=tcp::22386-:22
```

### PowerPc64
```batch
REM Create disk
REM "c:\Program Files\qemu\qemu-img.exe" create  hdd_ppc64el.img 20G

REM Install commands
REM "c:\Program Files\qemu\qemu-system-ppc64.exe" ^
REM -m 2G ^
REM -M pseries -smp cores=1,threads=1 ^
REM -cdrom ubuntu-16.04.4-server-ppc64el.iso ^
REM -device spapr-vscsi -drive file=hdd_ppc64el.img ^
REM -device e1000,netdev=net0 ^
REM -netdev user,id=net0,hostfwd=tcp::22064-:22

REM -nographic -nodefaults -serial stdio ^

REM ssh -l user localhost -p 22064 user

REM run
"c:\Program Files\qemu\qemu-system-ppc64.exe" ^
-m 2G ^
-nographic ^
-M pseries -smp cores=1,threads=1 ^
-device spapr-vscsi -drive file=hdd_ppc64el.img ^
-device e1000,netdev=net0 ^
-netdev user,id=net0,hostfwd=tcp::22064-:22
```