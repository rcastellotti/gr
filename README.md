# GR - AMD Confidential Computing Technologies Evaluation Report


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
- [Canonical cloud-init documentation](https://cloudinit.readthedocs.io/en/latest/reference/examples.html)
- [QEMU](https://github.com/AMDESE/qemu) provided by AMD
- [OVMF](https://github.com/AMDESE/ovmf)
- <http://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt>
- <https://www.kernel.org/doc/html/v5.6/virt/kvm/amd-memory-encryption~.html>
- <https://www.qemu.org/docs/master/system/i386/amd-memory-encryption.html>
- <https://www.amd.com/content/dam/amd/en/documents/developer/58207-using-sev-with-amd-epyc-processors.pdf>
- <https://www.amd.com/en/developer/sev.html>

