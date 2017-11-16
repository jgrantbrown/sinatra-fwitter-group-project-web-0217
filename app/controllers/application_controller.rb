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
      @user = User.find_by_id(session[:user_id]) if session[:user_id]
    end

    def is_logged_in?
      !!current_user
    end


  get '/' do

    erb :'index'
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
      @user=User.create(params[:user])
      session[:user_id] = @user.id
      redirect to "/tweets"
    end
  end

  get '/failure' do

    erb :failure
  end

  get '/login' do
    if is_logged_in?
        redirect("/tweets")
    else
      erb :'users/login'
    end
  end

# Sessions CONTROLLERS

  get '/sessions/logout' do
    if is_logged_in?
      session.clear
      redirect to '/'
    else
      redirect to '/'
    end

  end

  post "/sessions" do
      @user = User.find_by(username: params[:user][:username])
      if @user != nil && @user.authenticate(params[:user][:password])
        session[:user_id] = @user.id
        redirect('/tweets')
      end
      erb :"/failure"
  end

# TWEETS CONTROLLERS

  get '/tweets' do
    @tweets = Tweet.all
    erb :'tweets/tweets'
  end

  get '/tweets/new' do

    erb :'/tweets/create_tweet'
  end

  post '/tweets' do
    @tweet = Tweet.new
    @tweet.content = params[:content]
    @tweet.save

    redirect("/tweets/#{@tweet.id}")
  end

  get '/tweets/:id' do
    @tweet = Tweet.find_by(params[:id])
    erb :'tweets/show_tweet'
  end

  get '/tweets/:id/edit' do
    @tweet = Tweet.find_by(params[:id])
    erb :'tweets/edit_tweet'
  end

  patch '/tweets/:id' do

    @tweet = Tweet.find_by(params[:id])
    @tweet.update(params[:tweet])

    redirect :'/tweets'
  end

  delete '/tweets/:id/delete' do

    @tweet = Tweet.find_by(params[:id])
    @tweet.destroy
    redirect :'tweets/tweets'
  end

# user controller
  get '/user/:id' do
    @user = User.find_by(params[:id])
    binding.pry
    erb :'users/show'
  end


end
