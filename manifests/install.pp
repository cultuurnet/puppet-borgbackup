# == Class borgbackup::install
#
# This class is called from borgbackup for install.
#
class borgbackup::install(
  $package_name = $::borgbackup::package_name
) {

  $package_name.each |$package| {
    realize Package[$package]
  }
}
