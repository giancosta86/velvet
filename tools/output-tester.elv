use str
use github.com/giancosta86/ethereal/v1/string
use ../assertions

var create~ = (
  fn assert-string { |value|
    if (
      kind-of $value |
        eq (all) string |
        not (all)
    ) {
      fail 'Each element in the list must be a string'
    }
  }

  put { |&keep-styles=$false|
    var text = (
      var original-text = (
        all |
          str:join "\n"
      )

      if $keep-styles {
        put $original-text
      } else {
        string:unstyled $original-text
      }
    )

    put [
      &text=$text

      &should-contain-all={ |expected-strings|
        all $expected-strings | each { |expected-string|
          assert-string $expected-string

          put $text |
            assertions:should-contain $expected-string
        }
      }

      &should-contain-none={ |unexpected-strings|
        all $unexpected-strings | each { |unexpected-string|
          assert-string $unexpected-string

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
)