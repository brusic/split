# frozen_string_literal: true
ENV['RACK_ENV'] = "test"

require 'rubygems'
require 'bundler/setup'

require 'coveralls'
Coveralls.wear!

require 'split'
require 'ostruct'
require 'yaml'
require 'complex' if RUBY_VERSION.match(/1\.8/)

Dir['./spec/support/*.rb'].each { |f| require f }

require "fakeredis"

fakeredis = Redis.new

RSpec.configure do |config|
  config.order = 'random'
  config.before(:each) do
    Split.configuration = Split::Configuration.new
    Split.redis = fakeredis
    Split.redis.flushall
    @ab_user = mock_user
    params = nil
  end
end

def mock_user
  Split::User.new(double(session: {}))
end

def session
  @session ||= {}
end

def params
  @params ||= {}
end

def request(ua = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_6; de-de) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27')
  @request ||= begin
    r = OpenStruct.new
    r.user_agent = ua
    r.ip = '192.168.1.1'
    r
  end
end
