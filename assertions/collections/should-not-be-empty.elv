use github.com/giancosta86/ethereal/v1/collection
use ../../assertion

fn should-not-be-empty {
  var collection = (one)

  if (collection:is-empty $collection) {
    assertion:fail (src)
  }
}