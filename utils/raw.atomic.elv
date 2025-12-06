use str
use github.com/giancosta86/ethereal/v1/command
use github.com/giancosta86/ethereal/v1/exception
use ./assertion
use ./raw

echo ⚛ Raw testing

{
  echo ▶ Single test with no exceptions

  var command-result = (command:capture &type=bytes {
    raw:suite Description { |test~|
      test 'Test title' {
        print Never shown
        print Never shown >&2
        put 90
      }
    }
  })

  put [
    '🎭 '(styled Description bold | to-string (all))
    '▶ Test title'
    🎭✅
    ''
   ] |
    eq $command-result[data] (all) |
    assertion:assert (all)

  eq $command-result[exception] $nil |
    assertion:assert (all)
}

{
  echo ▶ Single test with exception

  var command-result = (command:capture &type=bytes {
    raw:suite Description { |test~|
      test 'Test title' {
        echo Cip
        echo Ciop >&2
        put 90

        fail 'DODO'
      }
    }
  })

  put [
    '🎭 '(styled Description bold | to-string (all))
    '▶ Test title'
    Cip
    Ciop
    ''
  ] |
    eq $command-result[data] (all) |
    assertion:assert (all)

  exception:get-fail-content $command-result[exception] |
    eq (all) DODO |
    assertion:assert (all)
}

{
  echo ▶ Multiple tests with no exceptions

  var command-result = (command:capture &type=bytes {
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

  put [
    '🎭 '(styled Description bold | to-string (all))
    '▶ Alpha title'
    '▶ Beta title'
    🎭✅
    ''
  ] |
    eq $command-result[data] (all) |
    assertion:assert (all)

  eq $command-result[exception] $nil |
    assertion:assert (all)
}

{
  echo ▶ Multiple tests with exception

  var command-result = (command:capture &type=bytes {
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

  put [
    '🎭 '(styled Description bold | to-string (all))
    '▶ Alpha title'
    '▶ Beta title'
    Yogi
    Bubu
    ''
   ] |
    eq $command-result[data] (all) |
    assertion:assert (all)

  exception:get-fail-content $command-result[exception] |
    eq (all) DODO |
    assertion:assert (all)
}

echo ⚛ ✅
echo