require_relative '../../rspec'
require_relative '../../../repo/time_sort_repo'

describe TimeSortRepo do
  context 'instantiated with a TimeSort' do
    it "generates a key based on sym" do
      ts = TimeSort.new sym_collaborator
      TimeSortRepo.new(ts).extract_key
    end

    describe "generating a hash" do
      let(:ts) { ts = TimeSort.from fake_thread_set(['one', 'two']) }
      let(:time_sort_repo) { TimeSortRepo.new(ts) }
      subject { time_sort_repo.serialize }

      it { expect(subject.count).to eq(2) }
      it { expect(subject.first).to eq({
        call_number: 'one',
        subject: 'subject one',
      }) }
    end
  end

  describe "::build_key" do
    it "delegates building a key to sym" do
      TimeSortRepo.build_key(sym_collaborator)
    end
  end

  describe "::find" do
    it "instantiates a TimeSort from the bucket" do
      sym = Sym.new('slug', 2014, 4)
      bucket = double('bucket')
      bucket.should_receive(:[]).with('slug/2014/04').and_return([
        {
          call_number: 'aaaaaaaa',
          subject: 'subject one',
        },
      ])
      TimeSortRepo.should_receive(:bucket).and_return(bucket)
      ts = TimeSortRepo.find(sym)
      expect(ts).to be_a(TimeSort)
      expect(ts.sym).to eq(sym)
      expect(ts.threads.count).to eq(1)
      tl = ts.threads.first
      expect(tl.sym).to eq(sym)
      expect(tl.call_number).to eq('aaaaaaaa')
      expect(tl.subject).to eq('subject one')
    end
  end
end