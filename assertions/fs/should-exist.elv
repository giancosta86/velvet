use os
use ../shared

var -error-message = 'should-exist assertion failed'

var should-exist~ = (
  shared:create-assertion-on-tested-entries $os:exists~ 'Missing file system entries' $-error-message
)
