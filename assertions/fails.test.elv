use github.com/giancosta86/ethereal/v1/exception
use ./fails

var fails~ = $fails:fails~

>> 'Assertion: fails' {
  >> 'when the block does not throw' {
    throws {
      fails {
        echo Hello
      }
    } |
      exception:get-fail-content |
      should-be 'The given code block did not fail!'
  }

  >> 'when the block throws a fail' {
    fails {
      fail Dodo
    } |
      should-be Dodo
  }

  >> 'when the block throws a non-fail exception' {
    throws {
      fails {
        ASD
      }
    } |
      show (all) |
      slurp |
      should-contain 'executable file not found'
  }
}