

https://ruby-doc.org/core-2.4.0/Array.html

iry

```ruby
# last → obj or nil click to toggle source
# last(n) → new_ary
# Returns the last element(s) of self. If the array is empty, the first form returns nil.
# See also #first for the opposite effect.
a = [ "w", "x", "y", "z" ]
a.last     #=> "z"
a.last(2)  #=> ["y", "z"]
```