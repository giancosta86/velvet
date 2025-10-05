use ./assertion
use ./command
use ./exception

echo ⚛ Command capturing

{
  echo ▶ Capturing stdout without exceptions

  command:capture {
    print Cip
  } |
    assertion:assert (eq (all) [
      &output=Cip
      &status=$ok
    ])
}

{
  echo ▶ Capturing stderr without exceptions

  command:capture {
    print Ciop >&2
  } |
    assertion:assert (eq (all) [
      &output=Ciop
      &status=$ok
    ])
}

{
  echo ▶ Capturing both stdout and stderr without exceptions

  command:capture {
    echo Cip
    echo Ciop >&2
  } |
    assertion:assert (eq (all) [
      &output="Cip\nCiop\n"
      &status=$ok
    ])
}

{
  echo ▶ Capturing stdout with exception

  var result = (command:capture {
    print Cip
    fail DODO
  })

  assertion:assert (==s $result[output] Cip)

  exception:get-fail-message $result[status] |
    ==s (all) DODO |
    assertion:assert (all)
}

{
  echo ▶ Capturing stderr with exception

  var result = (command:capture {
    print Ciop >&2
    fail DODO
  })

  assertion:assert (==s $result[output] Ciop)

  exception:get-fail-message $result[status] |
    ==s (all) DODO |
    assertion:assert (all)
}

{
  echo ▶ Capturing both stdout and stderr with exception

  var result = (command:capture {
    echo Cip
    echo Ciop >&2
    fail DODO
  })

  assertion:assert (==s $result[output] "Cip\nCiop\n")

  exception:get-fail-message $result[status] |
    ==s (all) DODO |
    assertion:assert (all)
}

echo ⚛ ✅
echo