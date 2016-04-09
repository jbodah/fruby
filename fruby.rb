require 'ruby2ruby'
require 'ruby_parser'

module Fruby
  module Self
    def self.method_missing(sym, actual_receiver, *args, &block)
      actual_receiver.public_send(sym, *args, &block)
    end
  end

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
      sexp = if %i(lasgn iasgn cdecl).include?(sexp.first)
               inner = parse_pipe_queue(queue, sexp.last)
               Sexp.from_array(sexp.first(2) << inner.to_a)
             else
               parse_pipe_queue(queue, sexp)
             end
      Ruby2Ruby.new.process sexp
    end

    def self.parse_pipe_queue(queue, sexp)
      queue.reduce(sexp) do |inner, outer|
        # find index of first call and insert inner as first variable to call
        if outer.first == :iter
          sexp_arr = outer.to_a
          sexp_arr[1].insert(3, inner.to_a)
        else
          sexp_arr = outer.to_a.insert(3, inner.to_a)
        end
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
