require "hazelcast_semaphore/jars"

module HazelcastSemaphore
  class Client

    java_import 'com.hazelcast.core.Hazelcast'
    java_import 'com.hazelcast.client.HazelcastClient'
    java_import 'com.hazelcast.client.config.ClientConfig'
    java_import 'com.hazelcast.client.config.ClientNetworkConfig'
    java_import 'java.util.concurrent.TimeUnit'

    def initialize(host = "127.0.0.1")
      # TODO create a hazelcast client according to environment? e.g., mock if testing
      network_config = ClientNetworkConfig.new
      network_config.addAddress(host)

      client_config = ClientConfig.new
      client_config.setNetworkConfig(network_config)

      @client = HazelcastClient.newHazelcastClient
    end

    def init(token, num_permits = 1)
      sem = @client.getSemaphore(token)
      sem.init(num_permits)
    end

    def destroy(token)
      @client.getSemaphore(token).destroy
    end

    def exec_inside(token, timeout = 4)
      sem = @client.getSemaphore(token)
      if block_given?
        if sem.tryAcquire(timeout, TimeUnit::SECONDS)
          yield
          sem.release
        else
          raise "Timeout in #{timeout}s waiting for execution"
        end
      end
    end

    def exists?(token)
      sem = @client.getDistributedObjects.find { |e| e.is_a?(Java::ComHazelcastCore::ISemaphore) && e.getName == token }
      !sem.nil?
    end

    def shutdown
      @client.shutdown
      @client = nil
    end
  end
end