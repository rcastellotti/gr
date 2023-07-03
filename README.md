# GR - Evaluating Confidential Computing with Unikernels

## Prepare the host toolchain
Compile the custom OVMF and QEMU provided by AMD:

```bash
./build.sh
```

## Misc

- You need to have cloud-config file and a network-config file for your VM, similar to those in the [config](.config/) folder.
- If you wish to have ssh connection to your VMs, you can adapt the cloud-config files and include your ssh keys, so that cloud-init sets them up automatically in the VM. Example cloud-init configurations that include the placeholders for ssh keys can be found in `config/`
- The [`prepare_net_cfg.sh`](./prepare_net_cfg.sh) script takes as a parameter the virtual bridge where the VMs will be connected to and modifies the IP prefix in the network configuration (given as a secord parameter) appropriately.
- Download an ubuntu image: `wget https://cloud-images.ubuntu.com/kinetic/current/kinetic-server-cloudimg-amd64.img`

## Prepare a NOSEV guest

```bash
qemu-img convert kinetic-server-cloudimg-amd64.img nosev.img
qemu-img resize nosev.img +20G
mkdir OVMF_files
sudo cloud-localds cloud-config-nosev.iso config/cloud-config-nosev.yml
cp ./usr/local/share/qemu/OVMF_CODE.fd ./OVMF_files/OVMF_CODE_nosev.fd
cp ./usr/local/share/qemu/OVMF_VARS.fd ./OVMF_files/OVMF_VARS_nosev.fd
```
## Launch a NOSEV guest. 

```bash
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./nosev.sh
```

## Prepare an AMD SEV-SNP guest.

```bash
qemu-img convert kinetic-server-cloudimg-amd64.img sev.img
qemu-img resize sev.img +20G
mkdir OVMF_files
sudo cloud-localds cloud-config-sev.iso ./config/cloud-config-sev.yml
cp ./usr/local/share/qemu/OVMF_CODE.fd ./OVMF_files/OVMF_CODE_sev.fd
cp ./usr/local/share/qemu/OVMF_VARS.fd ./OVMF_files/OVMF_VARS_sev.fd
```

## Launch an AMD SEV-SNP guest. 

```bash
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./sev.sh
```

## Inside the guest VM, verify that AMD SEV-SNP is enabled:
`sudo dmesg | grep snp -i ` should indicate `Memory Encryption Features active: AMD SEV SEV-ES SEV-SNP`

## Interact with the machines
- SEV machine: connect using ssh `ssh -p 2222 ubuntu@localhost`
- NOSEV machine: connect using ssh `ssh -p 2223 ubuntu@localhost`

### Useful links
- Sample cloud-config and network-config for cloud-init can be found [here](https://gist.github.com/itzg/2577205f2036f787a2bd876ae458e18e).
- Additional options of the cloud-config, such as running a specific command during initialization, can be found [here](https://www.digitalocean.com/community/tutorials/how-to-use-cloud-config-for-your-initial-server-setup)
- AMD [host kernels](https://github.com/AMDESE/linux) -- check branch names for each feature (e.g., SEV, ES, SNP)
- [QEMU](https://github.com/AMDESE/qemu) provided by AMD
- [OVMF](https://github.com/AMDESE/ovmf) provided by AMD


```
## qemu-img create -f qcow2 nvm.img 10G
# -drive file=nvm.img,if=none,id=nvm \
# -device nvme,serial=deadbeef,drive=nvm

## virtio-blk:
## qemu-img create -f qcow2 blk.img 10G
# -device virtio-blk-pci,drive=drive0,id=virtblk0,num-queues=4
# -drive file=blk.img,if=none,id=drive0

## virtio-scsi:
## qemu-img create -f qcow2 scsi.img 10G
-device virtio-scsi-pci,id=scsi
-device scsi-hd,drive=hd
-drive if=none,id=hd,file=scsi.img
```
