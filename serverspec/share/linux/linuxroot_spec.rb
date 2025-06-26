# User requirements for Linux VM
describe "User requirements for Linux VM" do
  # Check user cloud-init
  describe user('linuxroot') do
    it { should exist }
    it { should have_home_directory '/home/linuxroot' }
    it { should have_login_shell '/bin/bash' }
  end

  # uommon is one of the additional accounts
  describe user('linuxroot') do
    it { should exist }
    it { should belong_to_group 'root' }
    it { should have_uid 0 }
    it { should have_home_directory '/home/linuxroot' }
    it { should have_login_shell '/bin/bash' }
  end

  # Check user linuxroot authorized_keys
  describe file('/home/linuxroot/.ssh/authorized_keys') do
    it { should be_exist }
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'root' }
    its(:size) { should eq 0 }
  end

  describe file('/home/linuxroot/.hushlogin') do
    it { should be_exist }
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'root' }
    its(:size) { should eq 0 }
  end

end
