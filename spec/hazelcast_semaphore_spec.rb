require "spec_helper"

describe HazelcastSemaphore do

  hclient = HazelcastSemaphore::Client.new('127.0.0.1')

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
    pending 'Implement me'
  end

  it "should NOT allow execution when there are no available permits" do
    pending 'Implement me'
  end

  it "should tell if a semaphore exists" do
    pending 'Implement me'
  end

end
