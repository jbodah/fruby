require 'ruby2ruby'
require 'ruby_parser'

module Fruby
  class Compiler
    # @returns [String] ruby code
    def self.compile(str)
      queue = str.split('|>')
      parser = RubyParser.new
      sexp = parser.parse(queue.shift)
      sexp = queue.reduce(sexp) do |inner, code|
        outer = parser.parse(code)
        sexp_arr = outer.to_a.insert(3, inner.to_a)
        Sexp.from_array sexp_arr
      end
      Ruby2Ruby.new.process sexp
    end
  end

  def self.compile(str)
    Compiler.compile(str)
  end

  # @param [Binding]
  # @param [String]
  #
  # If binding_of_caller exists then you don't need to pass a binding
  def self.eval(*args)
    str = args.pop
    _binding = args.pop
    if binding.respond_to?(:of_caller)
      _binding ||= binding.of_caller(1)
    end
    _binding.eval compile(str)
  end
end
