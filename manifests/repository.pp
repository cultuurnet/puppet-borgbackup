define borgbackup::repository(
  $path       = $title,
  $encryption = 'none',
  $passphrase = undef,
  $borg_rsh   = 'ssh'
) {

  include borgbackup::params

  if $passphrase {
    $pass = "BORG_PASSPHRASE=${passphrase}"
  }

  if $borg_rsh {
    $rsh = "BORG_RSH=${borg_rsh}"
  }

  $exec_env = delete_undef_values([ $pass, $rsh])

  case $encryption {
    'none', 'repokey', 'keyfile', 'passphrase': {
      exec { "borg init ${title}":
        path        => [ '/usr/bin', '/usr/local/bin'],
        environment => $exec_env,
        command     => "borg init --encryption ${encryption} ${path}",
        unless      => "borg list ${path}"
      }
    }
    default: {
      fail("value ${encryption} not allowed for parameter encryption")
    }
  }
}
