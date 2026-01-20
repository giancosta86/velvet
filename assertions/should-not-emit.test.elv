use ./fails
use ./shared
use ./should-not-emit

var fails~ = $fails:fails~
var should-not-emit~ = $should-not-emit:should-not-emit~

var expect-failure~ = (shared:create-expect-failure $should-not-emit~ $should-not-emit:-error-message-base)

>> 'Assertions: should-not-emit' {
  >> 'when the argument is not a list' {
    fails {
      {
        put 90
      } |
        should-not-emit 90
    } |
      should-be 'The argument must be a list of values'
  }

  >> 'when not strict' {
    >> 'when none of the unexpected value is emitted' {
      {
        put Alpha
        put Beta
        put Gamma
      } |
        should-not-emit [
          90
          Dodo
          $true
        ]
    }

    >> 'when one of the unexpected values is emitted' {
      expect-failure {
        put Alpha
        put Beta
        put Dodo
        put Delta
      } [
        90
        Dodo
        $true
      ]
    }

    >> 'when multiple unexpected values are emitted' {
      throws &swallow {
        {
          put Alpha
          put Beta
          put Dodo
          put Delta
        } |
          should-not-emit [
            90
            Alpha
            Dodo
            $true
          ]
      } |
        should-emit [
          "\e[;1;31mUnexpected values found:\e[m"
          '['
          ' Alpha'
          ' Dodo'
          ']'
          "\e[;1;32mEmitted values:\e[m"
          '['
          ' Alpha'
          ' Beta'
          ' Dodo'
          ' Delta'
          ']'
        ]
    }

    >> 'with numbers and numeric strings' {
      expect-failure {
        put 90
        put 91
        put 92
      } [
        (num 91)
      ]
    }
  }

  >> 'when strict' {
    >> 'when none of the unexpected value is emitted' {
      {
        put Alpha
        put Beta
        put Gamma
      } |
        should-not-emit &strict [
          90
          Dodo
          $true
        ]
    }

    >> 'when one of the unexpected values is emitted' {
      expect-failure &strict {
        put Alpha
        put Beta
        put Dodo
        put Delta
      } [
        90
        Dodo
        $true
      ]
    }

    >> 'with numbers and numeric strings' {
      {
        put 90
        put 91
        put 92
      } |
        should-not-emit &strict [
          (num 91)
        ]
    }
  }

  >> 'when failing' {
    >> 'the output should describe the context' {
      var output-tester = (
        throws &swallow {
          {
            put Alpha
            put Beta
            put Gamma
          } |
            should-not-emit [
              Alpha
              Omega
              Beta
            ]
        } |
          create-output-tester &unstyled
      )

      $output-tester[should-contain-snippet] [
        'Unexpected values found:'
        '['
        ' Alpha'
        ' Beta'
        ']'
        'Emitted values:'
        '['
        ' Alpha'
        ' Beta'
        ' Gamma'
        ']'
      ]
    }
  }
}