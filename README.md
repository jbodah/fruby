# fruby

proof of concept Elixir-style pipes for Ruby

## Usage

```rb
require 'fruby'

n = 3
Fruby.eval binding, <<-EOF
  "hello"
  |> Helper.count_chars_and_add(n)
EOF
#=> 8

# or if binding_of_caller is already loaded

n = 3
Fruby.eval <<-EOF
  "hello"
  |> Helper.count_chars_and_add(n)
EOF
#=> 8
```

## Testing

```
ruby -I. test.rb
```
