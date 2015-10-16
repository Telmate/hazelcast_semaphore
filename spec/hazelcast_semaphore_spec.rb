require "spec_helper"
require 'java'

class TestSupport < Java::ComHazelcastTest::HazelcastTestSupport
end

describe HazelcastSemaphore do

  support = TestSupport.new
  inst = support.createHazelcastInstance

  hclient = HazelcastSemaphore::Client.new('127.0.0.1', :hazelcast_instance => inst)

  after(:all) do
    hclient.shutdown if hclient
  end

  it "inits a semaphore with the given number of permits" do
    token = "#{Time.now.to_i}#{rand(1000000)}"
    expect(hclient.exists?(token)).to be false
    expect(hclient.init(token, 4)).to be true
    expect(hclient.exists?(token)).to be true
  end

  it "destroys a semaphore" do
    token = "#{Time.now.to_i}#{rand(1000000)}"
    expect(hclient.init(token, 4)).to be true
    expect(hclient.exists?(token)).to be true
    hclient.destroy(token)
    expect(hclient.exists?(token)).to be false
  end

  it "should allow execution if there are available permits" do
    token = "#{Time.now.to_i}#{rand(1000000)}"
    hclient.init(token, 4)
    hclient.exec_inside(token) do
      expect(true).to be true
    end
  end

  it "should allow only up to available_permits number of executions" do
    token = "#{Time.now.to_i}#{rand(1000000)}"
    hclient.init(token, 4)

    4.times.each do
      Thread.new { hclient.exec_inside(token) { sleep 2 } }
    end
    expect(hclient.available_permits(token)).to eq 0
  end

  it "should NOT allow execution when there are no available permits" do
    token = "#{Time.now.to_i}#{rand(1000000)}"
    hclient.init(token, 2)

    2.times.each do
      Thread.new { hclient.exec_inside(token) { sleep 10 } }
    end
    expect { hclient.exec_inside(token, 2) { } }.to raise_error(RuntimeError, "Timeout in 2s waiting for execution")
  end

  it "should tell if a semaphore exists" do
    token = "#{Time.now.to_i}#{rand(1000000)}"
    hclient.init(token, 2)

    expect(hclient.exists?(token)).to be true
    expect(hclient.exists?("unknown_token")).to be false
  end

end

