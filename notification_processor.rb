require_relative './mailer'

class NotificationProcessor

  attr_reader :notification
  def initialize(notification)
    @notification = notification
    validate
    make_folder
  end

  def process!
    begin
      download_video
      send_mail
      Video.create!(video_title: video_title)
    rescue Error => e
      return nil
    end
  end

  private

  def message
    @message ||= JSON.parse(notification['Message'])
  end

  def parser
    @parser ||= Mail.new(message['content'])
  end

  def from
    @from ||= parser.from[0]
  end

  def text
    @text ||= plain_text_part&.raw_source || parser.body.raw_source
  end

  def plain_text_part
    @plain_text_part ||= parser.parts.select { |p| p.content_type.include?('text/plain') }.first
  end

  def url
    @url ||= URI.extract(text, ['http', 'https'])&.dig(0)
  end

  def video_title
    @video_title ||= `youtube-dl --skip-download -e #{url}`.strip
  end

  def video
    @video ||= Video.find_by(video_title: video_title)
  end

  def validate
    raise Error::NoTextFound unless text
    raise Error::UrlNotFound unless url
    raise Error::AlreadyDownloaded, "video already downloaded: #{url}" if video
  end

  def download_video
    raise Error::DownloadFailed, "couldn't download" unless download!
  end

  def send_mail
    return if from.include? 'noreply'
    Mailer.send(to: from, title: video_title)
  end

  def dir_name
    @dir_name ||= "#{ENV['ROOT_DOWNLOAD_FOLDER']}/#{folder_name}"
  end

  def folder_name
    @folder_name ||= from.split('@').first
  end

  def make_folder
    return if File.exists?(dir_name)
    FileUtils::mkdir_p(dir_name)
  end

  def download!
    return true if system("youtube-dl -o '#{dir_name}/#{video_title}' #{url}")
    false
  end
end