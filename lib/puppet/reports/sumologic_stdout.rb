require 'puppet'
require 'puppet/reportallthethings/helper'
require 'tempfile'
require 'json'

Puppet::Reports.register_report(:sumologic) do
  desc "Process reports via Sumologic"

  configfile = File.join([File.dirname(Puppet.settings[:config]), "sumologic.yaml"])
  raise(Puppet::ParseError, "Sumologic report config file #{configfile} not readable") unless File.exist?(configfile)
  config = YAML.load_file(configfile)
  SUMO_URL = config[:sumologic_url]

  def process
    # Save the report to a file
    report_file = Tempfile.new('report')
    report_file.write(self.logs.each)
    report_file.rewind

    # Just shell out to cURL to upload it, easier than constructing the request with net::HTTP
    # and probably faster than importing any more libraries.
    result = `curl -v -X POST -T #{report_file.path} #{SUMO_URL}`

    report_file.close
    report_file.unlink
  end
end
