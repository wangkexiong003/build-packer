os_name                 = "ubuntu"
os_version              = "24.04"
os_arch                 = "x86_64"
iso_urls                = ["https://mirrors.edge.kernel.org/ubuntu-releases/noble/ubuntu-24.04.3-live-server-amd64.iso", "https://old-releases.ubuntu.com/releases/noble/ubuntu-24.04.3-live-server-amd64.iso"]
iso_checksum            = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
hyperv_generation       = 2
boot_command            = ["<wait>e<wait><down><down><down><end> autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/<wait><f10><wait>"]
box_tag                 = "wangkexiong/ubuntu-24.04"
