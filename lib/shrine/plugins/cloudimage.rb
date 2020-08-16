# frozen_string_literal: true

require 'cloudimage'

class Shrine
  module Plugins
    module Cloudimage
      def self.configure(uploader, **opts)
        if opts[:client].is_a?(Hash)
          opts[:client] = ::Cloudimage::Client.new(**opts[:client])
        end

        uploader.opts[:cloudimage] ||= { invalidate: false }
        uploader.opts[:cloudimage].merge!(**opts)

        return if uploader.cloudimage_client

        raise Error, ':client is required for cloudimage plugin'
      end

      module ClassMethods
        def cloudimage_client
          opts[:cloudimage][:client]
        end
      end

      module FileMethods
        def cloudimage_url(**options)
          cloudimage_client.path(url).to_url(**options)
        end

        def cloudimage_srcset(**options)
          cloudimage_client.path(url).to_srcset(**options)
        end

        def delete
          super
          cloudimage_invalidate if cloudimage_invalidate?
        end

        def cloudimage_invalidate
          path = URI.parse(cloudimage_url).path
          cloudimage_client.invalidate_original(path)
        end

        private

        def cloudimage_client
          shrine_class.cloudimage_client
        end

        def cloudimage_invalidate?
          shrine_class.opts[:cloudimage][:invalidate]
        end
      end
    end

    register_plugin(:cloudimage, Cloudimage)
  end
end
