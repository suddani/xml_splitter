class XmlSplitter::FtpFetcher
  attr_reader :uri, :username, :password

  def initialize(username, password)
    @username = username
    @password = password
  end

  # @param [String] url  full location of the xml, make sure to url-escape spaces etc.
  # for example, the URL of file "US~Partner~Experteer incremental.xml" on "ftp://ftp.monster.com"
  # is "ftp://ftp.monster.com/US~Partner~Experteer%20incremental.xml"
  def fetch_direct(url)
    @uri = URI.parse(url)
    raise "only 'ftp' scheme allowed" if uri.scheme != 'ftp'

    ftp = init_ftp_connection
    ftp.chdir(dirname) if dirname && dirname != ""
    ftp.get(filename, nil)
  end

  private

  def init_ftp_connection
    ftp = Net::FTP.new(uri.host)
    username ? ftp.login(username, password) : ftp.login
    ftp.passive = true
    ftp
  end

  def dirname
    @_dir ||=  URI.unescape(File.dirname(uri.path))
  end

  def filename
    @_filename ||= URI.unescape(File.basename(uri.path))
  end
end
