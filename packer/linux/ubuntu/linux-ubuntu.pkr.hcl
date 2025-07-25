//  BLOCK: locals
//  Defines the local variables.

packer {
  required_plugins {
    vsphere = {
      version = "~> 1"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

locals {
  build_vm_name                       = "Template-${var.vm_guest_os_name}-${var.vm_guest_os_version}"
  build_os_distribution               = "${var.vm_guest_os_name}-${var.vm_guest_os_version}"
  build_by                            = "Built by: HashiCorp Packer"
  build_date                          = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_description                   = "${local.build_vm_name}\nBuilt on: ${local.build_date}\n${local.build_by}"
  build_iso_paths                     = "${local.build_os_distribution}" == "ubuntu-20-04" ? "${var.iso_paths_01}" : "${local.build_os_distribution}" == "ubuntu-22-04" ? "${var.iso_paths_02}" : "${var.iso_paths_03}"                                     
  build_boot_command                  = "${local.build_os_distribution}" == "ubuntu-20-04" ? "<esc><wait>" : "<wait3s>c<wait3s>"
  data_source_command                 = "${var.common_data_source}" == "http" ? "ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"" : "ds=\"nocloud\""
  data_source_content                 = {
    "/meta-data"                      = file("${abspath(path.root)}/data/meta-data")
    "/user-data"                      = templatefile("${abspath(path.root)}/data/user-data.pkrtpl.hcl", {
      build_vm_hostname               = "${var.vm_guest_os_name}"
      build_vm_network_device         = "${var.vm_network_device}"
      build_vm_ip                     = "${var.vm_ip_address}"
      build_vm_subnet                 = "${var.vm_subnet}"
      build_vm_gateway                = "${var.vm_gateway}"
      build_vm_dns                    = "${var.vm_dns}"
      build_vm_password_encrypted     = "${var.communicator_password_encrypted}"
      build_vm_public_key             = "${var.communicator_public_key}"
      build_vm_guest_os_language      = "${var.vm_guest_os_language}"
      build_vm_guest_os_keyboard      = "${var.vm_guest_os_keyboard}"
      build_vm_guest_os_timezone      = "${var.vm_guest_os_timezone}"
      build_vm_storage                = templatefile("${abspath(path.root)}/data/storage.pkrtpl.hcl", {
        device                        = "${var.vm_disk_device}"
        swap                          = "${var.vm_disk_use_swap}"
        partitions                    = "${var.vm_disk_partitions}"
        lvm                           = "${var.vm_disk_lvm}"
      })
    })
  }
}

//  BLOCK: source
//  Defines the builder configuration blocks.

source "vsphere-iso" "ubuntu" {

  // vCenter Server Endpoint Settings and Credentials
  vcenter_server                = "${var.vsphere_endpoint}"
  username                      = "${var.vsphere_username}"
  password                      = "${var.vsphere_password}"
  insecure_connection           = "${var.vsphere_insecure_connection}"

  // vSphere Settings
  datacenter                    = "${var.vsphere_datacenter}"
  cluster                       = "${var.vsphere_cluster}"
  host                          = "${var.vsphere_resource_pool}"
  datastore                     = "${var.vsphere_datastore}"
  folder                        = "${var.vsphere_folder}"

  // Virtual Machine Settings
  vm_name                       = "${local.build_vm_name}"
  notes                         = "${local.build_description}"
  guest_os_type                 = "${var.vm_guest_os_type}"
  firmware                      = "${var.vm_firmware}"
  CPUs                          = "${var.vm_cpu_count}"
  cpu_cores                     = "${var.vm_cpu_cores}"
  CPU_hot_plug                  = "${var.vm_cpu_hot_add}"
  RAM                           = "${var.vm_mem_size}"
  RAM_hot_plug                  = "${var.vm_mem_hot_add}"
  disk_controller_type          = "${var.vm_disk_controller_type}"
  storage {
    disk_size                   = "${var.vm_disk_size}"
    disk_thin_provisioned       = "${var.vm_disk_thin_provisioned}"
  }
  network_adapters {
    network                     = "${var.vsphere_network}"
    network_card                = "${var.vm_network_card_type}"
  }
  vm_version                    = "${var.vm_version}"
  usb_controller                = "${var.vm_usb_controller}"
  remove_cdrom                  = "${var.vm_remove_cdrom}"
  tools_upgrade_policy          = "${var.vm_tools_upgrade_policy}"
  iso_paths                     = "${local.build_iso_paths}"

  // Template Settings
  convert_to_template           = "${var.common_template_conversion}"

  // Boot and Provisioning Settings 
  http_content                  = "${var.common_data_source}" == "http" ? "${local.data_source_content}" : null
  cd_content                    = "${var.common_data_source}" == "disk" ? "${local.data_source_content}" : null
  cd_label                      = "${var.common_data_source}" == "disk" ? "cidata" : null
  boot_command = [
    "${local.build_boot_command}",
    "linux /casper/vmlinuz --- autoinstall ${local.data_source_command}",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  boot_order                    = "${var.common_vm_boot_order}"
  boot_wait                     = "${var.common_vm_boot_wait}"
  ip_wait_timeout               = "${var.common_ip_wait_timeout}"
  shutdown_timeout              = "${var.common_shutdown_timeout}"
  shutdown_command              = "init 0"

  // OS Connection Details
  communicator                  = "ssh"
  ssh_host                      = "${var.vm_ip_address}"
  ssh_username                  = "${var.communicator_user}"
  ssh_private_key_file          = "${var.communicator_private_key}"
  ssh_port                      = "${var.communicator_port}"
  ssh_timeout                   = "${var.communicator_timeout}"
}

//  BLOCK: build
//  Defines the builders to run, provisioners, and post-processors.

build {

  sources                       = ["source.vsphere-iso.ubuntu"]

  post-processor "manifest" {
    output                      = "../manifests/${local.build_os_distribution}.json"
    strip_path                  = true
    strip_time                  = true
    custom_data = {
      os_distribution           = "${local.build_os_distribution}"
    }
  }
}
