require 'spec_helper'
describe 'sumologic' do

  context 'with defaults for all parameters' do
    it { should contain_class('sumologic') }
  end
end
