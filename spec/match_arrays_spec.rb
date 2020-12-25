RSpec.describe MatchArrays do
  describe "Gem Basic Test" do
    it "has a version number" do
      expect(MatchArrays::VERSION).not_to be nil
    end
  end

  describe "Operation test" do
    let!(:key_ma_only) { "key_ma_only" }
    let!(:key_match) { "key_match" }
    let!(:key_tr_only) { "key_tr_only" }
  
    let!(:value_ma1) { 1 }
    let!(:value_ma2) { 2 }
    let!(:value_tr1) { 3 }
    let!(:value_tr2) { 4 }
  
    let(:masters) { [{ k: key_ma_only, v: value_ma1 }, { k: key_match, v: value_ma2 }] }
    let(:transactions) { [{ k: key_match, v: value_tr1 }, { k: key_tr_only, v: value_tr2 }] }
  
    let(:p_m_key) { proc { |ma| ma[:k] } }
    let(:p_t_key) { proc { |tr| tr[:k] } }
  
    let(:p_match) { proc {|m, t, obj| obj.push("#{output_str_match}#{m[:v] + t[:v]}") } }
    let(:p_tr_only) { proc { |t, obj| obj.push("#{output_str_tr_only}#{t[:v]}") } }
    let(:p_ma_only) { proc { |m, obj| obj.push("#{output_str_ma_only}#{m[:v]}") } }

    let!(:attr_obj) { [] }

    let!(:output_str_match) { "MATCH, Summarised value: " }
    let!(:output_str_tr_only) { "TR only, TR value: " }
    let!(:output_str_ma_only) { "MA only, MA value: " }

    subject do
      MatchArrays.match(
        masters: masters,
        transactions: transactions,
        p_m_key: p_m_key,
        p_t_key: p_t_key,
        p_ma_only: p_ma_only,
        p_tr_only: p_tr_only,
        p_match: p_match,
        attr_obj: attr_obj
      )
    end

    describe "Argument Check" do
      context "Nomal scenario" do
        it "not raise error" do
          expect{ subject }.not_to raise_error ArgumentError
         end
      end

      context "Exception scenario" do
        context "master is not an Array" do
          let(:masters) { 1 }
          it "raise error" do
            expect{ subject }.to raise_error ArgumentError
            expect{ subject }.to raise_error "Only an Array is accepted as the :masters argument."
           end
        end

        context "transactions is not an Array" do
          let(:transactions) { 1 }
          it "raise error" do
            expect{ subject }.to raise_error ArgumentError
            expect{ subject }.to raise_error "Only an Array is accepted as the :transactions argument."
           end
        end

        context "p_m_key is not an Proc" do
          let(:p_m_key) { 1 }
          it "raise error" do
            expect{ subject }.to raise_error ArgumentError
            expect{ subject }.to raise_error "Only an Proc is accepted as the :p_m_key argument."
           end
        end

        context "p_t_key is not an Proc" do
          let(:p_t_key) { 1 }
          it "raise error" do
            expect{ subject }.to raise_error ArgumentError
            expect{ subject }.to raise_error "Only an Proc is accepted as the :p_t_key argument."
           end
        end

        context "p_ma_only is not an Proc" do
          let(:p_ma_only) { 1 }
          it "raise error" do
            expect{ subject }.to raise_error ArgumentError
            expect{ subject }.to raise_error "Only an Proc is accepted as the :p_ma_only argument."
           end
        end

        context "p_tr_only is not an Proc" do
          let(:p_tr_only) { 1 }
          it "raise error" do
            expect{ subject }.to raise_error ArgumentError
            expect{ subject }.to raise_error "Only an Proc is accepted as the :p_tr_only argument."
           end
        end

        context "p_match is not an Proc" do
          let(:p_match) { 1 }
          it "raise error" do
            expect{ subject }.to raise_error ArgumentError
            expect{ subject }.to raise_error "Only an Proc is accepted as the :p_match argument."
           end
        end
      end
    end

    describe "Matching process" do
      context "maが0件" do
        let(:masters) { [] }
        it "'TR only' proc is only executed" do
          expect{ subject }
            .to change{ attr_obj[0] }.from(nil).to("#{output_str_tr_only}#{value_tr1}")
            .and change{ attr_obj[1] }.from(nil).to("#{output_str_tr_only}#{value_tr2}")
        end
      end

      context "transaction is empty" do
        let(:transactions) { [] }
        it "'MA only' proc is only executed" do
          expect{ subject }
            .to change{ attr_obj[0] }.from(nil).to("#{output_str_ma_only}#{value_ma1}")
            .and change{ attr_obj[1] }.from(nil).to("#{output_str_ma_only}#{value_ma2}")
        end
      end

      context "masters and transactions are both empty" do
        let(:masters) { [] }
        let(:transactions) { [] }
        it "No proc is only executed" do
          expect{ subject }.not_to change{ attr_obj }
        end
      end

      context "masters and transactions are not both empty" do
        context 'the first TR matches' do
          it "The procs are executed in the order 'Match -> TR only -> MA only'" do
            expect{ subject }
              .to change{ attr_obj[0] }.from(nil).to("#{output_str_match}#{value_ma2 + value_tr1}")
              .and change{ attr_obj[1] }.from(nil).to("#{output_str_tr_only}#{value_tr2}")
              .and change{ attr_obj[2] }.from(nil).to("#{output_str_ma_only}#{value_ma1}")
          end
        end

        context 'the second TR matches' do
          let(:transactions) { [{ k: key_tr_only, v: value_tr1 }, { k: key_match, v: value_tr2 }] }
          it "The procs are executed in the order 'TR only -> Match -> MA only'" do
            expect{ subject }
              .to change{ attr_obj[0] }.from(nil).to("#{output_str_tr_only}#{value_tr1}")
              .and change{ attr_obj[1] }.from(nil).to("#{output_str_match}#{value_ma2 + value_tr2}")
              .and change{ attr_obj[2] }.from(nil).to("#{output_str_ma_only}#{value_ma1}")
          end
        end
      end
    end
  end
end
