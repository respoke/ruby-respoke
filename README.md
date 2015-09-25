[![Gem Version](https://badge.fury.io/rb/respoke.svg)](http://badge.fury.io/rb/respoke)
[![Build Status](https://travis-ci.org/pho3nixf1re/ruby-respoke.svg?branch=master)](https://travis-ci.org/pho3nixf1re/ruby-respoke)
[![Dependency Status](https://gemnasium.com/pho3nixf1re/ruby-respoke.svg)](https://gemnasium.com/pho3nixf1re/ruby-respoke)

# Respoke

ruby-respoke is a wrapper for the Respoke API. For more information on the
Respoke service and API see [docs.respoke.io](http://docs.respoke.io).

## Installation

Using bundler, add this line to your application's Gemfile:

```ruby
gem 'respoke'
```

And then execute:

    $ bundle

For details on the ruby-respoke API please refer to the [full documentation].

[full documentation]: http://www.rubydoc.info/github/pho3nixf1re/ruby-respoke/master

## Running the tests

The test suite uses VCR to record API requests and responses once. After the
first run it caches these and works offline. These cached files are checked into
Git and can be found in the `test/vcr_cassettes` directory. To run the tests
against the live API just delete the `test/vcr_cassettes` directory. Please note
that this will change the expected input of the encrypted
`test/test_config.yml.enc` file used by Travis and that will need to be updated
if you intend to commit the new VCR cache. Otherwise just omit the new cache
files when making your tests.

### Units

Note that the unit tests do not use the VCR cache in favor of stubbing.

```sh
rake test:unit
```

### Specs

Before you can run the specs yourself you will need to remove the VCR cache
files and provide your Respoke API credentials. Copy the `test/test_config.yml`
file and replace the example values with the ones in the Respoke
[developer portal].

[developer portal]: https://portal.respoke.io

```
cp test/test_config.example.yml test/test_config.yml
```

Fill in the test_config.yml values then run the spec rake task.

```sh
rake test:spec
```

## Building the documentation

The documentation is marked up using Yard + Markdown. The easiest way to build
the included docs is to use the rake task.

```sh
rake yard
```
## Releasing

To cut a new release, you'll need to have permissions to push the `respoke` gem
to the rubygems.org repo.

1. Install gem-release. `gem install gem-release`
2. Do the release. `gem bump --version minor --tag --release`

## Contributing

If you wish to submit an issue use the [issue tracker].

[issue tracker]: https://github.com/pho3nixf1re/ruby-respoke/issues

1. Fork it ( https://github.com/[my-github-username]/ruby-respoke/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

Copyright 2014, Digium, Inc.
All rights reserved.

This source code is licensed under The MIT License found in the
[LICENSE](LICENSE) file in the root directory of this source tree.

For all details and documentation:  https://www.respoke.io
