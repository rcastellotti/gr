# tinyben

tinyben is an attempt to create a bencharking suite, similar to [phoronix-test-suite](https://www.phoronix-test-suite.com/), but simpler and easier to use. tinyBen is designed to ben <1000 lines of code [1](https://github.com/geohot/minikeyvalue).

We are always supporting (at least) the latest Ubuntu LTS version.

## usage

```bash
python3 -m venv venv
pip3 install -r requirements.txt
python3 run.py 
```
If you need to run with root permission (`apt-get` is part of a benchmark) run instead `sudo venv/bin/python3 runner.py`

https://github.com/rcastellotti/tinyben/blob/6cc00939da60bbf2cf6a6a01fc267c9609f7b078/run.py#L1-L27

## sample run output

![image](https://github.com/rcastellotti/tinyben/assets/43064224/004ce34b-a4f8-4b40-99f9-7d103813182d)

## instructions to launch an Ubuntu 22.04 qemu vm
```bash
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
sudo qemu-img convert jammy-server-cloudimg-amd64.img jammy.img
sudo qemu-img resize jammy.img +20G
sudo cloud-localds cloud-config-tinyben.iso cloud-config-tinyben.yml
```

`cloud-config-tinyben.yml`
```
password: tb
hostname: tinyben
chpasswd: { expire: False }
ssh_pwauth: True
final_message: "Cloud init is done!"
```

```bash
stty intr ^] &&
sudo qemu-system-x86_64 \
 -enable-kvm \
 -smp 32 \
 -m 32G \
 -drive file=jammy.img,if=none,id=disk0,format=raw \
 -drive file=cloud-config-tinyben.iso,media=cdrom,index=0 \
 -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true \
 -device scsi-hd,drive=disk0 \
 -nographic \
 -net user,hostfwd=tcp::10022-:22 \
 -net nic 

```
