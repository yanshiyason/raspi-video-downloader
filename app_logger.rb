class AppLogger < Logger
  LOG_PATH = './logs/app_logs.log'

  def initialize
    super LOG_PATH
  end
end
