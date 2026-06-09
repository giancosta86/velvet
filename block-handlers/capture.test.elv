use str
use ./capture

var capture~ = $capture:capture~

>> 'Block handlers' {
  >> 'capture' {
    >> 'when expecting no exception' {
      >> 'when no exception is thrown' {
        >> 'when emitting bytes' {
          capture {
            echo Hello
            echo World
          } |
            should-be "Hello\nWorld"
        }

        >> 'when emitting values' {
          capture {
            put (num 90)
            put (num 92)
            put $true
          } |
            should-be "90\n92\n$true"
        }

        >> 'when enabling lines' {
          capture &lines {
            echo Hello
            put (num 90)
          } |
            should-emit &any-order [
              Hello
              90
            ]
        }
      }

      >> 'when an exception is thrown' {
        fails {
          capture {
            fail DODO
          }
        } |
          should-be DODO
      }

      >> 'when styled text is emitted' {
        var styling-block = {
          echo (styled Hello red bold)
          echo (styled World green italic)
        }

        >> 'by default' {
          capture $styling-block |
            should-be "Hello\nWorld"
        }

        >> 'when requiring the styled text' {
          capture &styled $styling-block |
            should-be (
              $styling-block |
                str:join "\n"
            )
        }
      }
    }

    >> 'when expecting an exception' {
      >> 'when no exception is thrown' {
        fails {
          capture &throws {
            echo Hello
          }
        } |
          should-be 'The given code block did not throw!'
      }

      >> 'when an exception is thrown' {
        >> 'when emitting bytes' {
          capture &throws {
            echo Hello
            echo World

            fail DODO
          } |
            should-be "Hello\nWorld"
        }

        >> 'when emitting values' {
          capture &throws {
            put (num 90)
            put (num 92)
            put $false

            fail DODO
          } |
            should-be "90\n92\n$false"
        }

        >> 'when enabling lines' {
          capture &throws &lines {
            echo Hello
            put (num 92)
            put $false

            fail DODO
          } |
            should-emit &any-order [
              Hello
              92
              '$false'
            ]
        }
      }
    }
  }
}