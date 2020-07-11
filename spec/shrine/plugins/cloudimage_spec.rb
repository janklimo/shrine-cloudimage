# frozen_string_literal: true

require 'shrine/plugins/cloudimage'
require 'shrine/storage/s3'

describe Shrine::Plugins::Cloudimage do
  before do
    @shrine = Class.new(Shrine)
    bucket = 'my-bucket'
    @storage = Shrine::Storage::S3.new(
      bucket: bucket, stub_responses: true, public: true,
    )
    @shrine.storages[:s3] = @storage
    @s3_site = "https://#{bucket}.s3.us-stubbed-1.amazonaws.com"
  end

  describe '.configure' do
    it 'accepts :client as a hash' do
      @shrine.plugin :cloudimage, client: { token: 'token' }

      expect(@shrine.cloudimage_client).to be_instance_of Cloudimage::Client
      expect(@shrine.cloudimage_client.path('/image.jpg').to_url)
        .to eq 'https://token.cloudimg.io/v7/image.jpg'
    end

    it 'accepts :client as a Cloudimage::Client' do
      @shrine.plugin :cloudimage,
                     client: Cloudimage::Client.new(token: 'token')

      expect(@shrine.cloudimage_client).to be_instance_of Cloudimage::Client
      expect(@shrine.cloudimage_client.path('/image.jpg').to_url)
        .to eq 'https://token.cloudimg.io/v7/image.jpg'
    end

    it 'fails on missing :client option' do
      expect { @shrine.plugin :cloudimage }
        .to raise_error Shrine::Error, /:client is required/
    end
  end

  describe '#cloudimage_url' do
    before do
      @shrine.plugin :cloudimage, client: { token: 'token' }
      @file =
        @shrine.upload(StringIO.new('file'), :s3, location: 'assets/image.jpg')
    end

    it 'returns Cloudimage URL' do
      expect(@file.cloudimage_url)
        .to eq "https://token.cloudimg.io/v7/#{@s3_site}/assets/image.jpg"
    end

    it 'accepts transformation options' do
      expected = "https://token.cloudimg.io/v7/#{@s3_site}" \
        '/assets/image.jpg?h=200&w=100'
      expect(@file.cloudimage_url(w: 100, h: 200)).to eq expected
    end

    it 'accepts security options' do
      @shrine.plugin :cloudimage, client: {
        token: 'token', salt: 'salt', sign_urls: false, signature_length: 10
      }
      expected = "https://token.cloudimg.io/v7/#{@s3_site}/assets/image.jpg?" \
        'ci_eqs=Ymx1cj0yMCZoPTMwMCZ3PTMwMA&ci_seal=a926d4eab9'
      result = @file.cloudimage_url(
        blur: 20, w: 300, h: 300, seal_params: %i[w h blur],
      )
      expect(result).to eq expected
    end
  end
end
