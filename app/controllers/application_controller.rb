require './config/environment'
require "./app/models/user"

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

  # Helpers

    def current_user
       User.find(session[:user_id]) if session[:user_id]
    end

    def is_logged_in?
      !!current_user
    end


  get '/' do
    if is_logged_in?
      redirect to '/tweets'
    else
      erb :'index'
    end
  end

# LOGIN CONTROLLERS
  get '/signup' do

    if !is_logged_in?
      erb :'/users/create_user'
    else
      redirect to '/tweets'
    end
  end

  post '/signup' do

    if params[:username] == "" || params[:password] == "" || params[:email] == ""
        redirect '/signup'
    else
      @user = User.create(params)
      session[:user_id] = @user.id

      redirect to "/tweets"
    end
  end



  get '/login' do
    if is_logged_in?
        redirect('/tweets')
    else
      erb :'users/login'
    end
  end

  post "/login" do
      @user = User.find_by(username: params[:username])
      if @user != nil && @user.authenticate(params[:password])
        session[:user_id] = @user.id
        redirect('/tweets')
      else
        redirect('/login')
      end

  end


  get '/logout' do
    if is_logged_in?
      session.clear

      redirect('/login')
    else
      redirect('/')
    end

  end



# TWEETS CONTROLLERS

  get "/tweets" do
    if is_logged_in?
      @tweets = Tweet.all
      erb :'tweets/tweets'
    else
      redirect('/login')
    end
  end

  get '/tweets/new' do
    if is_logged_in?
      erb :'/tweets/create_tweet'
    else
      redirect("/login")
    end
  end

  post '/tweets' do
    if params[:content] == ""
      redirect("/tweets/new")
    else
      @tweet = Tweet.new
      @tweet.content = params[:content]
      @tweet.user_id = session[:user_id]
      @tweet.save

      redirect("/tweets/#{@tweet.id}")
    end
  end

  get '/tweets/:id' do
    if is_logged_in?
      @tweet=Tweet.find(params[:id])
      erb :'tweets/show_tweet'
    else
      redirect("/login")
    end

  end

  get '/tweets/:id/edit' do
    if is_logged_in?
      @tweet = Tweet.find(params[:id])
      erb :'tweets/edit_tweet'
    else
      redirect("/login")
    end
  end

  patch '/tweets/:id' do

    if params[:content] == ""

      redirect("tweets/#{params[:id]}/edit")
    else
      @tweet = Tweet.find(params[:id])
      @tweet.update(content: params[:content])
      redirect :'/tweets'
    end
  end

  delete '/tweets/:id/delete' do
    if is_logged_in? &&  Tweet.find(params[:id]).user == current_user 

      Tweet.destroy(params[:id])
      redirect('/tweets')
    else
      redirect("/login")
    end
  end

# user controller
  get '/users/:slug' do

    @user = User.find_by_slug(params[:slug])

    erb :'users/show'
  end


end
