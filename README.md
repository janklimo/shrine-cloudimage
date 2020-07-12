# Shrine::Plugins::Cloudimage

[![Gem Version](https://badge.fury.io/rb/shrine-cloudimage.svg)](https://badge.fury.io/rb/shrine-cloudimage) ![Build status](https://github.com/janklimo/shrine-cloudimage/workflows/Build/badge.svg)

[Cloudimage](https://www.cloudimage.io) integration for [Shrine](https://shrinerb.com).

Supports Ruby `2.4` and above, `JRuby`, and `TruffleRuby`.

- [Shrine::Plugins::Cloudimage](#shrinepluginscloudimage)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Usage](#usage)
  - [Development](#development)
  - [Contributing](#contributing)
  - [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shrine-cloudimage'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install shrine-cloudimage

## Configuration

Register the plugin with any valid Cloudimage settings:

```ruby
Shrine.plugin :cloudimage, client: {
  token: 'token', salt: 'salt', sign_urls: false, signature_length: 10
}
```

Or pass in the client object directly:

```ruby
require 'cloudimage'

Shrine.plugin :cloudimage, Cloudimage::Client.new(
  token: 'token', salt: 'salt', sign_urls: false, signature_length: 10
)
```

See [`cloudimage`](https://github.com/scaleflex/cloudimage-rb) for a list
of available options.

## Usage

You can generate a Cloudimage URL for a `Shrine::UploadedFile` object by
calling `#cloudimage_url`:

```ruby
photo.image.cloudimage_url(w: 300, h: 300, blur: 5)
# => "https://token.cloudimg.io/v7/https://my-bucket.s3.us-east-1.amazonaws.com/assets/image.jpg?blur=5&h=300&w=300"
```

## Development

After checking out the repo, run `bundle install` to install dependencies.
Then, run `bundle exec rake` to run the tests.

## Contributing

Bug reports and pull requests are welcome! This project is intended
to be a safe, welcoming space for collaboration, and contributors
are expected to adhere to the
[code of conduct](https://github.com/scaleflex/cloudimage-rb/blob/master/CODE_OF_CONDUCT.md).

## License

[MIT](https://opensource.org/licenses/MIT)
