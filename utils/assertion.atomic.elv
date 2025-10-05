use ./assertion

echo ⚛ Atomic assertion

{
  echo ▶ Asserting $true

  assertion:assert $true
}

{
  echo ▶ Asserting $false

  try {
    assertion:assert $false

    fail 'The assertion must fail!'
  } catch e {
    var message = $e[reason][content]

    if (not-eq $message 'ASSERTION FAILED!') {
      fail 'The expected failure did not occur!'
    }
  }
}

echo ⚛ ✅
echo