class dosquid::firewall (
  $squid_port = 3128,
) {

  @docommon::fireport { "0${squid_port} Squid Proxy Service":
    protocol => 'tcp',
    port => $squid_port,
  }
  
}


