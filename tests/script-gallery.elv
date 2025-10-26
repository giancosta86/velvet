use path

var -this-script-dir = (path:dir (src)[name])

var single-scripts = [
  single-scripts/empty.test.elv
  single-scripts/exceptions.test.elv
  single-scripts/in-section-failing.test.elv
  single-scripts/in-section-mixed.test.elv
  single-scripts/in-section-ok.test.elv
  single-scripts/metainfo.test.elv
  single-scripts/returning.test.elv
  single-scripts/root-failing.test.elv
  single-scripts/root-mixed.test.elv
  single-scripts/root-ok.test.elv
  single-scripts/root-test-without-title.test.elv
  single-scripts/sub-section-without-title.test.elv
]

var aggregator = [
  aggregator/alpha.test.elv
  aggregator/beta.test.elv
  aggregator/gamma.test.elv
]

var readme = [
  readme/maths.test.elv
]

var all = [(
  all [
    $@single-scripts
    $@aggregator
    $@readme
  ] |
    order
)]

fn get-script-path { |subdirectory basename|
  path:join $-this-script-dir $subdirectory $basename'.test.elv'
}