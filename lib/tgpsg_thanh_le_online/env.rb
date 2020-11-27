# frozen_string_literal: true

module TgpsgThanhLeOnline
  module Env
    def stage
      ENV['STAGE_ENV'] || 'development'
    end

    def test?
      stage == 'test'
    end

    def development?
      stage == 'development'
    end

    def region
      ENV['AWS_REGION'] || 'ap-southeast-1'
    end

    extend self

    Dotenv.load(".env.#{stage}", '.env')
  end
end
