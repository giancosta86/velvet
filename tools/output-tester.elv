use str
use github.com/giancosta86/ethereal/v1/string
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

fn create { |&unstyled=$false|
  var text = (
    var original-text = (
      all |
        to-lines |
        slurp
    )

    if $unstyled {
      string:unstyled $original-text
    } else {
      put $original-text
    }
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

    &should-contain-snippet={ |lines|
      var snippet = (str:join "\n" $lines)

      put $text |
        assertions:should-contain $snippet
    }

    &should-not-contain-snippet={ |lines|
      var snippet = (str:join "\n" $lines)

      put $text |
        assertions:should-not-contain $snippet
    }
  ]
}