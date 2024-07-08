define borgbackup::configuration(
  $ensure             = 'present',
  $source_directories = undef,
  $repository         = undef,
  $type               = 'borg',
  $encryption         = 'none',
  $umask              = '0027',
  $passphrase         = undef,
  $exclude_patterns   = [],
  $job_schedule       = {},
  $job_verbosity      = '1',
  $job_mailto         = '',
  $borg_rsh           = 'ssh',
  $timeout            = '5',
  $options            = {
    'compression'           => 'none',
    'keep_within'           => undef,
    'keep_hourly'           => undef,
    'keep_daily'            => undef,
    'keep_weekly'           => undef,
    'keep_monthly'          => undef,
    'keep_yearly'           => undef,
    'prefix'                => undef,
    'checks'                => [ 'repository', 'archives'],
    'check_last'            => '1'
  }
) {

  include borgbackup::params

  case $type {
    'attic': {
      $conf_dir = '/etc/atticmatic'
      $command  = '/usr/bin/atticmatic'
    }
    'borg': {
      $conf_dir = '/etc/borgmatic'
      $command  = '/usr/bin/borgmatic'
    }
    default: {
      fail("value ${type} not allowed for parameter type")
    }
  }

  if $ensure == 'absent' {
    file { "${conf_dir}/config.${title}":
      ensure => 'absent'
    }

    cron { "borgbackup::configuration::${title}":
      ensure => 'absent'
    }
  } else {
    unless $source_directories {
      fail("${title} expects a value for parameter 'source_directories'")
    }

    unless $repository {
      fail("${title} expects a value for parameter 'repository'")
    }

    if $passphrase {
      $pass = "BORG_PASSPHRASE=${passphrase}"
    } else {
      $pass = undef
    }

    if $borg_rsh {
      $rsh = "BORG_RSH=${borg_rsh}"
    } else {
      $rsh = undef
    }

    $exec_env = delete_undef_values([ $pass, $rsh])

    case $encryption {
      'none', 'repokey', 'keyfile', 'passphrase': {
        exec { "borg init ${title}":
          path        => [ '/usr/bin', '/usr/local/bin'],
          environment => $exec_env,
          returns     => [ 0, 2],
          command     => "borg init --umask ${umask} --encryption ${encryption} --lock-wait ${timeout} ${repository}",
          unless      => "borg list --lock-wait ${timeout} ${repository}"
        }
      }
      default: {
        fail("value ${encryption} not allowed for parameter encryption")
      }
    }

    File {
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0644'
    }

    $default_options = {
      'compression'  => 'none',
      'keep_within'  => undef,
      'keep_hourly'  => undef,
      'keep_daily'   => undef,
      'keep_weekly'  => undef,
      'keep_monthly' => undef,
      'keep_yearly'  => undef,
      'prefix'       => undef,
      'checks'       => [ 'repository', 'archives'],
      'check_last'   => '1'
    }
    $_options = merge($default_options, $options)

    file { "${conf_dir}/config.${title}":
      content => template('borgbackup/config.yaml.erb')
    }

    $env = [ "MAILTO=${job_mailto}", "PATH=/usr/bin:/bin:/usr/local/bin" ]

    if $borg_rsh {
      $borg_env = [ "BORG_RSH=\"${borg_rsh}\"" ]
    }

    if !empty($job_schedule) {
      cron { "borgbackup::configuration::${title}":
        user        => 'root',
        environment => unique(flatten([$env, $borg_env])),
        command     => "${command} --config ${conf_dir}/config.${title} -v ${job_verbosity} > /tmp/borgbackup.log 2>&1 || cat /tmp/borgbackup.log",
        minute      => $job_schedule[minute],
        hour        => $job_schedule[hour],
        weekday     => $job_schedule[weekday],
        month       => $job_schedule[month],
        monthday    => $job_schedule[monthday]
      }
    }
  }
}
