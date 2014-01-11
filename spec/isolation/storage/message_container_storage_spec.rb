require_relative '../../rspec'
require_relative '../../../model/storage/message_storage'
require_relative '../../../model/storage/message_container_storage'

describe MessageContainerStorage do
  describe '#value_to_hash' do
    FakeMessageContainer = Struct.new(:key, :value)

    it 'delegates to MessageStorage' do
      message = 'message placeholder'
      c = FakeMessageContainer.new 'key', message
      MessageStorage.should_receive(:new).with(message).and_return({})
      MessageContainerStorage.new(c).value_to_hash
    end
  end

  describe '::value_from_hash' do
    it 'delegates to MessageStorage' do
      hash = {}
      MessageStorage.should_receive(:from_hash).with(hash)
      MessageContainerStorage.value_from_hash(hash)
    end
  end
end