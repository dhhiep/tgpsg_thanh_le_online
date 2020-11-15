# frozen_string_literal: true

module TgpsgThanhLeOnline
  module Caching
    class Base
      class << self
        def get(cached_key)
          object = bucket.object(cached_key)
          content = object.get.body.read
          JSON.parse(content, symbolize_names: true)
        rescue # rubocop:disable Lint/SuppressedException
        end

        def set(cached_key, data)
          object = bucket.object(cached_key)
          object.put(body: data.to_json)
          data
        rescue # rubocop:disable Lint/SuppressedException
        end

        def delete(cached_key)
          bucket.object(cached_key).delete
        rescue # rubocop:disable Lint/SuppressedException
        end

        def fetch(cached_key, options = {}, &block)
          cached_data = nil

          if expired?(cached_key, options[:expired_time])
            delete(cached_key)
          else
            cached_data = get(cached_key)
          end

          return cached_data if cached_data && options[:reload_cache] != true

          begin
            cached_data = block.call
          ensure
            set(cached_key, cached_data) rescue nil
          end

          cached_data
        end

        private

        def s3_client
          @s3_client ||=
            Aws::S3::Resource.new(
              region: ENV.to_h['AWS_DEFAULT_REGION'],
              credentials: aws_credentials,
            )
        end

        def bucket
          s3_client.bucket(bucket_name)
        end

        def bucket_name
          raise NotImplementedError, 'Please implement me at subclass!'
        end

        def aws_credentials
          Aws::Credentials.new(
            ENV.to_h['AWS_RESOURCE_ACCESS_KEY_ID'],
            ENV.to_h['AWS_RESOURCE_SECRET_ACCESS_KEY'],
          )
        end

        def expired?(cached_key, expired_time)
          object = bucket.object(cached_key)
          return if expired_time.to_i <= 0 || !object.exists?

          bucket.object(cached_key).data.last_modified <= Time.now - expired_time
        end
      end
    end
  end
end
