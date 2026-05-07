use ./assertions/collections/should-be-empty
use ./assertions/collections/should-contain-all
use ./assertions/collections/should-contain-none
use ./assertions/collections/should-contain
use ./assertions/collections/should-not-be-empty
use ./assertions/collections/should-not-contain

use ./assertions/fs/should-be-dir
use ./assertions/fs/should-be-regular
use ./assertions/fs/should-exist
use ./assertions/fs/should-not-be-dir
use ./assertions/fs/should-not-be-regular
use ./assertions/fs/should-not-exist

use ./assertions/strings/should-contain-snippet
use ./assertions/strings/should-not-contain-snippet

use ./assertions/should-be
use ./assertions/should-emit
use ./assertions/should-not-be
use ./assertions/should-not-emit


var should-be-empty~ = $should-be-empty:should-be-empty~
var should-contain-all~ = $should-contain-all:should-contain-all~
var should-contain-none~ = $should-contain-none:should-contain-none~
var should-contain~ = $should-contain:should-contain~
var should-not-be-empty~ = $should-not-be-empty:should-not-be-empty~
var should-not-contain~ = $should-not-contain:should-not-contain~

var should-be-dir~ = $should-be-dir:should-be-dir~
var should-be-regular~ = $should-be-regular:should-be-regular~
var should-exist~ = $should-exist:should-exist~
var should-not-be-dir~ = $should-not-be-dir:should-not-be-dir~
var should-not-be-regular~ = $should-not-be-regular:should-not-be-regular~
var should-not-exist~ = $should-not-exist:should-not-exist~

var should-contain-snippet~ = $should-contain-snippet:should-contain-snippet~
var should-not-contain-snippet~ = $should-not-contain-snippet:should-not-contain-snippet~

var should-be~ = $should-be:should-be~
var should-emit~ = $should-emit:should-emit~
var should-not-be~ = $should-not-be:should-not-be~
var should-not-emit~ = $should-not-emit:should-not-emit~
