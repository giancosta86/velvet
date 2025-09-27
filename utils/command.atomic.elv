use str
use ./assertion
use ./command

echo ⚛ Command capturing

{
  echo ▶ Capturing stdout without exceptions

  var result = (command:capture {
    print Cip
  })

  assertion:assert (eq $result [
    &output=Cip
    &status=$ok
  ])
}

{
  echo ▶ Capturing stderr without exceptions

  var result = (command:capture {
    print Ciop >&2
  })

  assertion:assert (eq $result [
    &output=Ciop
    &status=$ok
  ])
}

{
  echo ▶ Capturing both stdout and stderr without exceptions

  var result = (command:capture {
    print Cip
    print Ciop >&2
  })

  assertion:assert (eq $result [
    &output=CipCiop
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

  assertion:assert (not-eq $result[status] $ok)

  assertion:assert (str:contains $result[status][reason][content] DODO)
}

{
  echo ▶ Capturing stderr with exception

  var result = (command:capture {
    print Ciop >&2
    fail DODO
  })

  assertion:assert (==s $result[output] Ciop)

  assertion:assert (not-eq $result[status] $ok)

  assertion:assert (str:contains $result[status][reason][content] DODO)
}

{
  echo ▶ Capturing both stdout and stderr with exception

  var result = (command:capture {
    print Cip
    print Ciop >&2
    fail DODO
  })

  assertion:assert (==s $result[output] CipCiop)

  assertion:assert (not-eq $result[status] $ok)

  assertion:assert (str:contains $result[status][reason][content] DODO)
}

echo ⚛ ✅
echo