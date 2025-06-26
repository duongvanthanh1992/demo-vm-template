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

  # Check language & keyboard
  describe command('localectl') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('System Locale: LANG=en_US.UTF-8') }
    its(:stdout) { should include('X11 Layout: us') }
  end
 
  # Check Timezone
  describe command('timedatectl') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should include('Time zone: Asia/Ho_Chi_Minh') }
  end
 
  describe service("sshd") do
    it { should be_enabled }
    it { should be_running }
  end
 
  describe port(22) do
    it { should be_listening }
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

end
