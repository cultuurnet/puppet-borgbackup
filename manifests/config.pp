# == Class borgbackup::config
#
# This class is called from borgbackup for config.
#
class borgbackup::config
{
  file { [ '/etc/atticmatic', '/etc/borgmatic']:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }
}
