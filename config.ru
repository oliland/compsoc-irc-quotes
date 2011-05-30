require 'rubygems'
require 'bundler'

Bundler.require

require './app'

use Rack::Static, :urls => ["/css", "/img", "/js", "/favicon.ico"], :root => "public"

run CompSocQuotes
