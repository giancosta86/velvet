use ./assertion

echo ⚛ 'Atomic assertion'

{
  echo ▶ 'Asserting a true value'

  assertion:assert $true
}

{
  echo ▶ 'Asserting a false value'

  try {
    assertion:assert $false
    fail 'The assertion must fail!'
  } catch e {
    var message = $e[reason][content]

    if (!=s $message 'ASSERTION FAILED!') {
      fail 'The expected failure did not occur!'
    }
  }
}

echo ⚛ ✅