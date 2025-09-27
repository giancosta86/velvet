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
      }
    }
  })

  assertion:assert (==s $command-result[output] '🎭 '(styled Description bold | to-string (all))"\n▶ Test title\n🎭✅\n\n")

  assertion:assert (eq $command-result[status] $ok)
}

{
  echo ▶ Single test with exception

  var command-result = (command:capture {
    raw:suite Description { |test~|
      test 'Test title' {
        echo Cip
        echo Ciop >&2
        fail 'DODO'
      }
    }
  })

  assertion:assert (==s $command-result[output] '🎭 '(styled Description bold | to-string (all))"\n▶ Test title\nCip\nCiop\n\n")

  exception:get-fail-message $command-result[status] |
    str:contains (all) DODO |
    assertion:assert (all)
}

{
  echo ▶ Multiple tests with no exceptions

  var command-result = (command:capture {
    raw:suite Description { |test~|
      test 'Alpha title' {
        print Never shown
        print Never shown >&2
      }

      test 'Beta title' {
        print Never shown
        print Never shown >&2
      }
    }
  })

  assertion:assert (==s $command-result[output] '🎭 '(styled Description bold | to-string (all))"\n▶ Alpha title\n▶ Beta title\n🎭✅\n\n")

  assertion:assert (eq $command-result[status] $ok)
}

{
  echo ▶ Multiple tests with exception

  var command-result = (command:capture {
    raw:suite Description { |test~|
      test 'Alpha title' {
        print Never shown
        print Never shown >&2
      }

      test 'Beta title' {
        echo Yogi
        echo Bubu >&2

        fail DODO
      }

      test 'Gamma title' {
        print Never executed

        fail 'NOT THROWN'
      }
    }
  })

  assertion:assert (==s $command-result[output] '🎭 '(styled Description bold | to-string (all))"\n▶ Alpha title\n▶ Beta title\nYogi\nBubu\n\n")

  exception:get-fail-message $command-result[status] |
    str:contains (all) DODO |
    assertion:assert (all)
}

echo ⚛ ✅
echo