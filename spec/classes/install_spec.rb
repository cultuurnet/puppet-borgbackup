require 'spec_helper'

describe 'borgbackup::install' do
  context "without any parameters" do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to have_package_resource_count(0) }
  end

  context "with package_name => [ 'python3-borgbackup', 'python3-atticmatic']" do
    let (:params) { { :package_name => [ 'python3-borgbackup', 'python3-atticmatic'] } }

    it { is_expected.to contain_package('python3-borgbackup').with_ensure('present') }
    it { is_expected.to contain_package('python3-atticmatic').with_ensure('present') }
  end

  context "with package_name => 'borgbackup'" do
    let (:params) { { :package_name => 'borgbackup' } }

    it { is_expected.to contain_package('borgbackup').with_ensure('present') }
  end
end
