use str
use github.com/giancosta86/ethereal/v1/map
use ./ethereal

>> 'Test script' {
  >> 'Ethereal namespaces' {
    >> 'should work' {
      map:iterate $ethereal:namespaces { |namespace-name namespace|
        put $namespace-name |
          should-have-suffix ':'

        kind-of $namespace |
          should-be ns
      }
    }
  }
}