require 'spec_helper'
require 'puppet'

describe 'sumologic::report_handler' do

  context 'with defaults for all parameters' do
    it { should_not compile }
  end

  context 'with incorrect mode parameter' do
    let(:params) {
      {
        :report_url => 'https://www.google.com',
        :mode => 'foo'
      }
    }
    it { should_not compile }
  end

  context 'with the mode parameter omitted' do
    let(:params) {
      {
        :report_url => 'https://www.google.com'
      }
    }

    it { should compile }

    it { should contain_ini_setting('enable_reports').with({
      'setting' => 'report',
      'value' => 'true'
      })}

    it { should contain_ini_subsetting('sumologic_json_handler').with({
      'ensure' => 'absent'
    })}

    it { should contain_ini_subsetting('sumologic_stdout_handler').with({
      'ensure' => 'present'
    })}

    it { should contain_file("/etc/puppet/sumologic\.yaml").with({
      'content' => "---\n:sumologic_url: 'https://www.google.com'"
      })}
  end

  context 'with all parameters being valid in stdout mode' do
    let(:params) {
      {
        :report_url => 'https://www.google.com',
        :mode => 'stdout'
      }
    }

    it { should compile }

    it { should contain_ini_setting('enable_reports').with({
      'setting' => 'report',
      'value' => 'true'
      })}

    it { should contain_ini_subsetting('sumologic_json_handler').with({
      'ensure' => 'absent'
    })}

    it { should contain_ini_subsetting('sumologic_stdout_handler').with({
      'ensure' => 'present'
    })}


    it { should contain_file("/etc/puppet/sumologic\.yaml").with({
      'content' => "---\n:sumologic_url: 'https://www.google.com'"
      })}
  end

  context 'with all parameters being valid in json mode' do
    let(:params) {
      {
        :report_url => 'https://www.google.com',
        :mode => 'json'
      }
    }

    it { should compile }

    it { should contain_ini_setting('enable_reports').with({
      'setting' => 'report',
      'value' => 'true'
      })}

    it { should contain_ini_subsetting('sumologic_json_handler').with({
      'ensure' => 'present'
    })}

    it { should contain_ini_subsetting('sumologic_stdout_handler').with({
      'ensure' => 'absent'
    })}


    it { should contain_file("/etc/puppet/sumologic\.yaml").with({
      'content' => "---\n:sumologic_url: 'https://www.google.com'"
      })}
  end
end
