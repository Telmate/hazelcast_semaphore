require "spec_helper"
require 'java'

class TestSupport < Java::ComHazelcastTest::HazelcastTestSupport
end

describe HazelcastSemaphore do

  inst = TestSupport.new.createHazelcastInstance

  hclient = HazelcastSemaphore::Client.new('127.0.0.1', :hazelcast_instance => inst)
  #hclient = HazelcastSemaphore::Client.new()

  after(:all) do
    hclient.shutdown if hclient
  end

  it "inits a semaphore with the given number of permits" do
    token = "#{Time.now.to_i}#{rand(1000000)}"
    expect(hclient.exists?(token)).to be false
    expect(hclient.init(token, 4)).to be true
    expect(hclient.exists?(token)).to be true
    expect(hclient.available?(token)).to be true
    hclient.destroy(token)
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
    hclient.destroy(token)
  end

  it "should allow only up to initialized number of simultaneous executions" do
    token = "#{Time.now.to_i}#{rand(1000000)}"
    hclient.init(token, 4)
    expect(hclient.available?(token)).to be true

    ths = []
    4.times.each do
      ths << Thread.new { hclient.exec_inside(token) { sleep 2 } }
    end

    sleep 0.1 # wait for all the threads to start

    expect(hclient.available?(token)).to be false
    expect { hclient.exec_inside(token, 100) {  } }.to raise_error(/Timeout/)

    ths.each(&:join)
    expect(hclient.available?(token)).to be true
    hclient.destroy(token)
  end

  it "should tell if a semaphore exists" do
    token = "#{Time.now.to_i}#{rand(1000000)}"
    hclient.init(token, 2)

    expect(hclient.exists?(token)).to be true
    expect(hclient.exists?("unknown_token")).to be false
    hclient.destroy(token)
  end

end

