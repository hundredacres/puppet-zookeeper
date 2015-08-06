# Class: zookeeper::service

class zookeeper::service(
  $cfg_dir        = '/etc/zookeeper/conf',
  $service_name   = 'zookeeper',
  $service_ensure = 'running',
  $manage_config  = true,
){
  require zookeeper::install

  case $::osfamily {
    'redhat': {
      case $::operatingsystemmajrelease {
        '6': { $initstyle = 'upstart' }
        '7': { $initstyle = 'systemd' }
        default: { $initstyle = 'unknown' }
      }
    }
    default: { $initstyle = 'unknown' }
  }

  if ($initstyle == 'systemd') {
    file { '/usr/lib/systemd/system/zookeeper.service':
      ensure  => 'present',
      content => template('zookeeper/zookeeper.service.erb'),
    } ~>
    exec { 'systemctl daemon-reload # for zookeeper':
      refreshonly => true,
      path        => $::path,
      notify      => Service[$service_name]
    }
  }

  if $manage_config {
    service { $service_name:
      ensure     => $service_ensure,
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
      require    => [
        Class['zookeeper::install'],
        File["${cfg_dir}/zoo.cfg"]
      ]
    }
  }
}
