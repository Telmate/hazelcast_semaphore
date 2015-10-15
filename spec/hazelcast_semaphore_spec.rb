require "spec_helper"

describe HazelcastSemaphore do

  context "multiple number of resources" do
    semaphore = HazelcastSemaphore::Client.new("multi_token_sample", host='127.0.0.1', :resource => 5)

    it "should initialize a semaphore" do
      expect(semaphore.class).to eq(HazelcastSemaphore::Client)
    end

    it "should return the correct number of available resources" do
      p "Available permit for semaphore #{semaphore.available_permits}"
      expect(semaphore.available_permits).to eq(5)
      expect(semaphore.available_permits).to_not eq(6)
    end

    it "should return the correct number of available resource after locking" do
      semaphore.lock
      expect(semaphore.available_permits).to eq(4)
    end

    it "should return the correct number of available resources after unlocking" do
      semaphore.unlock
      expect(semaphore.available_permits).to eq(5)
    end

  end


  context "single number of resource" do
    semaphore = HazelcastSemaphore::Client.new("single_token_sample", host='127.0.0.1', :resource => 1)

    it "should lock and unlock" do
      p "Locking semaphore with count #{semaphore.available_permits}"

      semaphore.lock
      expect(semaphore.locked?).to eq(true)

      semaphore.unlock
      expect(semaphore.locked?).to eq(false)
    end

  end

end
