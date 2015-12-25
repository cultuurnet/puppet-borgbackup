require 'spec_helper'

describe 'borgbackup::repository' do
  let(:title) { 'backup' }

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
	  facts
	end

        context "without any parameters" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_borgbackup__repository('backup').only_with(
            :repository => 'backup',
	    :encryption => 'none',
	    :borg_rsh   => 'ssh'
	  ) }

          it { is_expected.to contain_exec('borg init backup').with(
            :path        => ['/usr/bin', '/usr/local/bin'],
	    :environment => 'BORG_RSH=ssh',
            :command     => 'borg init --encryption none backup',
	    :unless      => 'borg list backup'
	  ) }
        end

	context "with title /mnt/backup and without parameters" do
          let(:title) { '/mnt/backup' }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_borgbackup__repository('/mnt/backup').only_with(
            :repository => '/mnt/backup',
	    :encryption => 'none',
	    :borg_rsh   => 'ssh'
	  ) }

          it { is_expected.to contain_exec('borg init /mnt/backup').with(
            :path        => ['/usr/bin', '/usr/local/bin'],
	    :environment => 'BORG_RSH=ssh',
            :command     => 'borg init --encryption none /mnt/backup',
	    :unless      => 'borg list /mnt/backup'
	  ) }
        end

        context "with encryption => foo" do
	  let(:params) { { :encryption => 'foo' } }

          it { expect { catalogue }.to raise_error(Puppet::Error, /value foo not allowed for parameter encryption/) }
        end

        context "with encryption => repokey, passphrase => secret, borg_rsh => ssh -i /tmp/privkey.pem and repository => /mnt/backup" do
	  let(:params) { { :encryption => 'repokey', :passphrase => 'secret', :borg_rsh => 'ssh -i /tmp/privkey.pem', :repository => '/mnt/backup' } }

          it { is_expected.to contain_exec('borg init backup').with(
            :path        => ['/usr/bin', '/usr/local/bin'],
	    :environment => [ 'BORG_PASSPHRASE=secret', 'BORG_RSH=ssh -i /tmp/privkey.pem'],
            :command     => 'borg init --encryption repokey /mnt/backup',
	    :unless      => 'borg list /mnt/backup'
	  ) }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'without any parameters on RedHat' do
      let(:facts) do
        {
          :operatingsystem => 'RedHat',
        }
      end

      it { expect { catalogue }.to raise_error(Puppet::Error, /RedHat not supported/) }
    end
  end

  context 'unsupported operating system release' do
    describe 'without any parameters on Ubuntu 12.04' do
      let(:facts) do
        {
          :operatingsystem        => 'Ubuntu',
          :operatingsystemrelease => '12.04'
        }
      end

      it { expect { catalogue }.to raise_error(Puppet::Error, /Ubuntu 12.04 not supported/) }
    end
  end
end
