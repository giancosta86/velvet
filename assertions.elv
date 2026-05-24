use ./assertions/collections/should-be-empty
use ./assertions/collections/should-contain-all
use ./assertions/collections/should-contain-none
use ./assertions/collections/should-contain
use ./assertions/collections/should-not-be-empty
use ./assertions/collections/should-not-contain

use ./assertions/core/should-be
use ./assertions/core/should-emit
use ./assertions/core/should-not-be
use ./assertions/core/should-not-emit

use ./assertions/fs/should-be-dir
use ./assertions/fs/should-be-regular
use ./assertions/fs/should-exist
use ./assertions/fs/should-not-be-dir
use ./assertions/fs/should-not-be-regular
use ./assertions/fs/should-not-exist

use ./assertions/strings/should-contain-snippet
use ./assertions/strings/should-have-prefix
use ./assertions/strings/should-have-suffix
use ./assertions/strings/should-match-regex
use ./assertions/strings/should-not-contain-snippet
use ./assertions/strings/should-not-have-prefix
use ./assertions/strings/should-not-have-suffix
use ./assertions/strings/should-not-match-regex

var should-be-empty~ = $should-be-empty:should-be-empty~
var should-contain-all~ = $should-contain-all:should-contain-all~
var should-contain-none~ = $should-contain-none:should-contain-none~
var should-contain~ = $should-contain:should-contain~
var should-not-be-empty~ = $should-not-be-empty:should-not-be-empty~
var should-not-contain~ = $should-not-contain:should-not-contain~

var should-be~ = $should-be:should-be~
var should-emit~ = $should-emit:should-emit~
var should-not-be~ = $should-not-be:should-not-be~
var should-not-emit~ = $should-not-emit:should-not-emit~

var should-be-dir~ = $should-be-dir:should-be-dir~
var should-be-regular~ = $should-be-regular:should-be-regular~
var should-exist~ = $should-exist:should-exist~
var should-not-be-dir~ = $should-not-be-dir:should-not-be-dir~
var should-not-be-regular~ = $should-not-be-regular:should-not-be-regular~
var should-not-exist~ = $should-not-exist:should-not-exist~

var should-contain-snippet~ = $should-contain-snippet:should-contain-snippet~
var should-have-prefix~ = $should-have-prefix:should-have-prefix~
var should-have-suffix~ = $should-have-suffix:should-have-suffix~
var should-match-regex~ = $should-match-regex:should-match-regex~
var should-not-contain-snippet~ = $should-not-contain-snippet:should-not-contain-snippet~
var should-not-have-prefix~ = $should-not-have-prefix:should-not-have-prefix~
var should-not-have-suffix~ = $should-not-have-suffix:should-not-have-suffix~
var should-not-match-regex~ = $should-not-match-regex:should-not-match-regex~
