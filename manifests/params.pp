# == Class borgbackup::params
#
# This class is meant to be called from borgbackup.
# It sets variables according to platform.
#
class borgbackup::params {
  case $::operatingsystem {
    'Ubuntu': {
      case $::operatingsystemrelease {
        '14.04': {
          $package_name = [ 'python3-borgbackup', 'python3-atticmatic' ]
          $configuration_directories = [ '/etc/atticmatic', '/etc/borgmatic']
        }
        '16.04': {
          $package_name = [ 'borgbackup', 'python3-borgmatic' ]
          $configuration_directories = '/etc/borgmatic'
        }
        default: {
          fail("Ubuntu ${::operatingsystemrelease} not supported")
        }
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
