use github.com/giancosta86/aurora-elvish/console
use ./file-runner

fn assert-eq  { |left-value right-value failure-message|
  if (not-eq $left-value $right-value) {
    fail $failure-message
  }
}

fn assert { |predicate failure-message|
  assert-eq $predicate $true $failure-message
}

fn test-block { |title block|
  console:section &emoji=🎭 $title {
    $block

    echo ✅All the tests for this section are OK!
  }
}

test-block 'Testing a describe context' {

}

test-block 'Testing a single file runner' {
  var result = (file-runner:run ./tests/basic.elv)

  pprint $result

  var stats = $result[stats]
  assert $stats[is-ok] 'is-ok should be true!'
  assert-eq $stats[total-failed] (num 0) 'total-failed should be 0!'
  assert-eq $stats[total-passed] (num 3) 'total-passed should be 3!'
  assert-eq $stats[total-tests] (num 3) 'total-tests should be 3!'

  var outcome-context = $result[outcome-context]


}
