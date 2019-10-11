# == Class borgbackup::install
#
# This class is called from borgbackup for install.
#
class borgbackup::install(
  $package_name = $::borgbackup::package_name
) {

  if $package_name {
    package { $package_name:
      ensure => present,
    }
  }
}
