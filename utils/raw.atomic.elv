use str
use ./assertion
use ./command
use ./exception
use ./raw

echo ⚛ Raw testing

{
  echo ▶ Single test with no exceptions

  var command-result = (command:capture {
    raw:suite Description { |test~|
      test 'Test title' {
        print Never shown
        print Never shown >&2
        put 90
      }
    }
  })

  all [
    '🎭 '(styled Description bold | to-string (all))
    '▶ Test title'
    🎭✅
    "\n"
   ] |
    str:join "\n" |
    eq $command-result[output] (all) |
    assertion:assert (all)

  eq $command-result[exception] $nil |
    assertion:assert (all)
}

{
  echo ▶ Single test with exception

  var command-result = (command:capture {
    raw:suite Description { |test~|
      test 'Test title' {
        echo Cip
        echo Ciop >&2
        put 90

        fail 'DODO'
      }
    }
  })

  all [
    '🎭 '(styled Description bold | to-string (all))
    '▶ Test title'
    Cip
    Ciop
    "\n"
  ] |
    str:join "\n" |
    eq $command-result[output] (all) |
    assertion:assert (all)

  exception:get-fail-content $command-result[exception] |
    eq (all) DODO |
    assertion:assert (all)
}

{
  echo ▶ Multiple tests with no exceptions

  var command-result = (command:capture {
    raw:suite Description { |test~|
      test 'Alpha title' {
        print Never shown
        print Never shown >&2
        put 90
      }

      test 'Beta title' {
        print Never shown again
        print Never shown again >&2
        put 95
      }
    }
  })

  all [
    '🎭 '(styled Description bold | to-string (all))
    '▶ Alpha title'
    '▶ Beta title'
    🎭✅
    "\n"
  ] |
    str:join "\n" |
    eq $command-result[output] (all) |
    assertion:assert (all)

  eq $command-result[exception] $nil |
    assertion:assert (all)
}

{
  echo ▶ Multiple tests with exception

  var command-result = (command:capture {
    raw:suite Description { |test~|
      test 'Alpha title' {
        print Never shown
        print Never shown >&2
        put 90
      }

      test 'Beta title' {
        echo Yogi
        echo Bubu >&2
        put 90

        fail DODO
      }

      test 'Gamma title' {
        print Never executed
        put 90

        fail 'NOT THROWN'
      }
    }
  })

  all [
    '🎭 '(styled Description bold | to-string (all))
    '▶ Alpha title'
    '▶ Beta title'
    Yogi
    Bubu
    "\n"
   ] |
    str:join "\n" |
    eq $command-result[output] (all) |
    assertion:assert (all)

  exception:get-fail-content $command-result[exception] |
    eq (all) DODO |
    assertion:assert (all)
}

echo ⚛ ✅
echo