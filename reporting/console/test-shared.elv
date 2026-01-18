use ../../summary
use ../../tools/output-tester

fn create-console-tester-constructor { |console-reporter|
  put { |sandbox-result|
    summary:from-sandbox-result $sandbox-result |
      $console-reporter (all) |
      output-tester:create
  }
}