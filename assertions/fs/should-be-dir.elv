use os
use ../../assertion

fn should-be-dir {
  assertion:enforce-predicate (src) $os:is-dir~ 'Missing directories'
}
