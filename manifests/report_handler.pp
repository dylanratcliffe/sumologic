# == Class: sumologic
#
# Full description of class sumologic here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'sumologic':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class sumologic::report_handler (
  $report_url,
  $other_handlers = ['console','puppetdb'],
  $puppet_conf = '/etc/puppetlabs/puppet/puppet.conf',
) {
  #Join the array into a string
  $handlers = join([$other_handlers, 'http'],',')

  ini_setting { 'enable_reports':
    ensure  => present,
    section => 'agent',
    setting => 'report',
    value   => true,
    path    => $puppet_conf,
  }

  ini_setting { 'reports_setting':
    ensure  => present,
    section => 'master',
    setting => 'reports',
    value   => $handlers,
    path    => $puppet_conf,
    require => File_line['enable_reports'],
  }

  ini_setting { 'report_url':
    ensure  => present,
    section => 'master',
    setting => 'reporturl',
    value   => $report_url,
    path    => $puppet_conf,
    require => File_line['reports_setting'],
  }
}
