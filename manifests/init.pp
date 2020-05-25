#
# @summary setup milter-xmpp as a system service
#
# @param install_prerequisites
#   Install software required for milter-xmpp to work.
# @param jabberid
#   Jabber/XMPP ID
# @param password
#   XMPP password
# @param room
#   The XMPP chatroom to join
# @param server
#   The XMPP server to connect to
# @param valid_from
#   Only forward emails which have this address in the "From" field
# @param proto
#   The procotol to use for milter's TCP socket.
# @param port
#   The port the milter listens on.
# @param iface
#   The interface/IP/hostname the milter listens on.
#
# @see https://github.com/Puppet-Finland/milter-xmpp/
#
class milter_xmpp
(
  Boolean               $install_prerequisites,
  String                $jabberid,
  String                $password,
  String                $room,
  String                $server,
  String                $valid_from,
  Enum['inet', 'inet6'] $proto,
  Integer               $port = 8894,
  String                $iface = 'localhost'
)
{

  $config_dir = '/etc/milter-xmpp'

  if $install_prerequisites {
    package { ['python3-pip', 'libmilter-dev', 'build-essential']:
      ensure => 'present',
    }

    package { ['pymilter', 'xmpppy']:
      ensure   => 'present',
      provider => 'pip3',
      require  => Package['python3-pip'],
    }
  }

  vcsrepo { '/opt/milter-xmpp':
    ensure   => 'present',
    provider => 'git',
    source   => 'https://github.com/Puppet-Finland/milter-xmpp.git',
  }

  file { $config_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  file { "${config_dir}/milter-xmpp":
    ensure  => 'present',
    content => template('milter_xmpp/milter-xmpp.ini.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => File[$config_dir],
    notify  => Service['milter-xmpp'],
  }

  file { '/etc/systemd/system/milter-xmpp.service':
    ensure  => 'present',
    content => template('milter_xmpp/milter-xmpp.service.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Exec['milter-xmpp-systemctl-daemon-reload'],
  }

  exec { 'milter-xmpp-systemctl-daemon-reload':
    command     => 'systemctl daemon-reload',
    path        => '/bin:/sbin',
    refreshonly => true,
  }

  service { 'milter-xmpp':
    ensure  => 'running',
    enable  => true,
    require => [ File['/etc/systemd/system/milter-xmpp.service'], Exec['milter-xmpp-systemctl-daemon-reload'], File["${config_dir}/milter-xmpp"] ], # lint:ignore:140chars
  }
}
