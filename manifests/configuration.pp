define borgbackup::configuration(
  $source_directories,
  $repository,
  $type          = 'borg',
  $encryption    = 'none',
  $passphrase    = undef,
  $excludes      = [],
  $job_schedule  = {},
  $job_verbosity = '1',
  $job_mailto    = '',
  $borg_rsh      = 'ssh',
  $options       = {
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
      $command  = '/usr/local/bin/atticmatic'
    }
    'borg': {
      $conf_dir = '/etc/borgmatic'
      $command  = '/usr/local/bin/borgmatic'
    }
    default: {
      fail("value ${type} not allowed for parameter type")
    }
  }

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
        command     => "borg init --encryption ${encryption} ${repository}",
        unless      => "borg list ${repository}"
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

  file { "${conf_dir}/config.${title}":
    content => template('borgbackup/config.erb')
  }

  file { "${conf_dir}/excludes.${title}":
    content => template('borgbackup/excludes.erb')
  }

  $env = [ "MAILTO=${job_mailto}", "PATH=/usr/bin:/bin:/usr/local/bin" ]

  if $borg_rsh {
    $borg_env = [ "BORG_RSH=\"${borg_rsh}\"" ]
  }

  if !empty($job_schedule) {
    cron { "borgbackup::configuration::${title}":
      user        => 'root',
      environment => unique(flatten([$env, $borg_env])),
      command     => "${command} --config ${conf_dir}/config.${title} --excludes ${conf_dir}/excludes.${title} -v ${job_verbosity} > /tmp/borgbackup.log 2>&1 || cat /tmp/borgbackup.log",
      minute      => $job_schedule[minute],
      hour        => $job_schedule[hour],
      weekday     => $job_schedule[weekday],
      month       => $job_schedule[month],
      monthday    => $job_schedule[monthday]
    }
  }
}
