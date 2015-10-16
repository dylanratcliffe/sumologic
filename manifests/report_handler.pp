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
# [*mode*]
#   `stdout` or `json`. Which underlying report handler to use. Stdout will
#   send only the messages that were printed to stdout for each report while
#   json will send the entire puppet report as a JSON file, note that this is
#   approx 430Kb per report but contains awesome info.
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
  $mode        = 'stdout',
) {
  # Validate the mode
  case $mode {
    'stdout' : {
      $stdout_ensure = 'present'
      $json_ensure = 'absent'
    }
    'json'   : {
      $stdout_ensure = 'absent'
      $json_ensure = 'present'
    }
    default  : { fail('Sumologic report handler mode must be: stdout, json') }
  }


  ini_setting { 'enable_reports':
    ensure  => present,
    section => 'agent',
    setting => 'report',
    value   => true,
    path    => "${settings::confdir}/puppet.conf",
  }

  ini_subsetting { 'sumologic_stdout_handler':
    ensure               => $stdout_ensure,
    path                 => "${settings::confdir}/puppet.conf",
    section              => 'master',
    setting              => 'reports',
    subsetting           => 'sumologic_stdout',
    subsetting_separator => ',',
    require              => Ini_setting['enable_reports'],
  }

  ini_subsetting { 'sumologic_json_handler':
    ensure               => $json_ensure,
    path                 => "${settings::confdir}/puppet.conf",
    section              => 'master',
    setting              => 'reports',
    subsetting           => 'sumologic_json',
    subsetting_separator => ',',
    require              => Ini_setting['enable_reports'],
  }

  file { "${settings::confdir}/sumologic.yaml":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "---\n:sumologic_url: '${report_url}'",
  }
}
