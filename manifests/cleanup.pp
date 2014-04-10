class dosquid::cleanup (
) {

  # remove reference to squid from yum config  
  exec { 'squid-unpoint-yum' :
    path => '/bin:/usr/bin',
    command => "sed -i '/proxy=http/d' /etc/yum.conf",
    onlyif => 'test -f /etc/yum.conf',
  }

  # tell yum to use mirrors again, but leave baseurl uncommented
  exec { 'squid-unpoint-yum-repos' :
    path => '/bin:/usr/bin',
    command => "sed -i -e 's/^#mirrorlist/mirrorlist/g' /etc/yum.repos.d/*.repo",
    onlyif => 'test -d /etc/yum.repos.d/',
  }
  
  # could find just the repos which have mirrorlists, but it's not essential
  # `grep -H -r 'mirrorlist' /etc/yum.repos.d/*.repo | cut -d: -f1 | uniq`

  # tell wget not to use proxy
  exec { 'squid-unpoint-wget' :
    path => '/bin:/usr/bin',
    command => "sed -i '/http_proxy=http/d' /etc/wgetrc",
  }

}

