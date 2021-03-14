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
        video_ids_api = video_ids_by_api(type: type, per_page: per_page)

        video_ids =
          if type == 'upcoming'
            [video_ids_api, upcoming_video_ids_by_fetcher].flatten.compact.uniq
          else
            video_ids_api
          end

        video_datum_builder(video_ids)
      end

      private

      def upcoming_video_ids_by_fetcher
        @upcoming_video_ids_by_fetcher ||= Youtube::VideosUpcomingFetcher.fetch(channel_id)
      end

      def video_ids_by_api(type: 'none', per_page: 15)
        query_options = {
          part: 'snippet',
          order: 'date',
          type: 'video',
          channelId: channel_id,
          eventType: type,
          maxResults: per_page,
        }

        videos = search(query_options)
        items = videos.body[:items] || []
        items.map { |item| item.dig(:id, :videoId) }
      end

      def video_datum_builder(video_ids)
        return [] if video_ids.nil? || video_ids.empty?

        video_datum =
          video_ids.map do |video_id|
            Concurrent::Future.execute do
              Youtube::VideoFetcher.fetch(video_id)
            end
          end

        video_datum.map(&:value).sort_by { |video| video[:timestamp] }
      end
    end
  end
end
