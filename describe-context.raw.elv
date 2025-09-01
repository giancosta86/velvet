use ./raw
use ./describe-context

raw:suite 'Testing a describe context' { |test~ assert~|
  test 'Empty root' {
    var root-context = (describe-context:create-root 'Alpha')

    var outcome-context = ($root-context[to-outcome-context])

    assert (eq $outcome-context[outcomes] [&]) 'The initial outcome context must have no outcomes!'
    assert (eq $outcome-context[sub-contexts] [&]) 'The initial outcome context must have no subcontexts!'
  }
}