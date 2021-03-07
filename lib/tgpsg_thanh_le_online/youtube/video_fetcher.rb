# frozen_string_literal: true

module Youtube
  class VideoFetcher
    attr_reader :video_id

    def self.fetch(video_id)
      video_fetcher = new(video_id)
      video_fetcher.fetch
    end

    def initialize(video_id)
      @video_id = video_id
    end

    def fetch
      # Video ID invalid
      return {} if video_published_at.to_i.zero?

      {
        timestamp: video_published_at.to_i,
        id: video_id,
        url: video_url,
        thumbnail: thumbnail,
        title: video_title,
        event_type: video_ended_at ? 'streamed' : 'upcoming',
        published_at: video_published_at,
        ended_at: video_ended_at,
      }
    end

    private

    def video_published_at
      published_at = raw_content.match(/"startTimestamp":"(.*)\",\"endTimestamp\"/)
      published_at ||= raw_content.match(/"startTimestamp":"(.*)\"},\"uploadDate"/)
      return unless published_at

      Time.parse(published_at[1]).getlocal('+07:00')
    end

    def video_ended_at
      stream_ended_at = raw_content.match(/"endTimestamp":"(.*)\"},\"uploadDate"/)
      return unless stream_ended_at

      Time.parse(stream_ended_at[1]).getlocal('+07:00')
    end

    def video_title
      title = raw_content.match(/"title":\{"simpleText":"(.*)\"},\"description\"/)
      return unless title

      title[1]
    end

    def raw_content
      @raw_content ||= URI.parse(video_url).read
    end

    def thumbnail
      "https://i.ytimg.com/vi/#{video_id}/maxresdefault_live.jpg"
    end

    def video_url
      "https://www.youtube.com/watch?v=#{video_id}"
    end
  end
end
