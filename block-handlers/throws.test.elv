use ./throws

var throws~ = $throws:throws~

>> 'Block handlers' {
  >> 'throws' {
    >> 'when no exception is thrown' {
      try {
        throws { }

        fail 'THE CODE SHOULD NOT REACH THIS POINT!'
      } catch e {
        exception:get-fail-content $e |
          should-be 'The given code block did not throw!'
      }
    }

    >> 'when there is a failure' {
      throws {
        fail DODO
      } |
        exception:get-fail-content |
        should-be DODO
    }

    >> 'when there is another exception' {
      throws {
        / 9 0
      } |
        exception:get-reason |
        to-string (all) |
        should-contain divisor
    }

    >> 'when emitting bytes' {
      throws {
        echo Hello
        fail DODO
      } |
        kind-of (all) |
        should-be exception
    }

    >> 'when emitting values' {
      throws {
        put 90
        fail DODO
      } |
        kind-of (all) |
        should-be exception
    }

    >> 'when swallowing the exception' {
      >> 'when an exception actually occurs' {
        >> 'when emitting values' {
          throws &swallow {
            put 90
            put (num 92)
            fail DODO
          } |
            should-emit &strict [
              90
              (num 92)
            ]
        }

        >> 'when emitting bytes' {
          throws &swallow {
            echo Hello
            echo World
            fail DODO
          } |
            should-emit [
              Hello
              World
            ]
        }
      }

      >> 'when no exception occurs' {
        fails {
          throws &swallow {
            put 90
          }
        } |
          should-be 'The given code block did not throw!'
      }
    }
  }
}
