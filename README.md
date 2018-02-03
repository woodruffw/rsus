# RSUS

A really simple upload service.

## Installation

```
$ git clone https://github.com/woodruffw/rsus && cd rsus
$ shards build --production
```

## Usage

Set up:

```bash
$ nano config.yml
$ ./bin/rsus
```

...and use:

```bash
$ curl -F auth=<your-token> -F file="@<your path>" <your endpoint>
```

## TODO

1. Maybe do de-duplication
2. Maybe add a web interface

## Contributing

1. Fork it (`https://github.com/woodruffw/rsus/fork`)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [woodruffw](https://github.com/woodruffw) William Woodruff - creator, maintainer
