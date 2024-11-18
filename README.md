# RubyModKit

RubyModKit is a transpiler tool from Ruby-like syntax script to Ruby script.
The name is shorthand for ruby-modify-kit.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add ruby_mod_kit

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install ruby_mod_kit

## Usage

### as command line tool

#### `transpile`

You can get transpiled ruby script from .rbm file by `ruby_mod_kit transpile` command.

    $ ruby_mod_kit transpile path/to/script.rbm

#### `exec`

You can run transpiled ruby script by `ruby_mod_kit exec` command.

    $ ruby_mod_kit exec path/to/script.rbm

The command also creates/updates ruby script before running.

## Feature

1. Type definition
    - The deifinitions will be changed to RBS-inline annotation comments.
    - Instance variables
        - `@foo: Foo` -> `# @rbs @foo: Foo`
    - Attributes (`attr_reader`, `attr_writer`, `attr_accessor`)
        - `attr_reader @foo: Foo` -> `# @rbs @foo: Foo` and `attr_reader :foo #: Foo`
        - `getter`, `setter`, `property` are also available
    - Method parameters
        - `def foo(Bar => bar) ... end` -> `# @rbs foo: Foo` and `def foo(bar) ... end`
    - Method return values
        - `def foo(bar): Foo ... end` -> `# @rbs return: Foo` and `def foo(bar) ... end`
2. Instance variable parameter
    - `def foo(@bar) ... end` -> `def foo(bar) @bar = bar ... end`
3. Overloading
    - ```
      def foo(Bar => arg): void
        ...
      end

      def foo(Buz => arg): Buz
        ...
      end
      ```
      ->
      ```
      # @rbs (Bar) -> void
      #    | (Buz) -> Buz
      def foo(*args)
        case args
        in [Bar]
          foo__overload0(*args)
        in [Buz]
          foo__overload1(*args)
        end
      end

      # @rbs arg: Bar
      # @rbs return: void
      def foo__overload0(Bar => arg)
        ...
      end

      # @rbs arg: Buz
      # @rbs return: Buz
      def foo__overload1(Buz => arg)
        ...
      end
      ```

## Development

TODO

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wanabe/ruby_mod_kit.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
