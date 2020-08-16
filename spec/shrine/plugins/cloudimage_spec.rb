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
    @file =
      @shrine.upload(StringIO.new('file'), :s3, location: 'assets/image.jpg')
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

  describe '#cloudimage_srcset' do
    it 'returns srcset' do
      @shrine.plugin :cloudimage, client: { token: 'token' }

      result = @file.cloudimage_srcset(blur: 5)
      urls = result.split(', ')

      expect(urls.size).to be > 3
      expect(urls).to all(match(/blur=5&w=\d{3,4} \d{3,4}w/))
    end
  end

  describe '#delete' do
    it "doesn't invalidate by default" do
      @shrine.plugin :cloudimage, client: { token: 'token', api_key: 'key' }
      allow(@shrine.cloudimage_client).to receive(:invalidate_original)

      @file.delete

      expect(@shrine.cloudimage_client)
        .not_to have_received(:invalidate_original)
    end

    it 'performs invalidation when opted-in' do
      options = {
        token: 'token',
        api_key: 'key',
        aliases: {
          'https://my-bucket.s3.us-stubbed-1.amazonaws.com' => '_cdn_',
        },
      }
      @shrine.plugin :cloudimage, client: options, invalidate: true
      allow(@shrine.cloudimage_client).to receive(:invalidate_original)

      # One way to trigger invalidation
      @file.cloudimage_invalidate

      # ... and another.
      @file.delete

      expect(@shrine.cloudimage_client)
        .to have_received(:invalidate_original)
        .with('/v7/_cdn_/assets/image.jpg')
        .twice
    end
  end
end
