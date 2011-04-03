require 'sinatra'
require 'sinatra/sequel'

require 'omniauth'
require 'haml'

configure :development do
  set :database, 'sqlite://data.db'
end

configure :production do
  set :database, 'postgres://postgres:Hatemachine@localhost/irc'
end

class User < Sequel::Model
  def save
    self.created_at ||= Time.now
    self.updated_at = Time.now
    super
  end
end

class Authorization < Sequel::Model
end

class Quote < Sequel::Model
  def save
    self.created_at ||= Time.now
    self.updated_at = Time.now
    super
  end

  def created_date
    self.created_at.strftime "%B %d, %Y"
  end
end

class Vote < Sequel::Model

  def self.vote(user_id, quote_id, direction)
    user  = User[:id => user_id]
    quote = Quote[:id => quote_id]
    value = 1 if direction == 'up'
    value = -1 if direction == 'down'
    vote = Vote[:user_id => user.id, :quote_id => quote.id]
    if vote
      if vote.value == 1 and value == -1
        vote.value = value
        quote.votes = quote.votes - 2
      elsif vote.value == -1 and value == 1
        vote.value = value
        quote.votes = quote.votes + 2
      end
    else
      vote = Vote.create(:user_id => user.id, :quote_id => quote.id, :value => value)
      quote.votes += value
    end
    vote.save
    quote.save
    return quote
  end

  def save
    self.created_at ||= Time.now
    self.updated_at = Time.now
    super
  end

end

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
    haml :index
  end

  get '/add' do
    haml :form
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
