class dosquid (
  $squid_ip,
  $squid_port = 3128,
) {

  # dosquid can't run on itself (first run)
  if ($squid_ip == $ipaddress) {
    $notus = false
  } else {
    $notus = true
  }

  # different caches for different OS
  case $operatingsystem {
    centos, redhat, fedora: {
      $yumable = true
    }
    ubuntu, debian: {
      $yumable = false
    }
  }  

  # ping output file stored in /tmp
  $pingfile = 'puppet-squid-ping-output.txt'
  $pingable = "grep -q '64 bytes from ' /tmp/${pingfile} && test $? -eq 0"

  # ping the target squid server and record the output (no errors) for grepping
  # exec ${pingable} to execute command onlyif we can ping the target server
  exec { 'squid-pingtest':
    path => '/bin:/usr/bin',
    command => "ping -c1 ${squid_ip} > /tmp/${pingfile} 2>&1",
    returns => [0, 1],
  }

  if ($yumable and $notus) {
    # setup yum to use local squid service, if no proxy already set
    exec { 'squid-point-yum' :
      path => '/bin:/usr/bin',
      command => "echo '\nproxy=http://${squid_ip}:${squid_port}\n' >> /etc/yum.conf",
      onlyif  => ["${pingable}", "test `cat /etc/yum.conf | grep 'proxy=http://' | wc -l` == 0"],
      require => Exec['squid-pingtest'],
    }

    # tell yum to ignore mirrors and use the baseurl, for cache consistency and therefore speed
    exec { 'squid-point-yum-repos' :
      path => '/bin:/usr/bin',
      command => "sed -i -e 's/^mirrorlist/#mirrorlist/g' -e 's/^#baseurl/baseurl/g' /etc/yum.repos.d/*.repo",
      onlyif  => ["${pingable}"],
      require => Exec['squid-pingtest'],
    }
  }

  if ($notus) {
    # tell wget to use proxy
    exec { 'squid-point-wget' :
      path => '/bin:/usr/bin',
      command => "echo '\nhttp_proxy=http://${squid_ip}:${squid_port}\n' >> /etc/wgetrc",
      onlyif  => ["${pingable}", "test `cat /etc/wgetrc | grep 'proxy=http://' | wc -l` == 0"],
      require => Exec['squid-pingtest'],
    }
  }

}

