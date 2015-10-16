require 'simplecov'

SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

Dir[File.join(File.dirname(__FILE__), "../lib/hazelcast_jars/test/*.jar")].each do |jar|
  puts "requiring #{jar}"
  require jar
end

require 'hazelcast_semaphore'


