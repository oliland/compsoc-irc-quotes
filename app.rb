require 'erb'
require 'omniauth'
require 'sinatra'
require 'sinatra/sequel'


configure :development do
  set :database, 'sqlite://data.db'
  # TODO
=begin
  OmniAuth.config.mock_auth[:facebook] = {
   'uid' => '123545',
   'user_info' => {'first_name' => 'Tester', 'last_name' => 'McTest'}
  }
=end
end

configure :production do
  set :database, 'postgres://postgres:Hatemachine@localhost/irc'
end

require './models/authorization'
require './models/quote'
require './models/user'
require './models/vote'

class CompSocQuotes < Sinatra::Base

  use OmniAuth::Builder do
    provider :facebook, '20591859c74eb33429cd5c35faa166af', \
      'b4c7387740cb09d56c64bfacc5d7b11e',
      {:scope => ''}
  end

  enable :sessions

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html

    def current_user
      if session[:user]
        User[:id => session[:user]]
      end
    end

    def protected!
      unless current_user
        throw(:halt, [401, "Not authorized\n"])
      end
    end  
  end

  get '/' do
    sort = params[:sort]
    if sort == "votes"
        @quotes = Quote.order(:votes.desc).all
    end
    @quotes ||= Quote.order(:created_at.desc).all
    erb :index
  end

  get '/add' do
    erb :form
  end

  post '/add' do
    protected!
    Quote.create(
      :user_id => current_user.id,
      :content => params["content"],
      :votes => 0,
    )
    redirect '/'
  end

  post '/vote' do
    protected!
    quote = Vote.vote(current_user.id, params[:quote], params[:direction])
    status 201
    body quote.votes.to_s
  end

  get '/auth/:name/callback' do
    data = request.env['omniauth.auth']
    auth = Authorization.find_or_create(:provider => data["provider"],
                                        :uid => data["uid"]) do |a|
      user = User.create(
        :first_name => data["user_info"]["first_name"],
        :last_name => data["user_info"]["last_name"],
      )
      a.user_id = user.id
      a.save
    end
    #User.find[auth.user_id].last_login = Time.now
    session[:user] = auth.user_id
    redirect '/'
  end

  get '/logout' do
    session[:user] = nil
    redirect '/'
  end
end
