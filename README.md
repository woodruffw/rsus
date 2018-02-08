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
$ cp config.yml.example config.yml
$ nano config.yml
$ ./bin/rsus
```

Here are some Nginx proxy rules, if that's your kind of thing:

```nginx
location /i/ {
        proxy_pass http://127.0.0.1:3000/u/;
        proxy_set_header    Host              $host;
        proxy_set_header    X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

}

location /upload/ {
        proxy_pass http://127.0.0.1:3000/;
        proxy_set_header    Host              $host;
        proxy_set_header    X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

}
```

...and use:

```bash
$ curl -F auth=<your-token> -F file="@<your path>" <your endpoint>
```

## TODO

1. Maybe do de-duplication
2. Maybe add a web interface
3. Log uploads
4. Optional EXIF/tag stripping

## Contributing

1. Fork it (`https://github.com/woodruffw/rsus/fork`)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [woodruffw](https://github.com/woodruffw) William Woodruff - creator, maintainer
