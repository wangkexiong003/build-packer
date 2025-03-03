os_name                 = "ubuntu"
os_version              = "24.04"
os_arch                 = "x86_64"
iso_url                 = "https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"
iso_checksum            = "file:https://releases.ubuntu.com/24.04.2/SHA256SUMS"
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
hyperv_generation       = 2
boot_command            = ["<wait>e<wait><down><down><down><end> autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/<wait><f10><wait>"]
box_tag                 = "wangkexiong/ubuntu-24.04"
