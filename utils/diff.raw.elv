use str
use ./assertion
use ./command
use ./diff
use ./raw

raw:suite 'Diff' { |test~|
  test 'When the strings are equal' {
    command:capture {
      diff:diff Alpha Alpha
    } |
      eq (all) [
        &output=''
        &status=$ok
      ] |
      assertion:assert (all)
  }

  test 'When the strings are different' {
    var command-result = (
      command:capture {
        diff:diff Alpha Beta
      }
    )

    str:contains $command-result[output] '@@ -1 +1 @@' |
      assertion:assert (all)

    str:contains $command-result[output] -Alpha |
      assertion:assert (all)

    str:contains $command-result[output] +Beta |
      assertion:assert (all)

    eq $command-result[status] $ok |
      assertion:assert (all)
  }
}