use github.com/giancosta86/ethereal/v1/set
use ./containers
use ./fails

var fails~ = $fails:fails~

>> 'Containers' {
  >> 'detecting kind' {
    >> 'when passing a string' {
      containers:detect-kind Dodo |
        should-be string
    }

    >> 'when passing a list' {
      containers:detect-kind [90 92] |
        should-be list
    }

    >> 'when passing a map' {
      containers:detect-kind [&a=90] |
        should-be map
    }

    >> 'when passing an Ethereal set' {
      set:of 90 92 95 98 |
        containers:detect-kind |
        should-be ethereal-set
    }

    >> 'when passing just a boolean' {
      containers:detect-kind $true |
        should-be bool
    }
  }

  >> 'container test' {
    >> 'when the container is a string' {
      >> 'when the substring is contained' {
        containers:contains Dodo od |
          should-be $true
      }

      >> 'when the substring is not contained' {
        containers:contains Yogi Bubu |
          should-be $false
      }
    }

    >> 'when the container is a list' {
      >> 'when the item is contained' {
        containers:contains [90 92 95 98] 95 |
          should-be $true
      }

      >> 'when the item is not contained' {
        containers:contains [90 92 95 98] 7 |
          should-be $false
      }
    }

    >> 'when the container is a map' {
      >> 'when the key is contained' {
        containers:contains [&a=90 &b=92 &c=95] b |
          should-be $true
      }

      >> 'when the key is not contained' {
        containers:contains [&a=90 &b=92 &c=95] zod |
          should-be $false
      }
    }

    >> 'when the container is an Ethereal set' {
      >> 'when the item is contained' {
        set:of 90 92 95 98 |
          containers:contains (all) 92 |
          should-be $true
      }

      >> 'when the item is not contained' {
        set:of 90 92 95 98 |
          containers:contains (all) 7 |
          should-be $false
      }
    }

    >> 'when trying to pass a number as a container' {
      fails {
        containers:contains (num 90) 90
      } |
        should-be 'Unsupported container kind: number'
    }
  }

  >> 'getting the value description' {
    >> 'for string' {
      containers:get-value-description Dodo |
        should-be substring
    }

    >> 'for list' {
      containers:get-value-description [] |
        should-be item
    }

    >> 'for map' {
      containers:get-value-description [&] |
        should-be key
    }

    >> 'for Ethereal set' {
      containers:get-value-description $set:empty |
        should-be item
    }

    >> 'for mere number' {
      fails {
        containers:get-value-description (num 90)
      } |
        should-be 'Unsupported container kind: number'
    }
  }
}