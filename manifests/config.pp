# == Class borgbackup::config
#
# This class is called from borgbackup for config.
#
class borgbackup::config
{
  file { $configuration_directories:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }
}
