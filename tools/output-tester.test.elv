use ./output-tester

>> 'Output tester' {
  var output-tester = (
    {
      put Alpha
      echo Beta
      put Gamma
      echo Delta
    } |
      output-tester:create
  )

  >> 'text' {
    >> 'should include "put" values' {
      put $output-tester[text] |
        should-contain Alpha

      put $output-tester[text] |
        should-contain Gamma
    }

    >> 'should include "echo" values' {
      put $output-tester[text] |
        should-contain Beta

      put $output-tester[text] |
        should-contain Delta
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
      fails {
        $output-tester[should-contain-all] [
          Alpha
          Beta
          INEXISTENT
        ]
      } |
        should-contain 'should-contain'
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
      fails {
        $output-tester[should-contain-none] [
          INEXISTENT
          Alpha
          MISSING
        ]
      } |
        should-contain 'should-not-contain'
    }

    >> 'when looking for a partial string' {
      fails {
        $output-tester[should-contain-none] [
          Al
          eta
          amm
        ]
      } |
        should-contain 'should-not-contain'
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
}