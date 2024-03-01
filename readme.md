# QEMU host and guest templates configuration to create virtual machines

This repository provides templates for running QEMU virtual machines on both Linux and Windows hosts, and for running guest operating systems, including both Linux and Windows. The templates are designed to simplify the process of setting up and managing virtual machines, making it easier for users to take advantage of the flexibility and power of QEMU.
Important note: these templates are only for 64 bits-based hosts, but you could change it a little bit and get QEMU accelerated in x86-based systems.

# The power of Type 1 Baremetal Hypervisors'

In addition to providing templates for running QEMU virtual machines, these templates also supports **hardware acceleration**. When running QEMU on a Linux host, it leverages the Kernel-based Virtual Machine (KVM) for hardware acceleration, enhancing the performance of the virtual machines. On the other hand, when running QEMU on a Windows host, it utilizes Hyper-V for hardware acceleration. Both **KVM and Hyper-V** help to improve the speed and efficiency of the virtual machines, making them more practical and effective for a variety of use cases.

# Acceleration 2D and 3D

These templates also offers the capability to create virtual machines with 2D and 3D acceleration using **VirtIO GPU's**, enhancing the graphical performance of the guest operating systems. This is particularly useful for applications that require high-quality graphics or fast rendering times. However, it's important to note that 3D acceleration is only available for Linux guest operating systems. Despite this limitation, the inclusion of 2D and 3D acceleration makes this repository a versatile tool for creating and managing virtual machines.
In Windows Guests, you must see this for VirtIO drivers in Windows guests: https://www.linux-kvm.org/page/WindowsGuestDrivers

# Templates works on BIOS & UEFI firmwares

The QEMU templates provided in this repository are capable of working with both **BIOS and UEFI firmware**. This flexibility allows users to create virtual machines that are compatible with a wide range of operating systems and hardware configurations. However, it's worth noting that currently, UEFI functionality has only been successfully tested on QEMU installations on Linux hosts. Despite this, the ability to work with both BIOS and UEFI firmware enhances the versatility and compatibility of the virtual machines created using these templates.

# Snapshots

Would you like not to lose or break your VM data? Done. With QEMU Snapshot, you can save the VM state, while running or when it's stopped. If you create a snapshot with the VM turned off, it won't take up space!
When you need it, you can create, restore or delete snapshots, but you can't rename them. Be careful to always choose a representative name!

# TODO: Investigate certains areas (in order by priority for now)

- **Bridged network connection** without Internet access, **only between host & guest**. This would be great for SSH connections, for example. Internet'd be going on NAT. NEW: For now, I've managed to do a simple port forwarding to get SSH and/or other services.
- **Shared folders** from host to guest since qemu command. While I'm investigating this, you can follow the post-installation instructions, where you'll find how to configure SAMBA.
- Drag and drop files feature using Spice only works from host to guest, **but doesn't from guest to host**.
- **Bridged network connection with Internet**, dispensing with NAT.
- **UEFI firmware** running in a QEMU virtual machine in Windows hosts.
- Not tested if audio -device intel-hda -device hda-duplex also works on AMD CPU real hardware. Maybe should be used -device usb-audio in these cases?
- Capability for **multiple virtual monitors**, with or without different display options in QEMU.
- -device virtio-vga doesn't work for Windows hosts. Graphics are broken in the VM, but -device virtio-vga-gl doesn't have this problem.
- Testing **other GPU-Accelerated devices**, like virtio-gpu rutabaga for Vulkan workloads. See this: https://www.qemu.org/docs/master/system/devices/virtio-gpu.html
- Testing other ways to have 3D Acceleration, such as **GPU Passthrough**, **Looking Glass**, **egl-headless**, etc. See this: https://wiki.archlinux.org/title/QEMU/Guest_graphics_acceleration

# TODO: not in the scope for now

- Use **CPU Host in QEMU from a Windows host** instead of kvm64 processor (I've tried it before, but I think it's impossible, and with kvm64 + all the set instructions aggregated manually, it may be enough for most)
- Install GTK libraries in Windows host in order to use GTK Display with 3D VirtIO VGA Acceleration (I've tried it before, but I couldn't. I'm sure this is possible)
- VNC with 3D VirtIO VGA Acceleration, ¿it's possible?
