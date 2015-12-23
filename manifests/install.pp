# == Class borgbackup::install
#
# This class is called from borgbackup for install.
#
class borgbackup::install(
  $package_name = undef
) {

  if $package_name {
    package { $package_name:
      ensure => present,
    }
  }
}
