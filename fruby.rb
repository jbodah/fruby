require 'ruby2ruby'
require 'ruby_parser'

module Fruby
  class Compiler
    # @returns [String] ruby code
    def self.compile(str)
      pipelines = str.split(/(?<!\|\>)\n+(?!\s*\|\>)/)
      pipelines.map { |p| compile_pipeline(p) }.join("\n")
    end

    def self.compile_pipeline(str)
      queue = str.split('|>')
      parser = RubyParser.new
      queue.map! { |i| parser.parse(i) }
      sexp = queue.shift
      if %i(lasgn iasgn cdecl).include?(sexp.first)
        inner = parse_pipe_queue(parser, queue, sexp.last)
        sexp = Sexp.from_array(sexp.first(2) << inner.to_a)
      else
        sexp = parse_pipe_queue(parser, queue, sexp)
      end
      Ruby2Ruby.new.process sexp
    end

    def self.parse_pipe_queue(parser, queue, sexp)
      queue.reduce(sexp) do |inner, outer|
        sexp_arr = outer.to_a.insert(3, inner.to_a)
        Sexp.from_array sexp_arr
      end
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
