use github.com/giancosta86/ethereal/v1/set
use github.com/giancosta86/velvet/v1/main velvet

var all-tests = (
  put **.test.elv |
    set:of
)

var excluded-tests = (
  put tests/**.test.elv |
    set:of
)

var actual-tests = (
  set:difference $all-tests $excluded-tests |
  set:to-list
)

velvet:velvet &must-pass $@actual-tests
