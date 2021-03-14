# frozen_string_literal: true

module Youtube
  class VideosUpcomingFetcher
    attr_reader :channel_id

    def self.fetch(channel_id)
      video_fetcher = new(channel_id)
      video_fetcher.fetch
    end

    def initialize(channel_id)
      @channel_id = channel_id
    end

    def fetch
      extract_video_ids
    end

    private

    def raw_content
      @raw_content ||= URI.parse(base_url).read
    end

    def extract_video_ids
      raw_content.scan(/"url":"\/watch\?v=(.{10,12})","webPageType"/)
    end

    def base_url
      "https://www.youtube.com/channel/#{channel_id}/videos?view=2&sort=dd&live_view=502&shelf_id=0"
    end
  end
end
