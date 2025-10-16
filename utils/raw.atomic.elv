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

  put '🎭 '(styled Description bold | to-string (all))"\n▶ Test title\n🎭✅\n\n" |
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

  put '🎭 '(styled Description bold | to-string (all))"\n▶ Test title\nCip\nCiop\n\n" |
    eq $command-result[output] (all) |
    assertion:assert (all)

  exception:get-fail-message $command-result[exception] |
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

  put '🎭 '(styled Description bold | to-string (all))"\n▶ Alpha title\n▶ Beta title\n🎭✅\n\n"|
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

  put '🎭 '(styled Description bold | to-string (all))"\n▶ Alpha title\n▶ Beta title\nYogi\nBubu\n\n" |
    eq $command-result[output] (all) |
    assertion:assert (all)

  exception:get-fail-message $command-result[exception] |
    eq (all) DODO |
    assertion:assert (all)
}

echo ⚛ ✅
echo