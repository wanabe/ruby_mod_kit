# frozen_string_literal: true

require "ruby_mod_kit"

describe RubyModKit::Generation do
  describe ".resolve" do
    it "keeps valid ruby script" do
      expect(described_class.resolve("p 1").script).to eq("p 1")
    end

    it "raises error with invalid ruby script" do
      expect { described_class.resolve("@") }.to raise_error(RubyModKit::SyntaxError)
    end

    describe "for instance variable parameter" do
      it "converts an instance variable parameter into an assignment" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          def foo(@bar)
          end
        RBM
          def foo(bar)
            @bar = bar
          end
        RB
      end

      it "inserts an assignment at beggining of method" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
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
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
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
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
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
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          def foo(Bar => bar)
          end
        RBM
          # rbs_inline: enabled

          # @rbs bar: Bar
          def foo(bar)
          end
        RB
      end

      it "keeps existing magic comments" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          # frozen_string_literal: true

          # rbs_inline: enabled

          def foo(Bar => bar)
          end
        RBM
          # frozen_string_literal: true

          # rbs_inline: enabled

          # @rbs bar: Bar
          def foo(bar)
          end
        RB
      end

      it "allows constant joined with `::`" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          def foo(Bar::Buz => bar)
          end
        RBM
          # rbs_inline: enabled

          # @rbs bar: Bar::Buz
          def foo(bar)
          end
        RB
      end

      it "treats same name method definitions as overloading" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          def foo(Bar => bar): (Foo | Bar)
            p :bar, bar
          end

          def foo(Buz => buz): void
            p :buz, buz
          end
        RBM
          # rbs_inline: enabled

          # @rbs (Bar) -> (Foo | Bar)
          #    | (Buz) -> void
          def foo(*args)
            case args
            in [Bar]
              foo__overload0(*args)
            in [Buz]
              foo__overload1(*args)
            end
          end

          # @rbs bar: Bar
          # @rbs return: Foo | Bar
          def foo__overload0(bar)
            p :bar, bar
          end

          # @rbs buz: Buz
          # @rbs return: void
          def foo__overload1(buz)
            p :buz, buz
          end
        RB
      end

      it "receives rest parameter" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          def foo(*Bar::Buz => bar)
          end
        RBM
          # rbs_inline: enabled

          # @rbs *bar: Bar::Buz
          def foo(*bar)
          end
        RB
      end

      it "converts correctly with ivar and namespaced type" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          class Foo
            @bar: Bar

            def buz(Foo => foo): Buz
            end

            def buz(Foo::Bar => bar): Buz
            end
          end
        RBM
          # rbs_inline: enabled

          class Foo
            # @rbs @bar: Bar

            # @rbs (Foo) -> Buz
            #    | (Foo::Bar) -> Buz
            def buz(*args)
              case args
              in [Foo]
                buz__overload0(*args)
              in [Foo::Bar]
                buz__overload1(*args)
              end
            end

            # @rbs foo: Foo
            # @rbs return: Buz
            def buz__overload0(foo)
            end

            # @rbs bar: Foo::Bar
            # @rbs return: Buz
            def buz__overload1(bar)
            end
          end
        RB
      end

      it "can separate with modules" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          class Foo
            module Bar
              def buz: Buz
              end

              def buz(Integer => n): Buz
              end
            end

            module Buz
              def buz(String => s): Buz
              end
            end
          end
        RBM
          # rbs_inline: enabled

          class Foo
            module Bar
              # @rbs () -> Buz
              #    | (Integer) -> Buz
              def buz(*args)
                case args
                in []
                  buz__overload0(*args)
                in [Integer]
                  buz__overload1(*args)
                end
              end

              # @rbs return: Buz
              def buz__overload0
              end

              # @rbs n: Integer
              # @rbs return: Buz
              def buz__overload1(n)
              end
            end

            module Buz
              # @rbs s: String
              # @rbs return: Buz
              def buz(s)
              end
            end
          end
        RB
      end

      it "supports optional argument types" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          def foo(Integer => n = 1, String => s = "a")
          end
        RBM
          # rbs_inline: enabled

          # @rbs n: Integer
          # @rbs s: String
          def foo(n = 1, s = "a")
          end
        RB
      end
    end

    describe "typed return value" do
      it "converts typed return value to rbs-inline annotation" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          def foo: Bar
          end
        RBM
          # rbs_inline: enabled

          # @rbs return: Bar
          def foo
          end
        RB
      end

      it "insert return value annotation after parameter annotation" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          def foo(Bar => bar): Buz
          end
        RBM
          # rbs_inline: enabled

          # @rbs bar: Bar
          # @rbs return: Buz
          def foo(bar)
          end
        RB
      end
    end

    describe "for instance variable type" do
      it "converts instance variable type definition to rbs-inline annotation" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          class Foo
            @bar: Bar
          end
        RBM
          # rbs_inline: enabled

          class Foo
            # @rbs @bar: Bar
          end
        RB
      end

      it "adds attr type definition as rbs-inline annotation" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          class Foo
            @bar: Bar

            attr_reader :bar
          end
        RBM
          # rbs_inline: enabled

          class Foo
            # @rbs @bar: Bar

            attr_reader :bar #: Bar
          end
        RB
      end

      it "supports attribute pattern without class body" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          class Foo
            attr_reader @bar: Bar
            property @buz: Buz
            writer @hoge: Hoge
          end
        RBM
          # rbs_inline: enabled

          class Foo
            # @rbs @bar: Bar
            # @rbs @buz: Buz
            # @rbs @hoge: Hoge

            attr_reader :bar #: Bar
            attr_accessor :buz #: Buz
            attr_writer :hoge #: Hoge
          end
        RB
      end

      it "supports attribute pattern with class body" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          class Foo
            attr_reader @bar: Bar
            property @buz: Buz

            def foo
            end
          end
        RBM
          # rbs_inline: enabled

          class Foo
            # @rbs @bar: Bar
            # @rbs @buz: Buz

            attr_reader :bar #: Bar
            attr_accessor :buz #: Buz

            def foo
            end
          end
        RB
      end

      it "receive visibilities" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          class Foo
            public attr_reader @bar: Bar
            private property @buz: Buz
            protected writer @hoge: Hoge
          end
        RBM
          # rbs_inline: enabled

          class Foo
            # @rbs @bar: Bar
            # @rbs @buz: Buz
            # @rbs @hoge: Hoge

            public attr_reader :bar #: Bar
            private attr_accessor :buz #: Buz
            protected attr_writer :hoge #: Hoge
          end
        RB
      end

      it "completes ivar parameter type" do
        expect(described_class.resolve(<<~RBM).script).to eq(<<~RB)
          class Foo
            @bar: Bar

            def foo(@bar)
            end
          end
        RBM
          # rbs_inline: enabled

          class Foo
            # @rbs @bar: Bar

            # @rbs bar: Bar
            def foo(bar)
              @bar = bar
            end
          end
        RB
      end
    end

    context "with type/check/arguments feature" do
      let(:config) { RubyModKit::Config.new(features: %w[type type/check/arguments]) }

      it "generates pattern matching" do
        expect(described_class.resolve(<<~RBM, config: config).script).to eq(<<~RB)
          class Foo
            def foo(Bar => bar)
              p bar
            end
          end
        RBM
          class Foo
            def foo(bar)
              bar => Bar
              p bar
            end
          end
        RB
      end

      it "supports same line def ... end" do
        expect(described_class.resolve(<<~RBM, config: config).script).to eq(<<~RB)
          class Foo
            def foo(Bar => bar); end
            def bar(Buz => buz): void; end
          end
        RBM
          class Foo
            def foo(bar)
              bar => Bar
            end
            def bar(buz)
              buz => Buz
            end
          end
        RB
      end
    end
  end
end
