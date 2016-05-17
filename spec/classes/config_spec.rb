require 'spec_helper'

describe 'borgbackup::config' do
  it { is_expected.to contain_file('/etc/atticmatic').with(
    :ensure => 'directory',
    :owner  => 'root',
    :group  => 'root',
    :mode   => '0755'
  ) }

  it { is_expected.to contain_file('/etc/borgmatic').with(
    :ensure => 'directory',
    :owner  => 'root',
    :group  => 'root',
    :mode   => '0755'
  ) }
end
