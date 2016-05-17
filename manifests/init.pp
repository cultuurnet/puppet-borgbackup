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
  $package_name   = $::borgbackup::params::package_name,
  $configurations = {}
) inherits ::borgbackup::params {

  class { borgbackup::install:
    package_name => $package_name
  }

  class { borgbackup::config: }

  $configurations.each | $name, $configuration| {
    borgbackup::configuration { $name:
      * => $configuration
    }
  }

  Class['borgbackup::install'] -> Class['borgbackup::config'] -> Borgbackup::Configuration <| |>
}
