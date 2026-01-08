use ./shared

>> 'Shared assertion utilities' {
  >> 'with-strict-prefix' {
    >> 'with strict disabled' {
      shared:with-strict-prefix &strict=$false Yogi |
        should-be Yogi
    }

    >> 'with strict enabled' {
      put Bubu |
        shared:with-strict-prefix &strict |
        should-be 'strict Bubu'
    }
  }

  >> 'getting a minimal value' {
    >> 'with strict disabled' {
      shared:get-minimal &strict=$false (num 90) |
        should-be &strict 90
    }

    >> 'with strict enabled' {
      put (num 92) |
        shared:get-minimal &strict |
        should-be &strict (num 92)
    }
  }

  >> 'fail-with-strict-prefix' {
    >> 'with strict disabled' {
      throws {
        shared:fail-with-strict-prefix &strict=$false Yogi
      } |
        get-fail-content |
        should-be Yogi
    }

    >> 'with strict enabled' {
      throws {
        put Bubu |
          shared:fail-with-strict-prefix &strict
      } |
        get-fail-content |
        should-be 'strict Bubu'
    }
  }

  >> 'getting the minimal actual and expected value' {
    >> 'when strict is disabled' {
      put (num 90) |
        shared:get-minimals (num 92) |
        should-emit [
          90
          92
        ]
    }

    >> 'when strict is enabled' {
      put (num 90) |
        shared:get-minimals &strict (num 92) |
        should-emit &strict [
          (num 90)
          (num 92)
        ]
    }
  }
}