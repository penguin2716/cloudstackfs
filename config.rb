API_SOURCE_URL = 'https://cloudstack.apache.org/docs/api/apidocs-4.5/TOC_Root_Admin.html'
CACHE_DIR = File.expand_path(File.join(File.dirname(__FILE__), 'cache'))

class APICaller
  @@apiKey = ''
  @@secretKey = ''
  @@baseURL = 'http://cloudstack.example.com'
  @@apiPath = '/client/api?'
end

