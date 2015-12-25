require 'spec_helper'

describe 'borgbackup' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('borgbackup') }
          it { is_expected.to contain_class('borgbackup::params') }
          it { is_expected.to contain_class('borgbackup::install').with_package_name('python3-borgbackup') }
	  it { is_expected.to have_borgbackup__repository_resource_count(0) }
        end

	context "with package_name => foobar" do
          let(:params) { { :package_name => 'foobar' } }

          it { is_expected.to contain_class('borgbackup::install').with_package_name('foobar') }
	end

	context "with repositories => { 'backup' => { 'repository' => '/mnt/backup' } }" do
          let(:params) { { :repositories => { 'backup' => { 'repository' => '/mnt/backup' } } } }

	  it { is_expected.to have_borgbackup__repository_resource_count(1) }
	  it { is_expected.to contain_borgbackup__repository('backup').with_repository('/mnt/backup') }
	end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'without any parameters on RedHat' do
      let(:facts) do
        {
          :operatingsystem => 'RedHat'
        }
      end

      it { expect { catalogue }.to raise_error(Puppet::Error, /RedHat not supported/) }
    end
  end

  context 'unsupported operating system release' do
    describe 'borgbackup class without any parameters on Ubuntu 12.04' do
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
