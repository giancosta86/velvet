use github.com/giancosta86/ethereal/v1/collection
use ../../assertion
use ../../utils/output

fn should-be-empty {
  var collection = (one)

  if (not (collection:is-empty $collection)) {
    var collection-kind = (collection:detect-kind $collection)

    output:highlight-wrong 'Unexpected non-empty '$collection-kind $collection

    assertion:fail (src)
  }
}