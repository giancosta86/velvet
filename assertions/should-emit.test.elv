use ./fails
use ./shared
use ./should-emit

var fails~ = $fails:fails~
var should-emit~ = $should-emit:should-emit~

var expect-failure~ = (shared:create-expect-failure $should-emit~ $should-emit:-error-message-base)

>> 'Assertions: should-emit' {
  >> 'when the argument is not a list' {
    fails {
      {
        put 90
      } |
        should-emit 90
    } |
      should-be 'The expected argument must be a list of values'
  }

  >> 'when emitting nothing' {
    { } |
      should-emit []
  }

  >> 'when emitting a string' {
    {
      put 'Hello, world!'
    } |
      should-emit [
        'Hello, world!'
      ]
  }

  >> 'when emitting a number' {
    >> 'when in string format' {
      {
        put 90
      } |
        should-emit [
          90
        ]
    }

    >> 'when in different formats' {
      {
        put 90
      } |
        should-emit [
          (num 90)
        ]
    }
  }

  >> 'when emitting both a string and a number' {
    {
      put Hello
      put 90
    } |
      should-emit [
        Hello
        90
      ]
  }

  >> 'when emitting via echo' {
    {
      echo Hello
      echo World
    } |
      should-emit [
        Hello
        World
      ]
  }

  >> 'when enabling strict equality' {
    >> 'when the data type is the same' {
      {
        put 90
      } |
        should-emit &strict [
          90
        ]
    }

    >> 'when the data type is different' {
      expect-failure &strict {
        put 90
      } [(num 90)]
    }
  }

  >> 'when the order is wrong' {
    expect-failure {
      put 95
      put 90
      put 98
      put 100
      put 92
    } [
      90
      92
      95
      98
      100
    ]
  }

  >> 'when ordering via a key' {
    {
      put 95
      put 90
      put 98
      put 100
      put 92
    } |
      should-emit &order-key=$num~ [
        90
        92
        95
        98
        100
      ]
  }
}