# GR - Evaluating Confidential Computing with Unikernels

Taken from [dimstav23/GDPRuler/tree/main/AMD_SEV_SNP](https://github.com/dimstav23/GDPRuler/tree/main/AMD_SEV_SNP)

### 3. Prepare the host toolchain
Compile the custom OVMF and QEMU provided by AMD:

```bash
./build.sh qemu
./build.sh ovmf
```

### 4. Prepare an AMD SEV-SNP guest.
- You need to have cloud-config file and a network-config file for your VM, similar to those in the [config](.config/) folder.
- If you wish to have ssh connection to your VMs, you can adapt the cloud-config files and include your ssh keys, so that cloud-init sets them up automatically in the VM. Example cloud-init configurations that include the placeholders for ssh keys can be found in `.config/`
- The [`prepare_net_cfg.sh`](./prepare_net_cfg.sh) script takes as a parameter the virtual bridge where the VMs will be connected to and modifies the IP prefix in the network configuration (given as a secord parameter) appropriately.

Follow the next set of commands to launch an SEV-SNP guest.

```bash
wget https://cloud-images.ubuntu.com/kinetic/current/kinetic-server-cloudimg-amd64.img 
mkdir images
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./usr/local/bin/qemu-img convert kinetic-server-cloudimg-amd64.img ./images/sev-server.img
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH  ./usr/local/bin/qemu-img resize ./images/sev-server.img +20G 
./prepare_net_cfg.sh -br virbr0 -cfg ./config/network-config-server.yml
sudo cloud-localds -N ./config/network-config-server.yml ./images/server-cloud-config.iso ./config/cloud-config-server
mkdir OVMF_files
cp ./usr/local/share/qemu/OVMF_CODE.fd ./OVMF_files/OVMF_CODE_server.fd
cp ./usr/local/share/qemu/OVMF_VARS.fd ./OVMF_files/OVMF_VARS_server.fd
```

Connect to qemu monitor using `socat -,echo=0,icanon=0 unix-connect:monitor` (socket created by `launch_qemu.sh`)

### 5. Launch an AMD SEV-SNP guest.
```bash
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./launch-qemu.sh \
  -hda ./images/sev-server.img \
  -cdrom ./images/server-cloud-config.iso \
  -sev-snp \
  -bridge virbr0 \
  -bios ./OVMF_files/OVMF_CODE_server.fd \
  -bios-vars ./OVMF_files/OVMF_VARS_server.fd
```

### 6. Inside the guest VM, verify that AMD SEV-SNP is enabled:
`sudo dmesg | grep snp -i ` should indicate `Memory Encryption Features active: AMD SEV SEV-ES SEV-SNP`

### 7. Networking: 
In step 5 above, we use the parameter `-bridge virbr0`, so that our VMs use the virtual network bridge `virbr0`. 
Our script [`prepare_net_cfg.sh`](./prepare_net_cfg.sh) checks the given virtual bridge and adjust the prefix of the IP declared in the network configuration file. Example configuration files are given in the [cloud_configs](./cloud_configs/) folder. They are used mainly to pre-determine the IPs of the VMs in the network.

### Manual ssh connection setup
- connect using ssh `ubuntu@192.168.122.48`

### Useful links
- Sample cloud-config and network-config for cloud-init can be found [here](https://gist.github.com/itzg/2577205f2036f787a2bd876ae458e18e).
- Additional options of the cloud-config, such as running a specific command during initialization, can be found [here](https://www.digitalocean.com/community/tutorials/how-to-use-cloud-config-for-your-initial-server-setup)
- AMD [host kernels](https://github.com/AMDESE/linux) -- check branch names for each feature (e.g., SEV, ES, SNP)
- [QEMU](https://github.com/AMDESE/qemu) provided by AMD
- [OVMF](https://github.com/AMDESE/ovmf) provided by AMD
- [SVSM](https://github.com/AMDESE/linux-svsm) repository