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

test 'it uses binding_of_caller if it exists' do
  require 'binding_of_caller'
  n = 3
  res = Fruby.eval <<-EOF
    "hello"
    |> Helper.count_chars_and_add(n)
  EOF
  res == 8
end
