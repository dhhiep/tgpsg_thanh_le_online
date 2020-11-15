# frozen_string_literal: true

module TgpsgThanhLeOnline
  module YoutubeApi
    class Base
      TIMEOUT = 30

      private

      def search(options)
        sender(:get, 'search', options)
      end

      def sender(type, path, body = {})
        resp = HTTParty.send(type, api_path_builder(path), http_data_builder(type, body))
        OpenStruct.new(code: resp.code, body: JSON.parse(resp.body, symbolize_names: true))
      rescue Net::ReadTimeout => e
        OpenStruct.new(code: 502, body: { message: e.message })
      rescue StandardError => e
        OpenStruct.new(code: 403, body: { message: e.message })
      end

      def youtube_endpoint
        'https://youtube.googleapis.com/youtube/v3'
      end

      def api_path_builder(path)
        [youtube_endpoint, path].join('/')
      end

      def http_data_builder(type, body)
        base_params = {
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          timeout: TIMEOUT,
        }

        # Youtube passing API_KEY to query string for all method GET, POST, PUT and DELETE
        # https://youtube.googleapis.com/youtube/v3/videos?key=[YOUR_API_KEY]
        base_params[:query] = { key: api_key }

        if %i[post delete].include?(type.downcase.to_sym)
          base_params[:body] = body.to_h
        elsif %i[get put].include?(type.downcase.to_sym)
          base_params[:query] = base_params[:query].merge(body.to_h)
        end

        base_params
      end

      def api_key
        ENV['YOUTUBE_API_KEY']
      end
    end
  end
end
