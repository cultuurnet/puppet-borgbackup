define borgbackup::repository(
  $path       = $title,
  $encryption = 'none',
  $passphrase = undef
) {

  include borgbackup::params

  case $encryption {
    'none', 'repokey', 'keyfile', 'passphrase': {
      exec { "borg init ${title}":
        path        => [ '/usr/bin', '/usr/local/bin'],
        environment => "BORG_PASSPHRASE=${passphrase}",
        command     => "borg init --encryption ${encryption} ${path}",
        unless      => "borg list ${path}"
      }
    }
    default: {
      fail("value ${encryption} not allowed for parameter encryption")
    }
  }
}
