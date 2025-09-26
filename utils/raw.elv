use os
use path
use ./atomic
use ./command

fn suite { |title suite-block|
  atomic:suite &emoji=🎭 $title { |atomic-test~|
    var raw-test = { |title test-block|
      atomic-test $title {
        var capture-result = (command:capture $test-block)

        if (not-eq $capture-result[status] $ok) {
          echo $capture-result[output]
          fail $capture-result[status]
        }
      }
    }

    $suite-block $raw-test
  }
}