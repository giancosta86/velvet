use ./assertion
use ./command
use ./exception

echo ⚛ Command capturing

{
  echo ▶ Capturing stdout without exceptions

  command:capture {
    print Cip
  } |
    eq (all) [
      &output=Cip
      &status=$ok
    ] |
    assertion:assert (all)
}

{
  echo ▶ Capturing stderr without exceptions

  command:capture {
    print Ciop >&2
  } |
    eq (all) [
      &output=Ciop
      &status=$ok
    ] |
    assertion:assert (all)
}

{
  echo ▶ Capturing both stdout and stderr without exceptions

  command:capture {
    echo Cip
    echo Ciop >&2
  } |
    eq (all) [
      &output="Cip\nCiop\n"
      &status=$ok
    ] |
    assertion:assert (all)
}

{
  echo ▶ Capturing stdout with exception

  var result = (command:capture {
    print Cip
    fail DODO
  })

  eq $result[output] Cip |
    assertion:assert (all)

  exception:get-fail-message $result[status] |
    eq (all) DODO |
    assertion:assert (all)
}

{
  echo ▶ Capturing stderr with exception

  var result = (command:capture {
    print Ciop >&2
    fail DODO
  })

  eq $result[output] Ciop |
    assertion:assert (all)

  exception:get-fail-message $result[status] |
    eq (all) DODO |
    assertion:assert (all)
}

{
  echo ▶ Capturing both stdout and stderr with exception

  var result = (command:capture {
    echo Cip
    echo Ciop >&2
    fail DODO
  })

  eq $result[output] "Cip\nCiop\n" |
    assertion:assert (all)

  exception:get-fail-message $result[status] |
    eq (all) DODO |
    assertion:assert (all)
}

echo ⚛ ✅
echo