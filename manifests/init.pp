# Class: borgbackup
# ===========================
#
# Full description of class borgbackup here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class borgbackup (
  $package_name = $::borgbackup::params::package_name,
  $repositories = {}
) inherits ::borgbackup::params {

  class { borgbackup::install:
    package_name => $package_name
  }

  create_resources('borgbackup::repository', $repositories)

  Class['borgbackup::install'] -> Borgbackup::Repository <| |>
}
