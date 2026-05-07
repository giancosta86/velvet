use os
use ../../assertion

fn should-exist {
  assertion:enforce-predicate (src) $os:exists~ 'Missing file system entries'
}
