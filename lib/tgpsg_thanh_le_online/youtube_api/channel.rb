# frozen_string_literal: true

module TgpsgThanhLeOnline
  module YoutubeApi
    class Channel < Base
      attr_reader :channel_id

      def initialize(channel_id)
        super()
        @channel_id = channel_id
      end

      def videos(type: 'none', per_page: 15)
        query_options = {
          part: 'snippet',
          order: 'date',
          type: 'video',
          channelId: channel_id,
          eventType: type,
          maxResults: per_page,
        }

        videos = search(query_options)
        video_datum_builder(videos)
      end

      private

      def video_datum_builder(videos)
        items = videos.body[:items]
        return [] if items.nil? || items.empty?

        video_datum =
          items.map do |item|
            Concurrent::Future.execute do
              video_snippet = item[:snippet]

              video_id = item.dig(:id, :videoId)
              video_url = "https://www.youtube.com/watch?v=#{video_id}"
              video_thumbnail = video_snippet.dig(:thumbnails, :high, :url)
              video_title = video_snippet[:title]
              video_event_type = video_snippet[:liveBroadcastContent]
              raw_content = video_raw_content(video_url)
              video_published_at = video_published_at(raw_content)
              video_ended_at = video_ended_at(raw_content)

              {
                timestamp: video_published_at.to_i,
                id: video_id,
                url: video_url,
                thumbnail: video_thumbnail,
                title: video_title,
                event_type: video_event_type,
                published_at: video_published_at,
                ended_at: video_ended_at,
              }
            end
          end

        video_datum.map(&:value).sort_by { |video| video[:timestamp] }
      end

      def video_published_at(raw_content)
        published_at = raw_content.match(/"startTimestamp":"(.*)\",\"endTimestamp\"/)
        published_at ||= raw_content.match(/"startTimestamp":"(.*)\"},\"uploadDate"/)
        return unless published_at

        Time.parse(published_at[1]).getlocal('+07:00')
      end

      def video_ended_at(raw_content)
        stream_ended_at = raw_content.match(/"endTimestamp":"(.*)\"},\"uploadDate"/)
        return unless stream_ended_at

        Time.parse(stream_ended_at[1]).getlocal('+07:00')
      end

      def video_raw_content(url)
        URI.parse(url).read
      end
    end
  end
end
