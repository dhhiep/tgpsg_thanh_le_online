# frozen_string_literal: true

require 'json'
require 'dotenv'
require 'httparty'
require 'aws-sdk-s3'
require 'open-uri'
require 'concurrent'

require_relative './lib/tgpsg_thanh_le_online/env'
require_relative './lib/tgpsg_thanh_le_online/mass'
require_relative './lib/tgpsg_thanh_le_online/youtube/video_fetcher'
require_relative './lib/tgpsg_thanh_le_online/youtube_api/base'
require_relative './lib/tgpsg_thanh_le_online/youtube_api/channel'
require_relative './lib/tgpsg_thanh_le_online/caching/base'
require_relative './lib/tgpsg_thanh_le_online/caching/response'
require_relative './lib/tgpsg_thanh_le_online/youtube/videos_upcoming_fetcher'

puts TgpsgThanhLeOnline::Mass.events(reload_cache: true)