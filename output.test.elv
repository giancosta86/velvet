use ./output

>> 'Utilities' {
  >> 'output' {
    >> 'highlighting a wrong value' {
      capture {
        output:display-wrong 'Test description' [90 92 95]
      } |
        should-contain-snippet [
          'Test description:'
          '['
          ' 90'
          ' 92'
          ' 95'
          ']'
        ]
    }

    >> 'contrasting values' {
      fn run-scenario { |&show-diff=$nil output-consumer|
        if (eq $show-diff $nil) {
          fail 'Missing &show-diff option'
        }

        var settings = [
          &red-description='MyRedDescription'
          &red=90
          &green-description='MyGreenDescription'
          &green=92
          &show-diff=$show-diff
        ]

        var output = (
          capture {
            put $settings |
              output:contrast
          }
        )

        >> 'should output the values' {
          put $output |
            should-contain-snippet [
              $settings[red-description]':'
              $settings[red]
              $settings[green-description]':'
              $settings[green]
            ]
        }

        $output-consumer $output
      }

      >> 'when not requesting the diff' {
        run-scenario &show-diff=$false { |output|
          >> 'should not show the diff' {
            put $output |
              should-contain-none [
                DIFF
                '@'
                '+'
                '-'
                '\'
              ]
          }
        }
      }

      >> 'when requesting the diff' {
        run-scenario &show-diff=$true { |output|
          >> 'should show the diff' {
            put $output |
              should-contain-all [
                DIFF
                '@'
                '+'
                '-'
                '\'
              ]
          }
        }
      }
    }
  }
}