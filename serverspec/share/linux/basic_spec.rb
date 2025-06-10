# Basic system requirements for Linux VM
describe "Basic system requirements for Linux VM" do
  # Check Support pvscsi
  describe command('lsmod |grep vmw_pvscsi') do
    its(:exit_status) { should eq 0 }
  end
 
  # Check Packages
  packages = ENV['PACKAGE'].split(' ')
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  # Check Services
  services = %w(vmtoolsd chronyd cloud-init atd acpid)
  services.each do |service|
    describe service(service) do
      it { should be_enabled }
    end
  end
 
  # Check cloud-init
  describe command('grep "disable_vmware_customization: true" /etc/cloud/cloud.cfg') do
    its(:exit_status) { should eq 0 }
  end
 
  # Check language & keyboard
  describe command('localectl') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('System Locale: LANG=en_US.UTF-8') }
    its(:stdout) { should include('VC Keymap: jp') }
    its(:stdout) { should include('X11 Layout: jp') }
  end
 
  # Check Timezone
  describe command('timedatectl') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('Time zone: Asia/Tokyo') }
  end
 
  # Check Service firewalld and sshd
  describe service("firewalld") do
    it { should be_enabled }
    it { should be_running }
  end
 
  describe service("sshd") do
    it { should be_enabled }
    it { should be_running }
  end
 
  describe port(22) do
    it { should be_listening }
  end
 
  # Firewall-cmd - Red Hat Certification application is running on port 8009 (or another port as configured)
  describe command("firewall-cmd --list-all") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('services: cockpit dhcpv6-client ssh') }
  end
 
  # Check GPT partitioned and boot efi 1GB
  describe command('fdisk -l /dev/sda') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('Disklabel type: gpt') }
  end
 
  describe command("fdisk -l /dev/sda | grep '/dev/sda1'") do
    its(:stdout) { should match /EFI System/ }
    its(:stdout) { should match /1G/ }
  end
 
  # Check Types of file systems XFS
  describe command("file -s /dev/sda3") do
    its(:stdout) { should include('LVM2 PV') }
  end
 
  # Check file Chrony
  describe file('/etc/chrony.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    # its(:content) { should include("server #{ENV['CHRONY_SERVER']} iburst") }
  end
end
