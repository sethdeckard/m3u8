require 'spec_helper'

describe do
  let(:test_class) { Class.new { extend M3u8 } }

  it 'should parse attributes to hash' do
    line = %(TEST-ID="Help",URI="http://test",ID=33\n)
    hash = test_class.parse_attributes line
    expect(hash['TEST-ID']).to eq 'Help'
    expect(hash['URI']).to eq 'http://test'
    expect(hash['ID']).to eq '33'
  end

  it 'should parse yes/no string' do
    value = 'YES'
    expect(test_class.parse_yes_no value).to be true
    value = 'NO'
    expect(test_class.parse_yes_no value).to be false
  end
end
