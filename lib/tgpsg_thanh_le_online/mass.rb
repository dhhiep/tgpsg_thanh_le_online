# frozen_string_literal: true

# require 'pry'

module TgpsgThanhLeOnline
  class Mass
    class << self
      def all_events(reload_cache: false)
        cached_key = 'tgpsg_mass_online_videos.json'
        expired_time = ENV.to_h['HTTP_RESPONSE_EXPIRE'].to_i * 60 # in minutes

        TgpsgThanhLeOnline::Caching::Response.fetch(cached_key, reload_cache: reload_cache, expired_time: expired_time) do
          mass = Mass.new

          videos = [
            mass.upcoming_videos,
            mass.live_videos,
            mass.streamed_videos,
          ]

          videos = videos.flatten
          videos = videos.uniq { |video| video[:timestamp] }
          videos = videos.sort_by { |video| video[:timestamp] }
          videos.reverse
        end
      end
    end

    def tgpsg_channel
      @tgpsg_channel ||= TgpsgThanhLeOnline::YoutubeApi::Channel.new('UCc7qu2cB-CzTt8CpWqLba-g')
    end

    def upcoming_videos
      @upcoming_videos ||= tgpsg_channel.videos(type: 'upcoming').reverse
    end

    def live_videos
      @live_videos ||= tgpsg_channel.videos(type: 'live')
    end

    def streamed_videos
      @streamed_videos ||= tgpsg_channel.videos(type: 'none')
    end
  end
end
