use ../assertions

fn -assert-string { |value|
  if (
    kind-of $value |
      eq (all) string |
      not (all)
  ) {
    fail 'Each element in the list must be a string'
  }
}

fn create {
  var text = (
    all |
      to-lines |
      slurp
  )

  put [
    &text=$text

    &should-contain-all={ |expected-strings|
      all $expected-strings | each { |expected-string|
        -assert-string $expected-string

        put $text |
          assertions:should-contain $expected-string
      }
    }

    &should-contain-none={ |unexpected-strings|
      all $unexpected-strings | each { |unexpected-string|
        -assert-string $unexpected-string

        put $text |
          assertions:should-not-contain $unexpected-string
      }
    }
  ]
}