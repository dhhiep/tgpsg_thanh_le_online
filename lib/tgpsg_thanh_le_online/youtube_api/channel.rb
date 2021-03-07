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
              Youtube::VideoFetcher.fetch(item.dig(:id, :videoId))
            end
          end

        video_datum.map(&:value).sort_by { |video| video[:timestamp] }
      end
    end
  end
end
