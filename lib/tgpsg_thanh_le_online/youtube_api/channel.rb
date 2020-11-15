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
        videos_builder(videos)
      end

      private

      def videos_builder(videos)
        items = videos.body[:items]
        return [] if items.nil? || items.empty?

        video_datum =
          items.map do |item|
            video_snippet = item[:snippet]

            video_id = item.dig(:id, :videoId)
            video_url = "https://www.youtube.com/watch?v=#{video_id}"
            video_thumbnail = video_snippet.dig(:thumbnails, :high, :url)
            video_title = video_snippet[:title]
            video_event_type = video_snippet[:liveBroadcastContent]
            video_published_at = title_datatime_extractor(video_title)

            video_data = {
              timestamp: video_published_at.to_i,
              id: video_id,
              url: video_url,
              thumbnail: video_thumbnail,
              title: video_title,
              event_type: video_event_type,
              published_at: video_published_at,
            }

            video_data_valid?(video_data) ? video_data : nil
          end

        video_datum.compact.sort_by { |video| video[:timestamp] }
      end

      # Thánh Lễ trực tuyến: thứ Năm tuần 33 mùa Thường niên lúc 18g ngày 19-11-2020
      # Thánh Lễ trực tuyến: thứ Sáu tuần 33 mùa Thường niên lúc 17g30 ngày 20-11-2020
      def title_datatime_extractor(video_title)
        datetime_matched = video_title.match(/.*lúc (.*)ngày (.*)/)
        return unless datetime_matched

        datetime_matched = "#{datetime_matched[2]} #{datetime_matched[1]} +07:00"

        title_datatime_patterns.each do |pattern|
          return Time.strptime(datetime_matched, pattern)
        rescue => _e
          next
        end
      end

      def title_datatime_patterns
        @title_datatime_patterns ||= [
          '%d-%m-%Y %Hg%M %Z',
          '%d-%m-%Y %Hg %Z',

          '%d-%m-%Y %H:%M %Z',
          '%d/%m/%Y %Hg%M %Z',
          '%d/%m/%Y %H:%M %Z',

          '%d/%m/%Y %Hg %Z',
          '%d/%m/%Y %H %Z',
        ]
      end

      def video_data_valid?(video_data)
        # Ritle datetime invalid
        if video_data[:timestamp].zero?
          puts "Invalid datetime in title: #{video_title}"
          return
        end

        if video_data[:timestamp] > Time.now.to_i && video_data[:event_type] == 'none'
          puts "Video streamed but publish time is upcoming. Details: #{video_data}"
          return
        end

        true
      end
    end
  end
end
