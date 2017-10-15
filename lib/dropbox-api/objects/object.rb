module Dropbox
  module API

    class Object
      attr_accessor :client, :deleted, :response

      def initialize(response, client)
        self.deleted = false
        self.client  = client
        self.response = response
      end

      def self.resolve_class(hash)
        hash['.tag'] == 'folder' ? Dropbox::API::Dir : Dropbox::API::File
      end

      def self.convert(result, client)
        if result.is_a?(Array)
          result.map do |item|
            resolve_class(item).new(item, client)
          end
        else
          resolve_class(result).new(result,client)
        end
      end

      # Kill off the ability for recursive conversion
      def deep_update(other_hash)
        other_hash.each_pair do |k,v|
          key = convert_key(k)
          regular_writer(key, convert_value(v, true))
        end
        self
      end

      def is_deleted?
        self.deleted
      end

    end

  end
end
