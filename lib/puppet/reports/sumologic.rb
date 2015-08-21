require 'puppet'
require 'puppet/reportallthethings/helper'
require 'tempfile'
require 'net/http'
require 'json'
require 'mime/types'

Puppet::Reports.register_report(:sumologic) do
  desc "Process reports via Sumologic"

  configfile = File.join([File.dirname(Puppet.settings[:config]), "sumologic.yaml"])
  raise(Puppet::ParseError, "Sumologic report config file #{configfile} not readable") unless File.exist?(configfile)
  config = YAML.load_file(configfile)
  sumo_url = config[:sumologic_url]

  def process
    # Save the report to a file
    report_file = Tempfile.new('report')
    report_file.write(JSON.pretty_generate(Puppet::ReportAllTheThings::Helper.report_all_the_things(self)))
    report_file.rewind

    # Just shell out to cURL to upload it, easier than constructing the request with net::HTTP
    # and probably faster than importing any more libraries.
    result = `curl -v -X POST -T #{report_file.path} #{sumo_url}`

    report_file.close
    report_file.unlink
  end
end
