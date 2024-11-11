# frozen_string_literal: true

require "ruby_mod_kit"

describe RubyModKit::Transpiler do
  let(:transpiler) { described_class.new }

  describe "#transpile" do
    it "keeps valid ruby script" do
      expect(transpiler.transpile("p 1")).to eq("p 1")
    end

    it "raises error with invalid ruby script" do
      generation = nil
      allow(RubyModKit::Generation).to receive(:new).and_wrap_original do |m, *args, **kw|
        generation = m.call(*args, **kw)
        allow(generation).to receive(:warn)
        generation
      end
      expect { transpiler.transpile("@") }.to raise_error(RubyModKit::Error)
      expect(generation).to have_received(:warn)
    end

    describe "for instance variable parameter" do
      it "converts an instance variable parameter into an assignment" do
        expect(transpiler.transpile(<<~RBM)).to eq(<<~RB)
          def foo(@bar)
          end
        RBM
          def foo(bar)
            @bar = bar
          end
        RB
      end

      it "inserts an assignment at beggining of method" do
        expect(transpiler.transpile(<<~RBM)).to eq(<<~RB)
          def foo(@bar)
            buz
          end
        RBM
          def foo(bar)
            @bar = bar
            buz
          end
        RB
      end

      it "converts some instance variable parameters into assignments in the same order" do
        expect(transpiler.transpile(<<~RBM)).to eq(<<~RB)
          def foo(@bar, @buz)
          end
        RBM
          def foo(bar, buz)
            @bar = bar
            @buz = buz
          end
        RB
      end

      it "converts mixed instance variable parameters into assignments" do
        expect(transpiler.transpile(<<~RBM)).to eq(<<~RB)
          def foo(@bar, @buz = nil, @hoge:, @fuga: nil)
          end
        RBM
          def foo(bar, buz = nil, hoge:, fuga: nil)
            @bar = bar
            @buz = buz
            @hoge = hoge
            @fuga = fuga
          end
        RB
      end
    end

    describe "typed parameter" do
      it "converts typed parameter to rbs-inline annotation" do
        expect(transpiler.transpile(<<~RBM)).to eq(<<~RB)
          def foo(Bar => bar)
          end
        RBM
          # @rbs bar: Bar
          def foo(bar)
          end
        RB
      end

      it "treats same name method definitions as overloading" do
        expect(transpiler.transpile(<<~RBM)).to eq(<<~RB)
          def foo(Bar => bar)
            p :bar, bar
          end

          def foo(Buz => buz)
            p :buz, buz
          end
        RBM
          # @rbs (Bar) -> untyped
          #    | (Buz) -> untyped
          def foo(*args)
            case args
            in [Bar]
              foo__overload0(*args)
            in [Buz]
              foo__overload1(*args)
            end
          end

          # @rbs bar: Bar
          def foo__overload0(bar)
            p :bar, bar
          end

          # @rbs buz: Buz
          def foo__overload1(buz)
            p :buz, buz
          end
        RB
      end
    end
  end
end