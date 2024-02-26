#!/bin/bash

# Path to UEFI/BIOS firmware
UEFI_FILE="/usr/share/OVMF/OVMF_CODE.fd"

# Path to disk file
# DISK_FILE="deepin.qcow2"
DISK_FILE="debian.qcow2"
# DISK_FILE="linuxmint-cinnamon.qcow2"
# DISK_FILE="win10.qcow2"

# Paths to ISO CD-ROM files
ISO_SO="/media/santiago/DATOS/Sistemas operativos/deepin-desktop-community-20.9-amd64.iso"
# ISO_SO="/media/santiago/2_TB/Sistemas operativos/MiniOS10 LTSC-21H2 v2023.04 x64.iso"
ISO_VIRTIO="/media/santiago/DATOS/Descargas/Descargas desde Linux/KVM Qemu/Drivers VirtIO/virtio-win-0.1.240.iso"

# Paths to shared folders
SHARED_FOLDER="/media/santiago/DATOS/"

# Path to remote-viewer client
REMOTE_URL="localhost"
PORT_SPICE="5930"
PORT_VNC="5900"
REMOTE_URL_SPICE="spice://$REMOTE_URL:$PORT_SPICE"
REMOTE_URL_VNC="$REMOTE_URL::$PORT_VNC"

# Create a 30 GB VirtIO disk if it does not exist
if [ ! -f $DISK_FILE ]; then
  qemu-img create -f qcow2 $DISK_FILE 30G
fi

#===============================================================SPICE DISPLAY================================================================================
# Spice has better host & guest integration, such as shared clipboard, but it's slower than other display options, like SDL or GTK.

# Note 1: If you want to initialize with remote-viewer instead of spice-app through UNIX Socket, execute this in the Linux terminal: remote-viewer spice://localhost:5930
# and specify the port in the -spice port argument, like this:
# -spice port=$PORT_SPICE,disable-ticketing=on,agent-mouse=on \

# --------------------Spice with VirtIO 3D acceleration (is not enjoyable) ---------------------
# qemu-system-x86_64 \
#   -enable-kvm \
#   -m 4096 \
#   -cpu host \
#   -smp 4,sockets=1,cores=4,threads=1 \
#   -machine type=q35 \
#   -drive file="$DISK_FILE",if=virtio \
#   -drive file="$ISO_SO",media=cdrom \
#   -drive file="$ISO_VIRTIO",media=cdrom \
#   -boot order=cd,menu=on \
#   -device intel-hda -device hda-duplex \
#   -monitor stdio \
#   -device qemu-xhci \
#   -device usb-tablet \
#   -device virtio-vga-gl \
#   -display spice-app,gl=on \
#   -spice disable-ticketing=on,gl=on \
#   -device virtio-serial-pci \
#   -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
#   -chardev spicevmc,id=spicechannel0,name=vdagent \

#---------------------Spice with VirtIO 2D acceleration (more enjoyable, but without 3D Acceleration, it's very similar to QXL)----------------------
# qemu-system-x86_64 \
#   -enable-kvm \
#   -m 4096 \
#   -cpu host \
#   -smp 4,sockets=1,cores=4,threads=1 \
#   -machine type=q35 \
#   -drive file="$DISK_FILE",if=virtio \
#   -drive file="$ISO_SO",media=cdrom \
#   -drive file="$ISO_VIRTIO",media=cdrom \
#   -boot order=cd,menu=on \
#   -device intel-hda -device hda-duplex \
#   -monitor stdio \
#   -device qemu-xhci \
#   -device usb-tablet \
#   -vga virtio \
#   -display spice-app \
#   -spice disable-ticketing=on \
#   -device virtio-serial-pci \
#   -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
#   -chardev spicevmc,id=spicechannel0,name=vdagent \

# --------------------Spice with QXL (balance between graphics performance and host & guest integration, such as shared clipboard) ---------------------
# Note 1: QXL works with Spice better than VirtIO Graphics. Too recommended if you want to use Spice and 3D Acceleration isn't important

# qemu-system-x86_64 \
#   -enable-kvm \
#   -m 4096 \
#   -cpu host \
#   -smp 4,sockets=1,cores=4,threads=1 \
#   -machine type=q35 \
#   -drive file="$DISK_FILE",if=virtio \
#   -drive file="$ISO_SO",media=cdrom \
#   -drive file="$ISO_VIRTIO",media=cdrom \
#   -boot order=cd,menu=on \
#   -device intel-hda -device hda-duplex \
#   -monitor stdio \
#   -device qemu-xhci \
#   -device usb-tablet \
#   -vga qxl \
#   -display spice-app \
#   -spice port=$PORT_SPICE,disable-ticketing=on,agent-mouse=on,head=2 \
#   -device virtio-serial-pci \
#   -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
#   -chardev spicevmc,id=spicechannel0,name=vdagent

#===============================================================VNC DISPLAY================================================================================
# Note 1: Depends on the VNC client, it can have more or less host & guest integration, such as shared clipboard.

# --------------------VNC with VirtIO 3D Acceleration (doesn't work, don't try it) ---------------------
# qemu-system-x86_64 \
#   -enable-kvm \
#   -m 4096 \
#   -cpu host \
#   -smp 4,sockets=1,cores=4,threads=1 \
#   -machine type=q35 \
#   -drive file=$DISK_FILE,if=virtio \
#   -drive file="$ISO_SO",media=cdrom \
#   -drive file="$ISO_VIRTIO",media=cdrom \
#   -boot order=cd,menu=on \
#   -net nic,model=virtio -net user \
#   -device intel-hda -device hda-duplex \
#   -monitor stdio \
#   -device qemu-xhci \
#   -device usb-tablet \
#   -device virtio-vga-gl \
#   -display none \
#   -vnc :0 \
#   -device virtio-serial-pci

# --------------------VNC with VirtIO 2D (but without 3D Acceleration, it's very similar to QXL)---------------------
# qemu-system-x86_64 \
#   -enable-kvm \
#   -m 4096 \
#   -cpu host \
#   -smp 4,sockets=1,cores=4,threads=1 \
#   -machine type=q35 \
#   -drive file=$DISK_FILE,if=virtio \
#   -drive file="$ISO_SO",media=cdrom \
#   -drive file="$ISO_VIRTIO",media=cdrom \
#   -boot order=cd,menu=on \
#   -net nic,model=virtio -net user \
#   -device intel-hda -device hda-duplex \
#   -monitor stdio \
#   -device qemu-xhci \
#   -device usb-tablet \
#   -vga virtio \
#   -display none \
#   -vnc :0 \
#   -device virtio-serial-pci

# --------------------VNC con QXL  --------------------------------
# qemu-system-x86_64 \
#   -enable-kvm \
#   -m 4096 \
#   -cpu host \
#   -smp 4,sockets=1,cores=4,threads=1 \
#   -machine type=q35 \
#   -drive file=$DISK_FILE,if=virtio \
#   -drive file="$ISO_SO",media=cdrom \
#   -drive file="$ISO_VIRTIO",media=cdrom \
#   -boot order=cd,menu=on \
#   -net nic,model=virtio -net user \
#   -device intel-hda -device hda-duplex \
#   -monitor stdio \
#   -device qemu-xhci \
#   -device usb-tablet \
#   -vga qxl \
#   -display none \
#   -vnc :0 \
#   -device virtio-serial-pci

#===============================================================GTK/SDL DISPLAYS================================================================================
# ---------------GTK/SDL Display (no host & guest integrations, but VirtIO 3D Acceleration is more enjoyable)-------------------------------

# qemu-system-x86_64 \
#   -enable-kvm \
#   -m 4096 \
#   -cpu host \
#   -smp 4,sockets=1,cores=4,threads=1 \
#   -machine type=q35 \
#   -drive file="$DISK_FILE",if=virtio \
#   -drive file="$ISO_SO",media=cdrom \
#   -drive file="$ISO_VIRTIO",media=cdrom \
#   -boot order=cd,menu=on \
#   -net nic,model=virtio -net user \
#   -device intel-hda -device hda-duplex \
#   -monitor stdio \
#   -device qemu-xhci \
#   -device usb-tablet \
#   -device virtio-vga-gl \
#   -display gtk,gl=on
# # -display sdl,gl=on

# ---------------GTK/SDL Display (no host & guest integrations, but VirtIO Graphics, although without 3D Acceleration)-------------------------------
# qemu-system-x86_64 \
#   -enable-kvm \
#   -m 4096 \
#   -cpu host \
#   -smp 4,sockets=1,cores=4,threads=1 \
#   -machine type=q35 \
#   -drive file="$DISK_FILE",if=virtio \
#   -drive file="$ISO_SO",media=cdrom \
#   -drive file="$ISO_VIRTIO",media=cdrom \
#   -boot order=cd,menu=on \
#   -net nic,model=virtio -net user \
#   -device intel-hda -device hda-duplex \
#   -monitor stdio \
#   -device qemu-xhci \
#   -device usb-tablet \
#   -device virtio-vga \
#   -display gtk
# # -display sdl

# ---------------GTK/SDL Display (no host & guest integrations, using QXL instead of VirtIO Graphics, only 2D) -------------------------------
# qemu-system-x86_64 \
#   -enable-kvm \
#   -m 4096 \
#   -cpu host \
#   -smp 4,sockets=1,cores=4,threads=1 \
#   -machine type=q35 \
#   -drive file="$DISK_FILE",if=virtio \
#   -drive file="$ISO_VIRTIO",media=cdrom \
#   -boot order=cd,menu=on \
#   -net nic,model=virtio -net user \
#   -device intel-hda -device hda-duplex \
#   -monitor stdio \
#   -device qemu-xhci \
#   -device usb-tablet \
#   -vga qxl \
#   -display gtk \
# # -display sdl

#======================================== FEATURES THAT CAN BE ADDED TO THE VIRTUAL MACHINE ========================================
# UEFI firmware: add the -bios argument to the command line, like this:
# -bios $UEFI_FILE \

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

# Compression of the disk image:
#qemu-img convert -O qcow2 $DISK_FILE zipped.qcow2 -c

# Reduce the size of the disk image:
# 1st: qemu-img resize imagen.qcow2 20
# 2nd: Start VM and reduce the size of the partition with GParted or fdisk. Then, synchronize the changes in the file system table.
# 3rd: qemu-img convert -o preallocation=metadata <nombre_imagen.qcow2> <imagen_redimensionada.qcow2>

# Snapshots (2 ways):
# 1st:
# qemu-img snapshot -c "my-snapshot" my-file.qcow2
# Additional options: -a "my-snapshot" -> To merge the snapshot with original image. -l -> To list the snapshots. -d "my-snapshot" -> To delete the snapshot.
# 2nd:
# Run the VM with de -monitor stdio option and type the following commands:
# monitor
# savevm my-snapshot
# Additional commands: loadvm my-snapshot -> To load the snapshot. info snapshots -> To list the snapshots delvm my-snapshot -> To delete the snapshot.

#======================================== EXPERIMENTAL FEATURES ========================================
#---------------------------------------- Shared Folders, 1st method ----------------------------------------
#  -fsdev local,id=fsdev0,path="$SHARED_FOLDER",security_model=mapped \
#  -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=hostshare \

#---------------------------------------- Shared Folders, 2nd method ----------------------------------------
#  -virtfs local,path="$SHARED_FOLDER",mount_tag=host0,security_model=passthrough,id=host0 \

# ---------------------------------------- Bridged host-only network ----------------------------------------
# See the file Linux_guest_post_installation_recommendations.txt

#======================================== CREDITS ========================================
# https://sl.bing.net/fh4vBKmcDaC -> Copilot, the AI that helped me to write this script.
# https://www.qemu.org/docs/master/system/invocation.html -> general QEMU documentation and options of the command line
# https://bbs.archlinux.org/viewtopic.php?id=182320 -> qemu and host-only networking
