require 'spec_helper'

describe 'borgbackup::configuration' do
  let(:title) { 'filesystem' }

  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
	        facts
	      end

        context "without any parameters" do
	        let(:params) { { } }

          it { expect { catalogue }.to raise_error(Puppet::PreformattedError, /expects a value for parameter 'source_directories'/) }
        end

        context "with source_directories => '/home'" do
	        let(:params) { { :source_directories => '/home' } }

          it { expect { catalogue }.to raise_error(Puppet::PreformattedError, /expects a value for parameter 'repository'/) }
        end

	      context "with the required parameters" do
	        let(:default_params) { { :source_directories => '/home', :repository => '/mnt/backup' } }
	        let(:params) { default_params }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_borgbackup__configuration('filesystem').with(
            :source_directories => '/home',
	          :repository         => '/mnt/backup',
            :encryption         => 'none',
	          :type               => 'borg',
            :timeout            => '5',
	          :excludes           => [],
            :job_schedule       => {},
	          :job_verbosity      => '1',
	          :borg_rsh           => 'ssh'
	        ) }

          it { is_expected.to contain_exec('borg init filesystem').with(
            :path        => ['/usr/bin', '/usr/local/bin'],
            :environment => [ 'BORG_RSH=ssh'],
            :command     => 'borg init --encryption none --lock-wait 5 /mnt/backup',
            :unless      => 'borg list --lock-wait 5 /mnt/backup'
          ) }

	        it { is_expected.to contain_file('/etc/borgmatic/config.filesystem').with(
	          :ensure => 'file',
            :owner  => 'root',
	          :group  => 'root',
	          :mode   => '0644'
	        ) }

	        it { is_expected.to contain_file('/etc/borgmatic/config.filesystem').with_content(
            /\[location\]\nsource_directories: \/home\nrepository: \/mnt\/backup\n\n/
	        ) }

	        it { is_expected.to contain_file('/etc/borgmatic/config.filesystem').with_content(
            /\[storage\]\ncompression: none\n\n/
	        ) }

	        it { is_expected.to contain_file('/etc/borgmatic/config.filesystem').with_content(
            /\[retention\]\n\n/
	        ) }

	        it { is_expected.to contain_file('/etc/borgmatic/config.filesystem').with_content(
            /\[consistency\]\nchecks: repository archives\ncheck_last: 1/
	        ) }

	        it { is_expected.to contain_file('/etc/borgmatic/excludes.filesystem') }
	        it { is_expected.to_not contain_cron('borgmatic::configuration::filesystem') }


          context "with encryption => foo" do
            let(:params) { default_params.merge({ :encryption => 'foo' }) }

            it { expect { catalogue }.to raise_error(Puppet::Error, /value foo not allowed for parameter encryption/) }
          end

          context "with encryption => repokey, timeout => 7, passphrase => secret and borg_rsh => ssh -i /tmp/privkey.pem" do
            let(:params) { default_params.merge({ :encryption => 'repokey', :timeout => '7', :passphrase => 'secret', :borg_rsh => 'ssh -i /tmp/privkey.pem' }) }

            it { is_expected.to contain_exec('borg init filesystem').with(
              :path        => ['/usr/bin', '/usr/local/bin'],
              :environment => [ 'BORG_PASSPHRASE=secret', 'BORG_RSH=ssh -i /tmp/privkey.pem'],
              :returns     => [ 0, 2],
              :command     => 'borg init --encryption repokey --lock-wait 7 /mnt/backup',
              :unless      => 'borg list --lock-wait 7 /mnt/backup'
            ) }
          end

	        context "and with type => attic" do
            let(:params) { default_params.merge( { :type => 'attic' } ) }

	          it { is_expected.to contain_file('/etc/atticmatic/config.filesystem').with(
	            :ensure => 'file',
              :owner  => 'root',
	            :group  => 'root',
	            :mode   => '0644'
	          ) }

	          it { is_expected.to contain_file('/etc/atticmatic/excludes.filesystem') }
          end

	        context "and with type => attic, passphrase => secret and a custom options hash" do
            let(:params) { default_params.merge( {
              :type       => 'attic',
	            :passphrase => 'secret',
	            :options    => {
                'compression'  => 'lz4',
	              'keep_within'  => '3H',
                'keep_hourly'  => '7',
                'keep_daily'   => '7',
                'keep_weekly'  => '5',
                'keep_monthly' => '3',
                'keep_yearly'  => '1',
                'prefix'       => 'foo',
                'checks'       => 'archives'
              }
	          } ) }

            it { is_expected.to contain_file('/etc/atticmatic/config.filesystem').with_content(
              /\[location\]\nsource_directories: \/home\nrepository: \/mnt\/backup\n\n/
            ) }

            it { is_expected.to contain_file('/etc/atticmatic/config.filesystem').with_content(
              /\[storage\]\nencryption_passphrase: secret\ncompression: lz4\n\n/
            ) }

            it { is_expected.to contain_file('/etc/atticmatic/config.filesystem').with_content(
              /\[retention\]\nkeep_within: 3H\nkeep_hourly: 7\nkeep_daily: 7\nkeep_weekly: 5\nkeep_monthly: 3\nkeep_yearly: 1\nprefix: foo\n\n/
            ) }

            it { is_expected.to contain_file('/etc/atticmatic/config.filesystem').with_content(
              /\[consistency\]\nchecks: archives\ncheck_last: 1/
            ) }
	        end

	        context "and with type => attic and excludes => [ '/home/a', '/home/b']" do
            let(:params) { default_params.merge(
	            {
                :type => 'attic',
	              :excludes => [ '/home/a', '/home/b']
	            }
	          ) }

	          it { is_expected.to_not contain_cron('atticmatic::configuration::filesystem') }

	          it { is_expected.to contain_file('/etc/atticmatic/config.filesystem').with(
	            :ensure => 'file',
              :owner  => 'root',
	            :group  => 'root',
	            :mode   => '0644'
	          ) }

	          it { is_expected.to contain_file('/etc/atticmatic/excludes.filesystem').with(
	            :ensure  => 'file',
              :owner   => 'root',
	            :group   => 'root',
	            :mode    => '0644',
	            :content => /\/home\/a\n\/home\/b/
	          ) }
          end

	        context "and with excludes => [ /home/c, /home/d, /home/e], borg_rsh => ssh -i /tmp/privkey.pem, job_verbosity => 1 and job_schedule => { hour => *, minute => 10, weekday => * }" do
            let(:params) { default_params.merge(
              {
                :excludes      => [ '/home/c', '/home/d', '/home/e'],
		            :borg_rsh      => 'ssh -i /tmp/privkey.pem',
		            :job_verbosity => '1',
                :job_schedule  => { 'hour' => '*', 'minute' => 10, 'weekday' => '*' }
              }
            ) }

	          it { is_expected.to contain_cron('borgbackup::configuration::filesystem').with(
              :user        => 'root',
	            :environment => ['MAILTO=', 'PATH=/usr/bin:/bin:/usr/local/bin', 'BORG_RSH="ssh -i /tmp/privkey.pem"'],
	            :command     => '/usr/local/bin/borgmatic --config /etc/borgmatic/config.filesystem --excludes /etc/borgmatic/excludes.filesystem -v 1 > /tmp/borgbackup.log 2>&1 || cat /tmp/borgbackup.log',
	            :hour        => '*',
	            :minute      => '10',
	            :weekday     => '*'
	          ) }

	          it { is_expected.to contain_file('/etc/borgmatic/config.filesystem').with(
	            :ensure => 'file',
              :owner  => 'root',
	            :group  => 'root',
	            :mode   => '0644'
	          ) }

	          it { is_expected.to contain_file('/etc/borgmatic/excludes.filesystem').with(
	            :ensure  => 'file',
              :owner   => 'root',
	            :group   => 'root',
	            :mode    => '0644',
	            :content => /\/home\/c\n\/home\/d\n\/home\/e/
	          ) }
	        end

	        context "and with job_verbosity => '2', job_mailto => 'root@localhost' and job_schedule => { hour => 3, minute => 15, weekday => 4, month => 5, monthday => * }" do
            let(:params) { default_params.merge(
              {
		            :job_verbosity => '2',
		            :job_mailto    => 'root@localhost',
                :job_schedule  => { 'hour' => 3, 'minute' => 15, 'weekday' => 4, 'month' => 5, 'monthday' => '*' }
              }
            ) }

	          it { is_expected.to contain_cron('borgbackup::configuration::filesystem').with(
              :user        => 'root',
	            :environment => ['MAILTO=root@localhost', 'PATH=/usr/bin:/bin:/usr/local/bin', 'BORG_RSH="ssh"'],
	            :command     => '/usr/local/bin/borgmatic --config /etc/borgmatic/config.filesystem --excludes /etc/borgmatic/excludes.filesystem -v 2 > /tmp/borgbackup.log 2>&1 || cat /tmp/borgbackup.log',
	            :hour        => '3',
	            :minute      => '15',
	            :weekday     => '4',
	            :month       => '5',
	            :monthday    => '*'
	          ) }

	          it { is_expected.to contain_file('/etc/borgmatic/config.filesystem').with(
	            :ensure => 'file',
              :owner  => 'root',
	            :group  => 'root',
	            :mode   => '0644'
	          ) }

	          it { is_expected.to contain_file('/etc/borgmatic/excludes.filesystem') }
	        end
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'with the required parameters on RedHat' do
      let(:facts) do
        {
          :operatingsystem => 'RedHat',
        }
      end
      let(:params) { { :source_directories => '/home', :repository => '/mnt/backup' } }

      it { expect { catalogue }.to raise_error(Puppet::Error, /RedHat not supported/) }
    end
  end

  context 'unsupported operating system release' do
    describe 'with the required parameters on Ubuntu 12.04' do
      let(:facts) do
        {
          :operatingsystem        => 'Ubuntu',
          :operatingsystemrelease => '12.04'
        }
      end
      let(:params) { { :source_directories => '/home', :repository => '/mnt/backup' } }

      it { expect { catalogue }.to raise_error(Puppet::Error, /Ubuntu 12.04 not supported/) }
    end
  end
end
