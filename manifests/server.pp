class dosquid::server (

  $squid_port = 3128,
  
  # by default squid is available to any host that can connect
  # specific subnets can be targetted using '192.168.0.0/16'
  $localnet_src = 'all',

  # cache dir location can be overridden,
  $cache_dir = $squid::params::cache_dir,

  # cache size in gigabytes (10GB default)
  $cache_dir_size_gb = 10,

) {

  # setup squid server and expose port
  class { 'squid':
    visible_hostname => $fqdn,
    localnet_src => $localnet_src,
    cache_dir => $cache_dir,
    cache_dir_size => $cache_dir_size_gb * 1024,
    require => Class['docommon'],
  }

  # protect squid service on active machines
  Service <| title == $squid::params::service |> {
    tag => 'service-sensitive',
  }

  class { 'dosquid::firewall' : }

  @domotd::register { "Squid(${squid_port})" : }

}


