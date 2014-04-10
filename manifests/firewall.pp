class dosquid::firewall (

) {

  @docommon::fireport { "0${squid_port} Squid Proxy Service":
    protocol => 'tcp',
    port => $squid_port,
  }
  
}


