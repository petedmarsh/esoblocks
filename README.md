# Esoblocks

[![Build Status](https://travis-ci.org/petedmarsh/esoblocks.png)](https://travis-ci.org/petedmarsh/esoblocks)

Annoy your co-workers! Impress your friends!

Esoblocks lets you embed programs written in Beatnik in regular Ruby code.

Why do this:

```ruby
puts 'd'
```

when you can do this*:

```ruby
require 'esoblocks'

esoblock do
  gone away gone quickly gone quickly gone quickly gone quickly returns returns returns address address
end
```

_*Never actually do this_
