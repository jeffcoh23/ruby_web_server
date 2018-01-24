class ServerHelper
  # Mapping of extensions to content type
  CONTENT_TYPE_MAPPING = {
    'html' => 'text/html',
    'txt' => 'text/plain',
    'png' => 'image/png',
    'jpg' => 'image/jpeg'
  }

  # If content type can't be found, default to binary data
  DEFAULT_CONTENT_TYPE = 'application/octet-stream'.freeze

  # Helper function that parses the extension of the request file and then looks up
  # its contents
  def self.content_type(path)
    ext = File.extname(path).split('.').last
    CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
  end

  # Takes a request line (e.g. "GET /path?foo=bar HTTP/1.1")
  # and extracts the path from it, scrubbing out parameters
  # and unescaping URI-encoding.
  #
  # This cleaned up path (e.g. "/path") is then converted into
  # a relative path to a file in the server's public folder
  # by joining it with the WEB_ROOT.
  def self.requested_file(request_line)
    request_uri = request_line.split(' ')[1]
    path = URI.unescape(URI(request_uri).path)
    clean = []

    parts = path.split('/')
    parts.each do |part|
      next if part.empty? || part == '.'
      # If the path component goes up one directory level (".."),
      # remove the last clean component.
      # Otherwise, add the component to the Array of clean components
      part == '..' ? clean.pop : clean << part
    end

    # return the web root joined to the clean path
    File.join(WEB_ROOT, *clean)
  end
end
