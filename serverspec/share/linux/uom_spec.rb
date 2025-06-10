# User requirements for Linux VM
describe "User requirements for Linux VM" do
  # Check user cloud-init
  describe user('cloud-user') do
    it { should exist }
    it { should have_home_directory '/home/cloud-user' }
    it { should have_login_shell '/bin/bash' }
  end

  # uommon is one of the additional accounts
  describe user('uommon') do
    it { should exist }
    it { should belong_to_group 'root' }
    it { should have_uid 0 }
    it { should have_home_directory '/home/uommon' }
    it { should have_login_shell '/bin/bash' }
  end

  # Check user uommon authorized_keys
  describe file('/home/uommon/.ssh/authorized_keys') do
    it { should be_exist }
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'root' }
    its(:size) { should eq 0 }
  end

  describe file('/home/uommon/.hushlogin') do
    it { should be_exist }
    it { should be_file }
    it { should be_mode 600 }
    it { should be_owned_by 'root' }
    its(:size) { should eq 0 }
  end

  # User uomope should not exist
  describe user('uomope') do
    it { should_not exist }
  end
end
