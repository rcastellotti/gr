./usr/local/bin/qemu-system-x86_64 \
  -enable-kvm \
  -cpu EPYC-v4,host-phys-bits=true \
  -smp 16 -m 16G \
  -machine type=q35 \
  -drive if=pflash,format=raw,unit=0,file=/scratch/roberto/gr/usr/local/share/qemu/OVMF_CODE.fd,readonly=on\
  -drive if=pflash,format=raw,unit=1,file=./nosev.fd \
  -drive file=cloud-config-nosev.iso,media=cdrom,index=0 \
  -drive file=nosev.img,if=none,id=disk0,format=raw \
  -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true \
  -device scsi-hd,drive=disk0 \
  -nographic \
  -monitor pty \
  -monitor unix:monitor,server,nowait \
  -netdev type=tap,script=no,downscript=no,id=net0,ifname=tap1 \
  -device virtio-net-pci,mac=52:54:00:cd:e6:01,netdev=net0,disable-legacy=on,iommu_platform=true,romfile= 



./usr/local/bin/qemu-system-x86_64  
  -enable-kvm \
  -cpu EPYC-v4,host-phys-bits=true \
  -smp 16 \
  -machine type=q35,confidential-guest-support=sev0,memory-backend=ram1,kvm-type=protected,vmport=off \
  -object memory-backend-memfd-private,id=ram1,size=16G,share=true \
  -object sev-snp-guest,id=sev0,policy=0x30000,cbitpos=51,reduced-phys-bits=1,init-flags=0,host-data=b2l3bmNvd3FuY21wbXA \
  -drive if=pflash,format=raw,unit=0,file=/scratch/roberto/gr/OVMF_files/OVMF_CODE_sev.fd,readonly=on \
  -drive if=pflash,format=raw,unit=1,file=./sev.fd -drive file=cloud-config-sev.iso,media=cdrom,index=0 \
  -drive file=sev.img,if=none,id=disk0,format=raw \
  -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true \
  -device scsi-hd,drive=disk0 \
  -nographic \
  -monitor pty \
  -monitor unix:monitor,server,nowait \
  -netdev type=tap,script=no,downscript=no,id=net0,ifname=tap1 \
  -device virtio-net-pci,mac=52:54:00:cd:e6:01,netdev=net0,disable-legacy=on,iommu_platform=true,romfile=




  ./usr/local/bin/qemu-system-x86_64 -enable-kvm -cpu EPYC-v4,host-phys-bits=true -smp 16 -machine type=q35,confidential-guest-support=sev0,memory-backend=ram1,kvm-type=protected,vmport=off -object memory-backend-memfd-private,id=ram1,size=16G,share=true -object sev-snp-guest,id=sev0,policy=0x30000,cbitpos=51,reduced-phys-bits=1,init-flags=0,host-data=b2l3bmNvd3FuY21wbXA -drive if=pflash,format=raw,unit=0,file=/scratch/roberto/gr/OVMF_files/OVMF_CODE_sev.fd,readonly=on -drive if=pflash,format=raw,unit=1,file=./sev.fd -drive file=cloud-config-sev.iso,media=cdrom,index=0 -drive file=sev.img,if=none,id=disk0,format=raw -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true -device scsi-hd,drive=disk0 -nographic -monitor pty -monitor unix:monitor,server,nowait -netdev type=tap,script=no,downscript=no,id=net0,ifname=tap1 -device virtio-net-pci,mac=52:54:00:cd:e6:01,netdev=net0,disable-legacy=on,iommu_platform=true,romfile= 