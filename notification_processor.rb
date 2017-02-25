require_relative './mailer'

class NotificationProcessor

  attr_reader :notification, :logger
  def initialize(notification)
    @logger = AppLogger.new
    @notification = notification
    validate
    make_folder
  end

  def process!
    begin
      download_video
      send_mail
    rescue Error => e
      @logger.error(error_message(e))
      return nil
    end
  end

  private

  def error_message(e)
    [e.class, e.message, e.backtrace.join("\n")].join("\n")
  end

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

  def video_found?
    File.file?(download_path)
  end

  def validate
    raise Error::NoTextFound, 'no text found in email' unless text
    raise Error::UrlNotFound, 'url not found in email' unless url
    raise Error::AlreadyDownloaded, "video already downloaded: #{download_path}" if video_found?
  end

  def download_video
    logger.info('Beginning to download video')
    raise Error::DownloadFailed, "couldn't download" unless download!
  end

  def send_mail
    return if from.include? 'noreply'
    logger.info("Sending email to #{from} -- #{video_title}")
    Mailer.send(to: from, title: video_title)
  end

  def dir_name
    @dir_name ||= "#{ENV['ROOT_DOWNLOAD_FOLDER']}/#{folder_name}"
  end

  def folder_name
    @folder_name ||= from.split('@').first
  end

  def download_path
    "#{dir_name}/#{video_title}"
  end

  def make_folder
    return if File.exists?(dir_name)
    FileUtils::mkdir_p(dir_name)
  end

  def download!
    logger.info("Trying to download: #{download_path}")
    return true if system("youtube-dl -o '#{download_path}' #{url}")
    false
  end
end