# == Class borgbackup::params
#
# This class is meant to be called from borgbackup.
# It sets variables according to platform.
#
class borgbackup::params {
  case $facts['os']['name'] {
    'Ubuntu': {
      case $facts['os']['release']['major'] {
        '14.04': {
          $package_name              = ['python3-borgbackup', 'python3-atticmatic']
          $configuration_directories = ['/etc/atticmatic', '/etc/borgmatic']
        }
        '16.04','18.04': {
          $package_name              = ['borgbackup', 'python3-borgmatic']
          $configuration_directories = '/etc/borgmatic'
        }
        '20.04','24.04': {
          $package_name              = ['borgbackup', 'borgmatic']
          $configuration_directories = '/etc/borgmatic'
        }
        default: {
          fail("Ubuntu ${facts['os']['release']['major']} not supported")
        }
      }
    }
    default: {
      fail("${facts['os']['name']} not supported")
    }
  }
}
