Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

Class['apt::update'] -> Package <| |>

  file { '/etc/motd':
     content => "Welcome to your Vagrant-built virtual machine!
                 Managed by Puppet.\n"
  }

  apt::key { "jenkins":
        key        => "D50582E6",
        key_source => "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key",
  }

  apt::source { 'jenkins':
      location   => 'http://pkg.jenkins-ci.org/debian',
      repos      => 'main',
      key        => "D50582E6",
  }

  package {'jenkins':
      ensure => present,
    require => Package['openjdk-6-jre-headless'],
}

package { 'openjdk-6-jre-headless':
    ensure => present,
    require => Apt::Source['jenkins'],
}

package {'nginx':
  ensure => present,
}

file {'/etc/nginx/sites-available/default':
    ensure => absent,
    require => Package['nginx'],
}

exec {'copy-jenkins.nginx':
  require => Package['nginx'],
  command => 'cp /vagrant_data/jenkins.nginx /etc/nginx/sites-available/jenkins',
}

file {'/etc/nginx/sites-enabled/jenkins':
  ensure => link,
  target => '/etc/nginx/sites-available/jenkins',
  require => Exec['copy-jenkins.nginx'],
  notify => Service['nginx'],
}

service {'nginx':
  ensure => 'running',
}
