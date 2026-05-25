use ./namespace

>> 'Test script' {
  >> 'namespace' {
    var test-namespace: = (
      namespace:create-for-script [
        &test-value=90
      ]
    )

    >> 'should contain the script builtins' {
      put $test-namespace:test-value |
        should-be 90
    }

    >> 'should contain Ethereal namespaces' {
      test-namespace:lang:ternary $true 90 7 |
        should-be 90
    }

    >> 'should contain assertions' {
      put 90 |
        test-namespace:should-be 90
    }

    >> 'should contain block handlers' {
      test-namespace:fails {
        fail Hello
      } |
        should-be Hello
    }

    >> 'should contain tools' {
      fails {
        test-namespace:fail-test
      } |
        should-be 'TEST SET TO FAIL'
    }
  }
}