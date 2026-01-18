use ./throws

var throws~ = $throws:throws~

>> 'Expecting an exception' {
  >> 'when no exception is thrown' {
    try {
      throws { }

      fail 'No exception was thrown by the expectation!'
    } catch e {
      exception:get-fail-content $e |
        should-be 'The given code block did not fail!'
    }
  }

  >> 'when there is an exception' {
    throws {
      fail DODO
    } |
      exception:get-fail-content |
      should-be DODO
  }

  >> 'in a pipeline, without arguments' {
    throws {
      fail CIOP
    } |
      exception:get-fail-content |
      should-be CIOP
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
          fail DODO
        } |
          should-emit [
            Hello
          ]
      }
    }

    >> 'when no exception occurs' {
      fails {
        throws &swallow {
          put 90
        }
      } |
        should-be 'The given code block did not fail!'
    }
  }
}