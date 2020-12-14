#
# @summary define some variables based on the operating system
class milter_xmpp::params {

  case $::osfamily {
    'RedHat': {
      $rel = $facts['os']['release']['major']

      if $rel == '8' {
        $prerequisites = ['python36-devel',
                          'python3-dns',
                          'python3-pip',
                          'python3-setuptools',
                          'python3-pymilter']

        $devel_tools = ['gcc', 'gcc-c++', 'make']

      } else {
        fail("${facts['os']['name']} ${rel} is not supported!")
      }
    }
    'Debian': {
      $prerequisites = ['python3-dev',
                        'python3-dnspython',
                        'python3-pip',
                        'python3-setuptools',
                        'libmilter-dev']

      $devel_tools = ['build-essential']
    }
    default: {
      fail("Unsupported operating system ${facts['os']['name']}")
    }
  }
}
