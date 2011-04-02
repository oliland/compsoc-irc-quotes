require './app'

use Rack::Static, :urls => ["/css", "/img", "/js", "/favicon.ico"], :root => "public"

run CompSocQuotes
