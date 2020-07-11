# frozen_string_literal: true

require 'shrine/plugins/cloudimage'
require 'shrine/storage/memory'

describe Shrine::Plugins::Cloudimage do
  before do
    @shrine = Class.new(Shrine)
    @shrine.storages[:memory] = Shrine::Storage::Memory.new
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
end
