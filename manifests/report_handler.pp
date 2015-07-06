# == Class: sumologic::report_handler
#
# This class sets up the https report handler. At the moment it is not 
# Sumologic specific so once I work out what the specifics are I can set it up 
# more easily.
# 
# It is important to note that this class requires a restart of the puppet
# server. This can be implemented with something like this:
# 
# ```
# class { 'sumologic::report_handler':
#   notify => Service['pe-puppetserver'],
# }
# ```
# === Parameters
#
# [*report_url*]
#   Address to send the reports to
#
# [*puppet_conf*]
#   Location of the puppet.conf file, default uses the confdir value from
#   Puppet's settings to locate the file so it should usually be fine.
#
# === Examples
#
#  class { 'sumologic':
#    report_url => 'https://reports.somewhere.com/some/api/endpoint,
#  }
#
# === Authors
#
# Dylan Ratcliffe <dylanratcliffe@puppetlabs.com>
#
# === Copyright
#
# Copyright 2015 Dylan Ratcliffe
#
class sumologic::report_handler (
  $report_url,
  $puppet_conf = "${settings::confdir}/puppet.conf",
) {

  ini_setting { 'enable_reports':
    ensure  => present,
    section => 'agent',
    setting => 'report',
    value   => true,
    path    => $puppet_conf,
  }

  ini_subsetting { 'reports_console':
    ensure               => present,
    path                 => $puppet_conf,
    section              => 'master',
    setting              => 'reports',
    subsetting           => 'http',
    subsetting_separator => ',',
    require              => Ini_setting['enable_reports'],
  }

  ini_setting { 'report_url':
    ensure  => present,
    section => 'master',
    setting => 'reporturl',
    value   => $report_url,
    path    => $puppet_conf,
    require => Ini_setting['reports_setting'],
  }
}
