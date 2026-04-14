use ../assertions/assertion-fails
use ./output-tester

var assertion-fails~ = $assertion-fails:assertion-fails~

>> 'Output tester' {
  var output-tester = (
    {
      echo Alpha
      echo Beta
      echo Gamma
      echo Delta
    } |
      output-tester:create
  )

  >> 'text' {
    >> 'should include "echo" values' {
      put $output-tester[text] |
        should-contain Beta

      put $output-tester[text] |
        should-contain Delta
    }

    >> 'should include "put" values' {
      var value-output-tester = (
        {
          put Ro
          put Sigma
        } |
          output-tester:create
      )

      put $value-output-tester[text] |
        should-contain Ro

      put $value-output-tester[text] |
        should-contain Sigma
    }
  }

  >> 'should-contain-all' {
    >> 'when all the strings are contained' {
      $output-tester[should-contain-all] [
        Alpha
        Beta
        Gamma
        Delta
      ]
    }

    >> 'when one of the strings is not contained' {
      assertion-fails should-contain {
        $output-tester[should-contain-all] [
          Alpha
          Beta
          INEXISTENT
        ]
      }
    }

    >> 'when looking for a partial string' {
      $output-tester[should-contain-all] [
        pha
        amm
        elt
      ]
    }

    >> 'when expecting a non-string value' {
      fails {
        $output-tester[should-contain-all] [
          [&b=90]
        ]
      } |
        should-be 'Each element in the list must be a string'
    }
  }

  >> 'should-contain-none' {
    >> 'when none of the strings is contained' {
      $output-tester[should-contain-none] [
        INEXISTENT
        MISSING
        'SOMETHING ELSE'
      ]
    }

    >> 'when one of the strings is contained' {
      assertion-fails should-not-contain {
        $output-tester[should-contain-none] [
          INEXISTENT
          Alpha
          MISSING
        ]
      }
    }

    >> 'when looking for a partial string' {
      assertion-fails should-not-contain {
        $output-tester[should-contain-none] [
          Al
          eta
          amm
        ]
      }
    }

    >> 'when not expecting a non-string value' {
      fails {
        $output-tester[should-contain-none] [
          [&b=90]
        ]
      } |
        should-be 'Each element in the list must be a string'
    }
  }

  >> 'should-contain-snippet' {
    >> 'when looking for an existing snippet' {
      $output-tester[should-contain-snippet] [
        Alpha
        Beta
      ]
    }

    >> 'when looking for a missing snippet' {
      assertion-fails should-contain {
        $output-tester[should-contain-snippet] [
          Cip
          Ciop
        ]
      }
    }

    >> 'when the output is styled' {
      var unstyling-tester = (
        {
          echo (styled Alpha red bold)
          echo (styled Beta green italic)
          echo (styled Gamma blue)
        } |
          output-tester:create
      )

      $unstyling-tester[should-contain-snippet] [
        Alpha
        Beta
        Gamma
      ]
    }
  }

  >> 'should-not-contain-snippet' {
    >> 'when not expecting an existing snippet' {
      assertion-fails should-not-contain {
        $output-tester[should-not-contain-snippet] [
          Alpha
          Beta
          Gamma
        ]
      }
    }

    >> 'when not expecting a missing snippet' {
      $output-tester[should-not-contain-snippet] [
        Ro
        Sigma
      ]
    }

    >> 'when the output is styled' {
      var preserving-tester = (
        {
          echo (styled Alpha red bold)
          echo (styled Beta green italic)
          echo (styled Gamma blue)
        } |
          output-tester:create &keep-styles
      )

      $preserving-tester[should-not-contain-snippet] [
        Alpha
        Beta
        Gamma
      ]
    }
  }
}