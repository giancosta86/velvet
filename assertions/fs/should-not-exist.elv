use os
use github.com/giancosta86/ethereal/v1/lang
use ../../assertion

fn should-not-exist {
  assertion:enforce-predicate (src) (lang:negate $os:exists~) 'Non-missing file system entries'
}
