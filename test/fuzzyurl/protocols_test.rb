require 'test_helper'

describe Fuzzyurl::Protocols do
  describe 'get_port' do
    it 'gets port by protocol' do
      assert_equal('80', Fuzzyurl::Protocols.get_port('http'))
      assert_equal('443', Fuzzyurl::Protocols.get_port('https'))
      assert_equal('22', Fuzzyurl::Protocols.get_port('git+ssh'))
      assert_equal(nil, Fuzzyurl::Protocols.get_port('hi mom'))
      assert_equal(nil, Fuzzyurl::Protocols.get_port(nil))
    end
  end

  describe 'get_protocol' do
    it 'gets protocol by port' do
      assert_equal('http', Fuzzyurl::Protocols.get_protocol('80'))
      assert_equal('http', Fuzzyurl::Protocols.get_protocol(80))
      assert_equal(nil, Fuzzyurl::Protocols.get_protocol(nil))
      assert_equal(nil, Fuzzyurl::Protocols.get_protocol(-22))
    end
  end
end
