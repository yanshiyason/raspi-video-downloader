class Error < StandardError
  AlreadyDownloaded = Class.new(self)
  DownloadFailed    = Class.new(self)
  UrlNotFound       = Class.new(self)
  NoTextFound       = Class.new(self)
end