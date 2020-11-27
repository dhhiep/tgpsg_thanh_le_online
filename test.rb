require 'open-uri'
require 'pry'
require 'json'
require 'concurrent'

def video_published_at(raw_content)
  published_at = raw_content.match(/"startTimestamp":"(.*)\",\"endTimestamp\"/)
  published_at ||= raw_content.match(/"startTimestamp":"(.*)\"},\"uploadDate"/)
  return unless published_at

  Time.parse(published_at[1]).getlocal('+07:00')
end

def video_end_at(raw_content)
  stream_end_at = raw_content.match(/"endTimestamp":"(.*)\"},\"uploadDate"/)
  return unless stream_end_at

  Time.parse(stream_end_at[1]).getlocal('+07:00')
end

def video_raw_content(url)
  URI.parse(url).read
end

list = JSON.parse(URI.open('https://467f3zdo54.execute-api.ap-southeast-1.amazonaws.com/live/api/masses/').read)

futures =
  list.map do |video|
    Concurrent::Future.execute do
      puts "\nStart: #{video['title']} - #{video['url']}"
      raw_content = video_raw_content(video['url'])
      video_published_at = video_published_at(raw_content)
      video_end_at = video_end_at(raw_content)
      puts "publish_date: #{video_published_at} - video_end_at: #{video_end_at}"
      [video_published_at, video_end_at]
    end
  end

values = futures.map(&:value)
puts "values: #{values}"
