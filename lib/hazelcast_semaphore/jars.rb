require 'java'

Dir[File.join(File.dirname(__FILE__), "../hazelcast_jars/*.jar")].each do |jar|
  require jar
end
