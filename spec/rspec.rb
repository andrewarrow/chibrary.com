require 'rspec'
require 'ostruct'

require_relative '../value/message_id'
require_relative '../value/sym'
require_relative '../repo/riak_repo'
require_relative '../repo/redis_repo'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.alias_example_to :expect_it

  config.before(:each) do
    module RiakRepo::ClassMethods
      def db_client
        FakeRepo.new
      end
    end

    module RedisRepo
      def self.db_client
        FakeRepo.new
      end
    end
  end
end

# http://stackoverflow.com/questions/12260534/using-implicit-subject-with-expect-in-rspec-2-11
RSpec::Core::MemoizedHelpers.module_eval do
  alias to should
  alias to_not should_not
end

class CNSTestRunIdService
  def run_id
    1
  end

  def next! ; end
end

class CNSTestSequenceIdService
  def consume_sequence_id!
    2
  end
end

class FakeRepo
  def method_missing *args
    raise RuntimeError, "accidentally called a real storage method in test"
  end
end

class FakeMessage
  attr_reader :message_id, :message, :key

  def initialize message_id='id@example.com'
    @message_id = MessageId.new(message_id)
  end

  def list ; OpenStruct.new(slug: 'slug') ; end
  def from ; 'from@example.com' ; end
  def subject_is_reply? ; false ; end
  def date ; Time.new(2013, 11, 21) ; end
  def email ; 'email' ; end
end

class FakeStorableMessage < FakeMessage
  def email ; OpenStruct.new(canonicalized_from_email: 'from@example.com') ; end
  def source ; 'source' ; end
  def call_number ; 'callnumber' ; end
end

FakeThreadSet = Struct.new(:threads) do
  def sym ; Sym.new('slug', 2014, 12) ; end
end
FakeThreadLink = Struct.new(:call_number, :subject) do
  def n_subject ; subject ; end
end
def fake_thread_set call_numbers
  FakeThreadSet.new call_numbers.map { |c| FakeThreadLink.new(c, "subject #{c}") }
end
