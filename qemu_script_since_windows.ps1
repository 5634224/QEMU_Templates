# Path to UEFI/BIOS firmware
#$UEFI_FILE = "C:\Program Files\qemu\share\edk2-x86_64-code.fd"
$UEFI_FILE = "C:\Program Files\qemu\share\OVMF_CODE-pure-efi.fd"

# Path to disk file
# $DISK_FILE = "debian.qcow2"
$DISK_FILE = "debian-odoo.qcow2"
# $DISK_FILE = "linuxmint-cinnamon.qcow2"
# $DISK_FILE = "locos23-lxde.qcow2"

# Paths to ISO CD-ROM files
# $ISO_SO = "D:\Sistemas operativos\deepin-desktop-community-20.9-amd64.iso"
# $ISO_SO = "D:\Sistemas operativos\linuxmint-21.3-cinnamon-64bit.iso"
# $ISO_SO = "D:\Sistemas operativos\Loc-OS-23-LXDE-x86_64.iso"
# $ISO_SO = "D:\Sistemas operativos\debian-live-12.1.0-amd64-kde.iso"
$ISO_SO = "D:\Sistemas operativos\debian-12.4.0-amd64-netinst.iso"
$ISO_VIRTIO = "D:\Descargas\Descargas desde Linux\KVM Qemu\Drivers VirtIO\virtio-win-0.1.240.iso"

# Paths to shared folders
$SHARED_FOLDER = "/media/santiago/DATOS/"

# Path to remote-viewer client
$REMOTE_URL = "localhost"
$PORT_SPICE = "5930"
$PORT_VNC = "5900"
$REMOTE_URL_SPICE = "spice://${REMOTE_URL}:${PORT_SPICE}"
$REMOTE_URL_VNC = "${REMOTE_URL}::${PORT_VNC}"

# Create a 30 GB VirtIO disk if it does not exist
if (!(Test-Path $DISK_FILE)) {
  <# Action to perform if the condition is true #>
  qemu-img create -f qcow2 $DISK_FILE 30G
}


#===============================================================SPICE DISPLAY================================================================================
# Spice has better host & guest integration, such as shared clipboard, but it's slower than other display options, like SDL or GTK.

# Note 1: If you want to initialize with remote-viewer instead of spice-app through UNIX Socket, execute this in the Linux terminal: remote-viewer spice://localhost:5930
# and specify the port in the -spice port argument, like this:
# -spice port=$PORT_SPICE,disable-ticketing=on,agent-mouse=on \

# Note 2: -device virtio-vga doesn't work for Windows hosts. Graphics are broken in the VM.
# However -device virtio-gpu-pci doesn't have this problem, but mouse is grabbed despite having usb-tablet device added, and moves are rough.

#---------------------Spice with VirtIO 2D acceleration (is not enjoyable, doesn't have 3D acceleration, it's similar to QXL, or even worse)----------------------
# Start-Job -ScriptBlock { param($REMOTE_URL_SPICE) 
#   Start-Sleep -Miliseconds 500
#   remote-viewer $REMOTE_URL_SPICE
# } -ArgumentList $REMOTE_URL_SPICE
# & qemu-system-x86_64 `
#   -enable-kvm `
#   -m 4096 `
#   -cpu kvm64,+ssse3,+sse4.1,+sse4.2,+popcnt,+avx2,hv-passthrough,hv-relaxed,hv-time,hv-vapic,hv-no-nonarch-coresharing=auto `
#   -smp 4,sockets=1,cores=4,threads=1 `
#   -machine type=q35,accel=whpx:tcg,kernel-irqchip=off `
#   -rtc base=localtime `
#   -drive file="$DISK_FILE",if=virtio `
#   -drive file="$ISO_SO",media=cdrom `
#   -drive file="$ISO_VIRTIO",media=cdrom `
#   -boot order=cd,menu=on `
#   -net nic,model=virtio -net user `
#   -device intel-hda -device hda-duplex `
#   -monitor stdio `
#   -device qemu-xhci `
#   -device usb-tablet `
#   -device virtio-vga `
#   -spice port=${PORT_SPICE},disable-ticketing=on,agent-mouse=on `
#   -device virtio-serial-pci `
#   -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 `
#   -chardev spicevmc,id=spicechannel0,name=vdagent `

# Receive-Job -Job $q -> this line is old. Ignore it. It's only stopping the job stored in a variable called $q, but it's not necessary.

# --------------------Spice with QXL (balance between graphics performance and host & guest integration, such as shared clipboard) ---------------------
# Note 1: QXL works with Spice better than VirtIO Graphics. Too recommended if you want to use Spice and 3D Acceleration isn't important

# Start-Job -ScriptBlock { param($REMOTE_URL_SPICE) 
#   Start-Sleep -Miliseconds 500
#   remote-viewer $REMOTE_URL_SPICE 
# } -ArgumentList $REMOTE_URL_SPICE
# & qemu-system-x86_64.exe `
#   -enable-kvm `
#   -m 4096 `
#   -cpu kvm64,+ssse3,+sse4.1,+sse4.2,+popcnt,+avx2,hv-passthrough,hv-relaxed,hv-time,hv-vapic,hv-evmcs,hv-no-nonarch-coresharing=auto `
#   -smp 4,sockets=1,cores=4,threads=1 `
#   -machine type=q35,accel=whpx:tcg,kernel-irqchip=off `
#   -rtc base=localtime `
#   -drive file=$DISK_FILE,if=virtio `
#   -drive file="$ISO_SO",media=cdrom `
#   -drive file="$ISO_VIRTIO",media=cdrom `
#   -boot order=cd,menu=on `
#   -net nic,model=virtio -net user `
#   -device intel-hda -device hda-duplex `
#   -monitor stdio `
#   -device qemu-xhci `
#   -device usb-tablet `
#   -device qxl-vga `
#   -spice port=${PORT_SPICE},disable-ticketing=on `
#   -device virtio-serial-pci `
#   -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 `
#   -chardev spicevmc,id=spicechannel0,name=vdagent


#===============================================================VNC DISPLAY================================================================================
# Note 1: Depends on the VNC client, it can have more or less host & guest integration, such as shared clipboard.
# -device virtio-vga doesn't work for Windows hosts. Graphics are broken in the VM.

# --------------------VNC with VirtIO 2D (without 3D Acceleration, similar to QXL)---------------------
# Start-Job -ScriptBlock { param($REMOTE_URL_VNC) 
#   Start-Sleep -Miliseconds 500
#    tvnviewer $REMOTE_URL_VNC
# } -ArgumentList $REMOTE_URL_VNC
# qemu-system-x86_64.exe `
#   -enable-kvm `
#   -m 4096 `
#   -cpu kvm64,+ssse3,+sse4.1,+sse4.2,+popcnt,+avx2,hv-passthrough,hv-relaxed,hv-time,hv-vapic,hv-evmcs,hv-no-nonarch-coresharing=auto `
#   -smp 4,sockets=1,cores=4,threads=1 `
#   -machine type=q35,accel=whpx:tcg,kernel-irqchip=off `
#   -rtc base=localtime `
#   -drive file=$DISK_FILE,if=virtio `
#   -drive file="$ISO_SO",media=cdrom `
#   -drive file="$ISO_VIRTIO",media=cdrom `
#   -boot order=cd,menu=on `
#   -net nic,model=virtio -net user `
#   -device intel-hda -device hda-duplex `
#   -monitor stdio `
#   -device qemu-xhci `
#   -device usb-tablet `
#   -vga virtio `
#   -display none `
#   -vnc :0 `
#   -device virtio-serial-pci

# --------------------VNC with QXL --------------------------------
# Start-Job -ScriptBlock { param($REMOTE_URL_VNC) 
#   Start-Sleep -Miliseconds 500
#    tvnviewer $REMOTE_URL_VNC
# } -ArgumentList $REMOTE_URL_VNC
# qemu-system-x86_64.exe `
#   -enable-kvm `
#   -m 4096 `
#   -cpu kvm64,+ssse3,+sse4.1,+sse4.2,+popcnt,+avx2,hv-passthrough,hv-relaxed,hv-time,hv-vapic,hv-evmcs,hv-no-nonarch-coresharing=auto `
#   -smp 4,sockets=1,cores=4,threads=1 `
#   -machine type=q35,accel=whpx:tcg,kernel-irqchip=off `
#   -rtc base=localtime `
#   -drive file=$DISK_FILE,if=virtio `
#   -drive file="$ISO_SO",media=cdrom `
#   -drive file="$ISO_VIRTIO",media=cdrom `
#   -boot order=cd,menu=on `
#   -net nic,model=virtio -net user `
#   -device intel-hda -device hda-duplex `
#   -monitor stdio `
#   -device qemu-xhci `
#   -device usb-tablet `
#   -vga qxl `
#   -display none `
#   -vnc :0 `
#   -device virtio-serial-pci

#===============================================================GTK/SDL DISPLAYS================================================================================
# Note 1: GTK for me, doesn't work. Requires to install GTK libraries, but I don't know how to do it in Windows.
# Note 2: -device virtio-vga doesn't work for Windows hosts. Graphics are broken in the VM, but -device virtio-vga-gl doesn't have this problem.
# However, if you really want VirtIO 2D only, -device virtio-gpu-pci doesn't have this problem, but mouse is grabbed despite having usb-tablet device added, and moves are rough.

# ---------------GTK/SDL Display (no host & guest integrations, but VirtIO 3D Acceleration is more enjoyable)-------------------------------
# & qemu-system-x86_64 `
#   -enable-kvm `
#   -m 4096 `
#   -cpu kvm64,+ssse3,+sse4.1,+sse4.2,+popcnt,+avx2,hv-passthrough,hv-relaxed,hv-time,hv-vapic,hv-evmcs,hv-no-nonarch-coresharing=auto `
#   -smp 4,sockets=1,cores=4,threads=1 `
#   -machine type=q35,accel=whpx:tcg,kernel-irqchip=off `
#   -rtc base=localtime `
#   -drive file="$DISK_FILE",if=virtio `
#   -drive file="$ISO_SO",media=cdrom `
#   -drive file="$ISO_VIRTIO",media=cdrom `
#   -boot order=cd,menu=on `
#   -net nic,model=virtio -net user `
#   -device intel-hda -device hda-duplex `
#   -monitor stdio `
#   -device qemu-xhci `
#   -device usb-tablet `
#   -device virtio-vga-gl `
#   -display sdl,gl=on
#   # -display gtk,gl=on

# ---------------GTK/SDL Display (no host & guest integrations, but VirtIO Graphics, although without 3D Acceleration)-------------------------------
# qemu-system-x86_64 `
#   -enable-kvm `
#   -m 4096 `
#   -cpu kvm64,+ssse3,+sse4.1,+sse4.2,+popcnt,+avx2,hv-passthrough,hv-relaxed,hv-time,hv-vapic,hv-evmcs,hv-no-nonarch-coresharing=auto `
#   -smp 4,sockets=1,cores=4,threads=1 `
#   -machine type=q35,accel=whpx:tcg,kernel-irqchip=off `
#   -rtc base=localtime `
#   -drive file="$DISK_FILE",if=virtio `
#   -drive file="$ISO_SO",media=cdrom `
#   -drive file="$ISO_VIRTIO",media=cdrom `
#   -boot order=cd,menu=on `
#   -net nic,model=virtio -net user `
#   -device intel-hda -device hda-duplex `
#   -monitor stdio `
#   -device qemu-xhci `
#   -device usb-tablet `
#   -device virtio-vga `
#   -display sdl
# # -display gtk

# ---------------GTK/SDL Display (no host & guest integrations, using QXL instead of VirtIO Graphics, only 2D) -------------------------------
# & qemu-system-x86_64 `
#   -enable-kvm `
#   -m 4096 `
#   -cpu kvm64,+ssse3,+sse4.1,+sse4.2,+popcnt,+avx2,hv-passthrough,hv-relaxed,hv-time,hv-vapic,hv-evmcs,hv-no-nonarch-coresharing=auto `
#   -smp 4,sockets=1,cores=4,threads=1 `
#   -machine type=q35,accel=whpx:tcg,kernel-irqchip=off `
#   -rtc base=localtime `
#   -drive file="$DISK_FILE",if=virtio `
#   -drive file="$ISO_SO",media=cdrom `
#   -drive file="$ISO_VIRTIO",media=cdrom `
#   -boot order=cd,menu=on `
#   -net nic,model=virtio -net user `
#   -device intel-hda -device hda-duplex `
#   -monitor stdio `
#   -device qemu-xhci `
#   -device usb-tablet `
#   -device qxl-vga `
#   -display sdl `

# ---------------GTK/SDL Display (no host & guest integrations, using QXL graphics, minimal, useful for no-GUI OS, like Linux Servers) -------------------------------
& qemu-system-x86_64 `
  -enable-kvm `
  -m 1024 `
  -cpu kvm64,+ssse3,+sse4.1,+sse4.2,+popcnt,+avx2,hv-passthrough,hv-relaxed,hv-time,hv-vapic,hv-evmcs,hv-no-nonarch-coresharing=auto `
  -smp 4,sockets=1,cores=4,threads=1 `
  -machine type=q35,accel=whpx:tcg,kernel-irqchip=off `
  -rtc base=localtime `
  -drive file="$DISK_FILE",if=virtio `
  -drive file="$ISO_SO",media=cdrom `
  -drive file="$ISO_VIRTIO",media=cdrom `
  -boot order=cd,menu=on `
  -net nic,model=virtio -net user,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80,hostfwd=tcp::8069-:8069 `
  -monitor stdio `
  -device qxl-vga `
  -display none `
#-display gtk,show-cursor=on,zoom-to-fit=on ` -> for installation of OS and SSH Server. After that, you can put -display none

#======================================== FEATURES THAT CAN BE ADDED TO THE VIRTUAL MACHINE ========================================
# Accelerators:
# -machine type=q35,accel=whpx ` se puede sustituir whpx por tcg, pero irá mucho más lento.
# También se puede poner como -machine type=q35,accel=whpx:tcg, por si falla whpx, que use tcg

# USB support has several options:
#   -device piix4-usb-uhci \ -> To enable USB 1.1 support.
#   -usb \ -> To enable USB 1.1 and USB 2.0 support (most known and most supported).
#   -device usb-ehci \ -> To enable USB 1.1 and USB 2.0 support.
#   -device nec-usb-xhci \ -> To enable USB 1.1, USB 2.0 and USB 3.0 support.
#   -device qemu-xhci \ -> To enable USB 1.1, USB 2.0 and USB 3.0 support. Uses less resources (especially CPU). It's prefered than other for any guest OS released around 2010 or later.

# Managing and mantaining the virtual machine:
#   -monitor stdio \ -> To manage the virtual machine through the terminal while it is running.

# Boot order explanations
#  -boot order=cd,menu=on \
# First, a first menu will appear where you can choose which unit you want to boot to.
# If we select nothing and the countdown ends, the sequence order of the order argument will follow.
# c = hard disk. d = CD-ROM

# Get info about the hard disk:
# qemu-img info $DISK_FILE

# Compression of the disk image:
#qemu-img.exe convert -O qcow2 $DISK_FILE zipped.qcow2 -c

# Reduce the size of the disk image:
# 1st: qemu-img resize imagen.qcow2 20
# 2nd: Start VM and reduce the size of the partition with GParted or fdisk. Then, synchronize the changes in the file system table.
# 3rd: qemu-img convert -o preallocation=metadata <nombre_imagen.qcow2> <imagen_redimensionada.qcow2>

# Snapshots (2 ways):
# 1st:
# qemu-img snapshot -c "my-snapshot" my-file.qcow2
# Additional options: -a "my-snapshot" -> To return the image to the snapshot. -l -> To list the snapshots. -d "my-snapshot" -> To delete the snapshot.
# 2nd:
# Run the VM with de -monitor stdio option and type the following commands:
# monitor
# savevm my-snapshot
# Additional commands: loadvm my-snapshot -> To load the snapshot. info snapshots -> To list the snapshots delvm my-snapshot -> To delete the snapshot.


#======================================== EXPERIMENTAL FEATURES ========================================
# UEFI firmware: add the -bios argument to the command line, like this:
# -bios $UEFI_FILE \
# -cpu [...]],hv-reset -> put it only in presence of -bios (I mean, UEFI)

#---------------------------------------- Shared Folders, 1st method ----------------------------------------
#  -fsdev local,id=fsdev0,path="$SHARED_FOLDER",security_model=mapped \
#  -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \

#---------------------------------------- Shared Folders, 2nd method ----------------------------------------
#  -virtfs local,path="$SHARED_FOLDER",mount_tag=host0,security_model=passthrough,id=host0 \

# ---------------------------------------- Bridged host-only network ----------------------------------------
# It doesn't work in Windows hosts with precompiled binaries. It's only for Linux hosts.
# See the file Linux_guest_post_installation_recommendations.txt

# -netdev bridge,id=n1 -device virtio-net-pci,netdev=n1 `
# Other tests:
# -netdev tap,id=nd0,ifname=tap0 -device e1000,netdev=nd0 `
# -netdev user,id=mynet0,net=192.168.76.0/24,dhcpstart=192.168.76.9 -device virtio-net,netdev=mynet0 `

# While I'm researching bridged connections, if you want to connect via SSH or port 80, you can use: -net user,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80

#======================================== CREDITS ========================================
# https://sl.bing.net/fh4vBKmcDaC -> Copilot, the AI that helped me to write this script.
# https://www.qemu.org/docs/master/system/invocation.html -> general QEMU documentation and options of the command line
#https://www.linux-kvm.org/page/WindowsGuestDrivers -> for VirtIO drivers in Windows guests
#https://askubuntu.com/questions/1238523/enabling-opengl-in-windows-10-guest-vm-in-qemu
#https://github.com/pal1000/mesa-dist-win?tab=readme-ov-file#downloads
#https://github.com/pal1000/mesa-dist-win/releases/tag/22.3.5
#https://www.youtube.com/watch?v=DYpaX4BnNlg -> for Bridged host-only network