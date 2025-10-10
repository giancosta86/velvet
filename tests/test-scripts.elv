use path

var single-scripts = [
  single-scripts/empty.test.elv
  single-scripts/metainfo.test.elv
  single-scripts/mixed-outcomes.test.elv
  single-scripts/returning.test.elv
  single-scripts/root-it.test.elv
  single-scripts/single-failing.test.elv
  single-scripts/single-ok.test.elv
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

fn get-path { |subdirectory basename|
  var this-script-dir = (path:dir (src)[name])

  path:join $this-script-dir $subdirectory $basename'.test.elv'
}