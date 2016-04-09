require 'fruby'
require 'colorize'

def print_success(name)
  puts "Success: #{name}".green
end

def print_failure(name)
  puts "Failed: #{name}".red
end

def test(name, &block)
  if block.call
    print_success name
  else
    print_failure name
  end
rescue => e
  print_failure name
  puts e.to_s.red
  puts e.backtrace.map(&:red)
end

puts "Testing..."

###

module Helper
  def self.count_chars(str)
    str.each_char.size
  end

  def self.count_chars_and_add(str, n)
    count_chars(str) + n
  end
end

def reverse(str)
  str.reverse
end

test 'it evaluates basic expressions' do
  res = Fruby.eval binding, '"hello" |> Helper.count_chars'
  res == 5
end

test 'it evaluates over new lines' do
  res = Fruby.eval binding, <<-EOF
    "hello"
    |> Helper.count_chars
  EOF
  res == 5
end

test 'it evaluates correctly with extra args' do
  res = Fruby.eval binding, <<-EOF
    "hello"
    |> Helper.count_chars_and_add(3)
  EOF
  res == 8
end

test 'it evaluates correctly with root level methods' do
  res = Fruby.eval binding, <<-EOF
    "hello" |> reverse
  EOF
  res == "olleh"
end

test 'it evaluates correctly with multiple chains' do
  res = Fruby.eval binding, <<-EOF
    "hello" |> reverse |> reverse
  EOF
  res == "hello"
end

# NOTE: @jbodah 2016-04-08: local vars won't work as this is forbidden in Ruby
test 'you can save itermediary results to instance variables' do
  Fruby.eval binding, <<-EOF
    @word = "hello" |> reverse |> reverse
  EOF
  @word == "hello"
end

test 'you can define multiple pipelines' do
  res = Fruby.eval binding, <<-EOF
    "hello" |> reverse |> reverse

    "hello" |> Helper.count_chars
  EOF
  res == 5
end

test 'you can share itermediary results between pipelines' do
  res = Fruby.eval binding, <<-EOF
    word = "hello" |> reverse |> reverse
    word |> Helper.count_chars_and_add(3)
  EOF
  res == 8
end

test 'it can be used with enumerable methods' do
  res = Fruby.eval binding, <<-EOF
    [1, 2, 3]
    |> Fruby::Self.map { |n| n + 1 }
    |> Fruby::Self.select { |n| n >= 3 }
  EOF
  res == [3, 4]
end

test 'it supports pattern matching' do
  Fruby.eval binding, <<-EOF
    def say("hello")
      "hi there"
    end

    def say(Integer => n)
      "the number \#{n}"
    end

    def say(Array => n)
      "an array of size \#{n.size}"
    end
  EOF

  say "hello" == "hi there"
  say 6 == "the number 6"
  say 4 == "the number 4"
  say [1, 2, 4] == "an array of size 3"
end

at_exit {
  test 'it uses binding_of_caller if it exists' do
    require 'binding_of_caller'
    n = 3
    res = Fruby.eval <<-EOF
      "hello"
      |> Helper.count_chars_and_add(n)
    EOF
    res == 8
  end
}
