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
        exception:get-fail-content |
        should-be Yogi
    }

    >> 'with strict enabled' {
      throws {
        put Bubu |
          shared:fail-with-strict-prefix &strict
      } |
        exception:get-fail-content |
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

  >> 'getting an equalized list' {
    var source = [
      (num 95)
      90
      98
      (num 92)
    ]

    >> 'when the strict flag is disabled' {
      >> 'when the order key is missing' {
        all $source |
          shared:equalize |
          should-emit &strict [
            95
            90
            98
            92
          ]
      }

      >> 'when the order key is passed' {
        all $source |
          shared:equalize &order-key=$to-string~ |
          should-emit &strict [
            90
            92
            95
            98
          ]
      }
    }

    >> 'when the strict flag is enabled' {
      >> 'when the order key is missing' {
        all $source |
          shared:equalize &strict |
          should-emit &strict [
            (num 95)
            90
            98
            (num 92)
          ]
      }

      >> 'when the order key is passed' {
        all $source |
          shared:equalize &strict &order-key=$to-string~ |
          should-emit &strict [
            90
            (num 92)
            (num 95)
            98
          ]
      }
    }
  }
}