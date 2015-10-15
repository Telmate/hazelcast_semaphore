require "hazelcast_semaphore/jars"

module HazelcastSemaphore
  class Client

    java_import 'com.hazelcast.core.Hazelcast'
    java_import 'com.hazelcast.client.HazelcastClient'
    java_import 'com.hazelcast.client.config.ClientConfig'
    java_import 'com.hazelcast.client.config.ClientNetworkConfig'
    java_import 'com.hazelcast.client.impl.HazelcastClientProxy'
    java_import 'java.util.concurrent.TimeUnit'

    def initialize(name = "default", host="127.0.0.1", opts)
      network_config = ClientNetworkConfig.new
      network_config.addAddress(host)

      client_config = ClientConfig.new
      client_config.setNetworkConfig(network_config)

      @client = HazelcastClient.newHazelcastClient

      @semaphore = @client.getSemaphore(name)
      @semaphore.init(opts[:resource]) if ! semaphore_exists?(name)
    end

    def lock(timeout)
      if @semaphore.tryAcquire(timeout, TimeUnit::SECONDS)
        if block_given?
          yield
        end
      end
    end

    def unlock
      @semaphore.release
    end

    def locked?
      @semaphore.availablePermits.eql? 0
    end

    def available_permits
      @semaphore.availablePermits
    end

    private

    def semaphore_exists?(token_name)
      objects = @client.getDistributedObjects
      objects.each do |obj|
        true if obj.name == token_name
      end
    end

  end
end