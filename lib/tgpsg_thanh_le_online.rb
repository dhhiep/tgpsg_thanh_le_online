# frozen_string_literal: true

require 'json'
require 'dotenv'
require 'httparty'
require 'aws-sdk-s3'
require 'open-uri'
require 'concurrent'

require_relative './tgpsg_thanh_le_online/env'
require_relative './tgpsg_thanh_le_online/mass'
require_relative './tgpsg_thanh_le_online/youtube_api/base'
require_relative './tgpsg_thanh_le_online/youtube_api/channel'
require_relative './tgpsg_thanh_le_online/caching/base'
require_relative './tgpsg_thanh_le_online/caching/response'

def handler(event:, context:)
  {
    statusCode: 200,
    headers: default_headers,
    body: body_builder(event),
  }
end

def default_headers
  [{ 'Content-Type' => 'application/json' }]
end

def body_builder(event)
  reload_cache = event.dig('queryStringParameters', 'reload_cache') == 'true'
  TgpsgThanhLeOnline::Mass.all_events(reload_cache: reload_cache).to_json
end
