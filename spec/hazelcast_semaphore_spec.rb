require "spec_helper"

describe HazelcastSemaphore do

  sem = HazelcastSemaphore::Client.new("test_token", host='127.0.0.1', :resource => 5)


  it "should initialize a semaphore" do
    expect(sem.class).to eq(HazelcastSemaphore::Client)
  end

  it "should return available permits" do
    expect(sem.available_permits).to eq(5)
    expect(sem.available_permits).to_not eq(6)
  end

  it "should lock  and unlock permits" do
    sem.lock(2)
    expect(sem.available_permits).to eq(4)

    sem.unlock
    expect(sem.available_permits).to eq(5)
  end

end
