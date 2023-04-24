# GR - Evaluating Confidential Computing with Unikernels

Taken from [dimstav23/GDPRuler/tree/main/AMD_SEV_SNP](https://github.com/dimstav23/GDPRuler/tree/main/AMD_SEV_SNP)

### 3. Prepare the host toolchain
Compile the custom OVMF and QEMU provided by AMD:

```bash
./build.sh qemu
./build.sh ovmf
```

**Note:** 

For SNP, this setup has been tested with 
- `qemu`: snp-latest branch provided by AMD ([link](https://github.com/AMDESE/qemu/tree/snp-latest)) -- the latest tested commit is [here](https://github.com/AMDESE/qemu/commit/b3721248d18d1ed56a75df2528591b2f1505660f)
- `ovmf`: snp-latest branch provided by AMD ([link](https://github.com/AMDESE/ovmf/tree/snp-latest)) -- the latest tested commit is [here](https://github.com/AMDESE/ovmf/commit/e1a623d4ac86024284c53f7e577b02b45ffb8b2f)

For SVSM, this setup has been tested with 
- `qemu`: svsm-preview-v2 branch provided by AMD ([link](https://github.com/AMDESE/qemu/tree/svsm-preview-v2)) -- the latest tested commit is [here](https://github.com/AMDESE/qemu/commit/2c6dbe30d6da1cac18ff6dba81087179ebd3b8a7)
- `ovmf`: svsm-preview-v2 branch provided by AMD ([link](https://github.com/AMDESE/ovmf/tree/svsm-preview-v2)) -- the latest tested commit is [here](https://github.com/AMDESE/ovmf/commit/db753e31773ae52ea7f2b320fc7a57c5ef6b46d0)


### 4. Prepare an AMD SEV-SNP guest.
- You need to have cloud-config file and a network-config file for your VM, similar to those in the [config](.config/) folder.
- If you wish to have ssh connection to your VMs, you can adapt the cloud-config files and include your ssh keys, so that cloud-init sets them up automatically in the VM. Example cloud-init configurations that include the placeholders for ssh keys can be found in `.config/`

- The [`prepare_net_cfg.sh`](./prepare_net_cfg.sh) script takes as a parameter the virtual bridge where the VMs will be connected to and modifies the IP prefix in the network configuration (given as a secord parameter) appropriately.

Follow the next set of commands to launch an SEV-SNP guest (tested with ubuntu 22.04 cloud img).

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

**Important note:** 
- Each VM requires a separate `.img` and `OVMF_*.fd` files.
- To avoid any problems, you have to use a distro with text-based installer, otherwise your launched VM might stuck ([issue](https://github.com/AMDESE/AMDSEV/issues/38)).

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

**Important notes:**
- Be a bit patient, the network configuration above takes some seconds. If, in the meantime, you encounter a log-in prompt that does not accept your credentials, you can try Ctrl+C which will detach from the current tty and will allow the cloud-init to finish properly. Then you can log in normally.
It is a known "issue". 
- Follow the same process for the creation of a client vm (if you want/need to).
You need a different `.img`, and to adapt the network configuration appropriately to reserve a different IP.
Configuration examples are given in the [cloud_configs](./cloud_configs/) folder.
- The provided scripts are modified versions of those provided by AMD [here](https://github.com/AMDESE/linux-svsm). The patched versions are also in [this](https://github.com/dimstav23/linux-svsm/tree/gdpruler_patched_build) repository.

### 6. Inside the guest VM, verify that AMD SEV-SNP is enabled:
`sudo dmesg | grep snp -i ` should indicate `Memory Encryption Features active: AMD SEV SEV-ES SEV-SNP`

### 7. Networking: 
In step 5 above, we use the parameter `-bridge virbr0`, so that our VMs use the virtual network bridge `virbr0`. 
Our script [`prepare_net_cfg.sh`](./prepare_net_cfg.sh) checks the given virtual bridge and adjust the prefix of the IP declared in the network configuration file. Example configuration files are given in the [cloud_configs](./cloud_configs/) folder. They are used mainly to pre-determine the IPs of the VMs in the network.

### Manual ssh connection setup
- After you make sure that networking works fine and you can reach the VM guest from the host, you can log-in the VM using ssh (after placing your ssh keys in the `~/.ssh/autorhized_keys` file of the guest VM).

### Useful links
- Sample cloud-config and network-config for cloud-init can be found [here](https://gist.github.com/itzg/2577205f2036f787a2bd876ae458e18e).
- Additional options of the cloud-config, such as running a specific command during initialization, can be found [here](https://www.digitalocean.com/community/tutorials/how-to-use-cloud-config-for-your-initial-server-setup)
- AMD [host kernels](https://github.com/AMDESE/linux) -- check branch names for each feature (e.g., SEV, ES, SNP)
- [QEMU](https://github.com/AMDESE/qemu) provided by AMD
- [OVMF](https://github.com/AMDESE/ovmf) provided by AMD
- [SVSM](https://github.com/AMDESE/linux-svsm) repository
