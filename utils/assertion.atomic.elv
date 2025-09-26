use ./assertion
use ./atomic

atomic:suite 'Atomic assertion' {
  assertion:assert $true

  try {
    assertion:assert $false
    fail 'The assertion must fail!'
  } catch e {
    var message = $e[reason][content]

    if (!=s $message 'Assertion failed!') {
      fail 'The expected failure did not occur!'
    }
  }
}