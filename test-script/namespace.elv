use github.com/giancosta86/ethereal/v1/map
use ../assertions
use ../block-handlers
use ../ethereal
use ../tools

fn create-for-script { |script-builtins|
  all [
    $script-builtins
    $assertions:
    $block-handlers:
    $ethereal:namespaces
    $tools:
  ] |
    map:merge |
    ns (all)
}