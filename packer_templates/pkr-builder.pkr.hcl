packer {
  required_version = ">= 1.7.0"
  required_plugins {
    hyperv = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/hyperv"
    }
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
    vagrant = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/vagrant"
    }
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
    vmware = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "-", "")
  scripts = var.scripts == null ? (
    var.os_name == "archlinux" ? [
      "${path.root}/scripts/${var.os_name}/bootstrap.sh",
      "${path.root}/scripts/${var.os_name}/update.sh",
      "${path.root}/scripts/${var.os_name}/virtualbox.sh",
      "${path.root}/scripts/${var.os_name}/workaround.sh",
      "${path.root}/scripts/${var.os_name}/cleanup.sh",
      "${path.root}/scripts/${var.os_name}/pacmansource.sh",
      "${path.root}/scripts/_common/motd.sh",
      "${path.root}/scripts/_common/sshd.sh",
      "${path.root}/scripts/_common/vagrant.sh",
      "${path.root}/scripts/_common/minimize.sh"
    ] : (
    var.os_name == "ubuntu" ||
    var.os_name == "debian" ? [
      "${path.root}/scripts/${var.os_name}/update.sh",
      "${path.root}/scripts/_common/motd.sh",
      "${path.root}/scripts/_common/sshd.sh",
      "${path.root}/scripts/${var.os_name}/networking.sh",
      "${path.root}/scripts/${var.os_name}/sudoers.sh",
      "${path.root}/scripts/_common/vagrant.sh",
      "${path.root}/scripts/${var.os_name}/systemd.sh",
      "${path.root}/scripts/_common/virtualbox.sh",
      "${path.root}/scripts/${var.os_name}/hyperv.sh",
      "${path.root}/scripts/${var.os_name}/vmware.sh",
      "${path.root}/scripts/${var.os_name}/hostname.sh",
      "${path.root}/scripts/${var.os_name}/cleanup.sh",
      "${path.root}/scripts/_common/minimize.sh"
    ] : [
      "${path.root}/scripts/rhel/update_dnf.sh",
      "${path.root}/scripts/_common/motd.sh",
      "${path.root}/scripts/_common/sshd.sh",
      "${path.root}/scripts/_common/vagrant.sh",
      "${path.root}/scripts/_common/virtualbox.sh",
      "${path.root}/scripts/rhel/vmware.sh",
      "${path.root}/scripts/rhel/cleanup_dnf.sh",
      "${path.root}/scripts/_common/minimize.sh"
    ]
  )) : var.scripts
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = [
    "sources.hyperv-iso.vm",
    "sources.virtualbox-iso.vm",
    "sources.vmware-iso.vm"
  ]

  # Linux Shell scipts
  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/vagrant",
      "COUNTRY=${var.country}",
      "http_proxy=${var.http_proxy}",
      "https_proxy=${var.https_proxy}",
      "no_proxy=${var.no_proxy}"
    ]
    execute_command = var.os_name == "ubuntu" ? (
      "echo 'vagrant' | {{ .Vars }} sudo -S -E bash -eux '{{ .Path }}'"
    ) : (
    var.os_name == "archlinux" ? (
      "{{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    ) : (
      "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    ))
    expect_disconnect = true
    scripts           = local.scripts
  }

  post-processors {
    post-processor "vagrant" {
      compression_level = 9
      output            = "${path.root}/../builds/${var.os_name}-${var.os_version}-${var.os_arch}.{{ .Provider }}.box"
      vagrantfile_template = var.is_windows ? "${path.root}/vagrantfile-windows.template" : (
        var.os_name == "freebsd" ? "${path.root}/vagrantfile-freebsd.template" : null
      )
    }
    post-processor "vagrant-registry" {
      client_id     = var.hcp_client_id
      client_secret = var.hcp_client_secret
      box_tag = var.box_tag
      version = substr(local.timestamp, 0, 8)
    }
  }
}
