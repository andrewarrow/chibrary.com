require_relative '../rspec'
require_relative '../../value/message_id'
require_relative '../../value/thread_link'
require_relative '../../model/message'
require_relative '../../model/thread'

module Chibrary

describe Thread do
  let(:message) { Message.from_string "From: a@example.com\nDate: 2014-08-19 07:37:00\nSubject: a\n\nBody", 'callnumb' }

  describe '::initialize' do
    it 'imports messages from Threads' do
      thread1 = Thread.new :slug, [message]
      thread2 = Thread.new :slug, thread1
      expect(thread2.count).to eq(1)
    end

    it 'imports messages from an array' do
      thread = Thread.new :slug, [message]
      expect(thread.count).to eq(1)
    end

    it 'requries one container' do
      expect {
        Thread.new :slug, []
      }.to raise_error(ArgumentError)
    end

    it 'errors if a block is given to catch collisions with built-in Thread' do
      expect {
        Thread.new(:slug, []) { |a| a }
      }.to raise_error(ArgumentError)
    end
  end

  describe '#sym' do
    it 'is based on the root message' do
      m = Message.from_string "Subject: a\nDate: 2014-08-19 07:40:00\n\nBody", 'callnumb'
      thread = Thread.new :slug, [m]
      expect(thread.sym).to eq(Sym.new('slug', 2014, 8))
    end
  end

  describe 'sorting' do
    it 'is based on date only' do
      m1 = Message.from_string "Subject: a\nDate: 2014-08-20 07:40:00\n\nBody", 'callnumb'
      m2 = Message.from_string "Subject: a\nDate: 2014-08-19 07:40:00\n\nBody", 'callnumb'
      t1 = Thread.new :slug, [m1]
      t2 = Thread.new :slug, [m2]
      threads = [t1, t2]
      expect(threads.sort).to eq([t2, t1])
    end
  end

  describe '#call_numbers' do
    it 'returns call numbers' do
      m1 = Message.from_string "Subject: a\n\nBody", 'callnum1'
      m2 = Message.from_string "Subject: a\n\nBody", 'callnum2'
      thread = Thread.new(:slug, [m1, m2])
      expect(thread.call_numbers).to eq(['callnum1', 'callnum2'])
    end

    it 'does not return duplicates because of empty containers' do
      m = Message.from_string "Subject: a\nMessage-Id: b@example.com\nIn-Reply-To: a@example.com\n\nBody", 'callnumb'
      thread = Thread.new(:slug, [m])
      expect(thread.call_numbers).to eq(['callnumb'])
    end
  end

  describe '#message_count' do
    it 'ignores empty containers' do
      m = Message.from_string "Subject: a\nMessage-Id: b@example.com\nIn-Reply-To: a@example.com\n\nBody", 'callnumb'
      thread = Thread.new :slug, [m]
      expect(thread.containers.count).to eq(2)
      expect(thread.message_count).to eq(1)
    end
  end

  describe '#message_ids' do
    it 'returns message_ids' do
      m1 = Message.from_string "Message-Id: 1@example.com\n\nBody", 'callnum1'
      m2 = Message.from_string "Message-Id: 2@example.com\n\nBody", 'callnum2'
      thread = Thread.new :slug, [m1, m2]
      expect(thread.message_ids).to eq(['1@example.com', '2@example.com'])
    end

    it 'does include empty containers' do
      m = Message.from_string "Message-Id: 2@example.com\nIn-Reply-To: 1@example.com\n\nBody", 'callnum2'
      thread = Thread.new :slug, [m]
      expect(thread.message_ids).to eq(['1@example.com', '2@example.com'])
    end
  end

  describe '#n_subjects' do
    it 'returns normalized subjects' do
      m1 = Message.from_string "Subject: Fwd: 1  \n\nBody", 'callnum1'
      m2 = Message.from_string "Subject: Re: 2\n\nBody", 'callnum2'
      thread = Thread.new(:slug, [m1, m2])
      expect(thread.n_subjects).to eq(['1', '2'])
    end

    it 'does not include duplicates' do
      m1 = Message.from_string "Subject: 1\n\nBody", 'callnum1'
      m2 = Message.from_string "Subject: 1\n\nBody", 'callnum2'
      thread = Thread.new(:slug, [m1, m2])
      expect(thread.n_subjects).to eq(['1'])
    end
  end

  describe '#conversation_for?' do
    it 'is not the conversation is not on the same list'

    it 'is if there is an empty container for it' do
      m1 = Message.from_string "Message-Id: 2@example.com\nIn-Reply-To: 1@example.com\n\nBody", 'callnum2'
      thread = Thread.new :slug, [m1]
      m2 = Message.from_string "Message-Id: 1@example.com\n\nBody", 'callnum2'
      expect(thread).to be_conversation_for(m2)
    end

    it 'is not if the subject does not match' do
      m1 = Message.from_string "Subject: 1\n\nBody", 'callnum1'
      thread = Thread.new(:slug, [m1])
      m2 = Message.from_string "Subject: 2\n\nBody", 'callnum2'
      expect(thread).not_to be_conversation_for(m2)
    end

    it 'is if matching quotes' do
      m1 = Message.from_string "\n\nm1 text", 'callnum1'
      thread = Thread.new(:slug, [m1])
      m2 = Message.from_string "\n\n> m1 text\nm2", 'callnum2'
      expect(thread).to be_conversation_for(m2)
    end
  end

  describe '#<<' do
    it 'stores Messages' do
      m0 = Message.from_string "Message-Id: 0@example.com\n\nBody", 'callnum0'
      thread = Thread.new(:slug, [m0])

      m1 = Message.from_string "Message-Id: 1@example.com\n\nBody", 'callnum1'
      thread << m1
      expect(thread.call_numbers).to include('callnum1')
    end

    it 'stores MessageContainers' do
      m0 = Message.from_string "Message-Id: 0@example.com\n\nBody", 'callnum0'
      thread = Thread.new(:slug, [m0])

      m1 = Message.from_string "Message-Id: 1@example.com\n\nBody", 'callnum1'
      thread << MessageContainer.new(m1.message_id, m1)
      expect(thread.call_numbers).to include('callnum1')
    end

    it 'parents the message' do
      m0 = Message.from_string "Message-Id: 0@example.com\n\nBody", 'callnum0'
      thread = Thread.new(:slug, [m0])

      m1 = Message.from_string "Message-Id: 1@example.com\nIn-Reply-To: 0@example.com\n\nBody", 'callnum1'
      thread << m1
      expect(thread.containers[MessageId.new('1@example.com')].parent.message_id).to eq('0@example.com')
    end

    it 'may update the thread root' do
      m0 = Message.from_string "Subject: Re: foo\n\nBody", 'callnum0'
      thread = Thread.new(:slug, [m0])

      m1 = Message.from_string "Subject: foo\n\nBody", 'callnum1'
      thread << m1
      expect(thread.root.call_number).to eq('callnum1')
    end

    it 'may make the message a parent' do
      m0 = Message.from_string "Subject: Re: foo\n\nBody", 'callnum1'
      thread = Thread.new(:slug, [m0])

      m1 = Message.from_string "Subject: foo\n\nBody", 'callnum0'
      thread << m1
      expect(thread.root.call_number).to eq('callnum0')
      expect(thread.root.children.first.call_number).to eq('callnum1')
    end
  end

  describe '#store_in_container' do
    it 'creates containers' do
      m0 = Message.from_string "Message-Id: 0@example.com\n\nBody", 'callnum0'
      thread = Thread.new(:slug, [m0])
      m1 = Message.from_string "Message-Id: 1@example.com\n\nBody", 'callnum1'
      thread.send(:store_in_container, m1)
      expect(thread.containers.keys).to include('1@example.com')
    end

    it 'does not store duplicates, because Filer should have overlaid' do
      m1 = Message.from_string "Message-Id: 1@example.com\n\nBody", 'callnum1'
      m2 = Message.from_string "Message-Id: 1@example.com\n\nBody", 'callnum2'
      thread = Thread.new :slug, [m1]
      expect(thread.send(:store_in_container, m2).message).to be(m1)
    end

    it 'uses empty containers' do
      m0 = Message.from_string "Message-Id: 0@example.com\nIn-Reply-To: 1@example.com\n\nBody", 'callnum0'
      thread = Thread.new(:slug, [m0])
      m1 = Message.from_string "Message-Id: 1@example.com\n\nBody", 'callnum1'
      c = thread.send(:store_in_container, m1)
      expect(c).to be_a(MessageContainer)
      expect(thread.containers.count).to eq(2)
    end
  end

  describe '#find_or_create_container' do
    it 'finds containers if existing' do
      m0 = Message.from_string "Message-Id: 0@example.com\nIn-Reply-To: 1@example.com\n\nBody", 'callnum0'
      thread = Thread.new(:slug, [m0])
      m1 = Message.from_string "Message-Id: 1@example.com\n\nBody", 'callnum1'
      root = thread.root
      c = thread.send(:find_or_create_container, m1.message_id)
      expect(c).to be(root)
    end

    it 'creates containers if needed' do
      m0 = Message.from_string "Message-Id: 0@example.com\n\nBody", 'callnum0'
      m1 = Message.from_string "Message-Id: 1@example.com\n\nBody", 'callnum1'
      thread = Thread.new(:slug, [m0])
      expect {
        thread.send(:find_or_create_container, m1.message_id)
      }.to change { thread.containers.count }.by(1)
    end
  end

  describe '#parent_references' do
    it 'sets the references given' do
      m2 = Message.from_string "Message-Id: 2@example.com\nIn-Reply-To: 1@example.com\nReferences: 0@example.com 1@example.com\n\nBody", 'callnum0'
      thread = Thread.new(:slug, [m2])
      expect(thread.root.message_id).to eq('0@example.com')
      expect(thread.root.children.first.message_id).to eq('1@example.com')
      expect(thread.root.children.first.children.first.message_id).to eq('2@example.com')
    end
  end

  describe '#set_root' do
    it 'takes the first container available' do
      m0 = Message.from_string "Message-Id: 0@example.com\n\nBody", 'callnum0'
      thread = Thread.new(:slug, [m0])
      expect(thread.root.message_id).to eq(m0.message_id)
    end

    it 'prefers an empty container to a full one' do
      m2 = Message.from_string "Message-Id: 2@example.com\nIn-Reply-To: 1@example.com\n\nBody", 'callnum0'
      thread = Thread.new(:slug, [m2])
      expect(thread.root.message_id).to eq('1@example.com')
    end

    it 'prefers messages with less re/fwd gunk' do
      m1 = Message.from_string "Subject: a\n\nBody", 'callnum1'
      m2 = Message.from_string "Subject: Re: a\n\nBody", 'callnum2'
      thread = Thread.new(:slug, [m1, m2])
      expect(thread.root.call_number).to eq('callnum1')
    end
  end

  describe '#parent_messages_without_references' do
    it 'parents to the message with the most quotes' do
      m1 = Message.from_string "\n\nquoted text 1\nquoted text 2\nquoted text 3", 'callnum1'
      m2 = Message.from_string "\n\nquoted text 1\nquoted text 2", 'callnum2'
      m3 = Message.from_string "\n\n> quoted text 1\n> quoted text 2\n> quoted text 3\n\nm2", 'callnum3'
      thread = Thread.new(:slug, [m1, m2, m3])
      expect(thread.containers[MessageId.new 'callnum3@generated-message-id.chibrary.org'].parent.call_number).to eq('callnum1')
    end
  end
end

end