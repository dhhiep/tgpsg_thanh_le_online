# frozen_string_literal: true

module TgpsgThanhLeOnline
  module Caching
    class Response < Base
      class << self
        private

        def bucket_name
          'giaoxutanphuoc'
        end
      end
    end
  end
end
