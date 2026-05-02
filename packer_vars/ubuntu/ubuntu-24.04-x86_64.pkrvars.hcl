os_name                 = "ubuntu"
os_version              = "24.04"
os_arch                 = "x86_64"
iso_urls                = ["https://mirrors.edge.kernel.org/ubuntu-releases/noble/ubuntu-24.04.4-live-server-amd64.iso", "https://old-releases.ubuntu.com/releases/noble/ubuntu-24.04.4-live-server-amd64.iso"]
iso_checksum            = "sha256:e907d92eeec9df64163a7e454cbc8d7755e8ddc7ed42f99dbc80c40f1a138433"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
hyperv_generation       = 2
qemu_efi_boot           = true
qemu_efi_firmware_code  = "/usr/share/OVMF/OVMF_CODE_4M.fd"
qemu_efi_firmware_vars  = "/usr/share/OVMF/OVMF_VARS_4M.fd"
qemu_efi_drop_efivars   = true
boot_command            = ["<wait>e<wait><down><down><down><end> autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/<wait><f10><wait>"]
box_tag                 = "wangkexiong/ubuntu-24.04"