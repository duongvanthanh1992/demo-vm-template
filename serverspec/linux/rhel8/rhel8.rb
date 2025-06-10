require_relative 'share/spec_helper'

describe "Check DNF repositories" do
  repolist_command = command("dnf repolist -v")
  repo_ids = repolist_command.stdout.lines.grep(/^Repo-id\s*:/)
              .map { |line| line.split(":").last.strip }
  it "Successfully printed all Repo-ids" do
    expect(repolist_command.exit_status).to eq 0
    puts "List all Repo-ids:\n  - #{repo_ids.join("\n  - ")}"
  end

  repo_ids.each do |repo_id|
    describe "Dump configuration manager of Repo-ids: #{repo_id}" do
      describe command("dnf config-manager --dump #{repo_id}") do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should include('mirrorlist = https://rhui01.vpc.gen2.p2.iijgio.jp/') }
        its(:stdout) { should include('enabled = 1') }
        its(:stdout) { should include('sslverify = 1') }
      end
    end
  end
end
