require './config/environment'

# ApplicationController handles requests for homepage, signup and logins
class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'

    enable :sessions
    set :session_secret, "secret"
  end

  get '/' do
    redirect "/tweets" if is_logged_in?
    erb :index
  end

  get '/signup' do
    redirect "tweets" if is_logged_in?
    erb :"users/signup"
  end

  post '/signup' do
    if params[:username] == "" || params[:email] == "" || params[:password] == ""
      erb :"users/signup", locals: {message: "Please submit enter all the information to complete signup."}
    else
      @user = User.create(
        username: params[:username],
        email: params[:email],
        password: params[:password]
      )
      session[:user_id] = @user.id
      erb :"tweets/index", locals: {message: "Welcome to Fwitter. Thank you for signing up."}
    end
  end

  get '/login' do
    redirect '/tweets'if is_logged_in?
    erb :"users/login"
  end

  post '/login' do
    if params[:username] == "" || params[:password] == ""
      redirect "/login"
    end

    @user = User.find_by(username: params[:username])
    if  @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect "/tweets"
    else
      erb :"users/login", locals: {message: "Invalid username or password."}
    end
  end

  get '/logout' do
    session.clear if is_logged_in?
    @current_user = nil
    redirect "/login"
  end

  get '/users' do
    redirect "/login" if !is_logged_in?
    erb :"users/index"
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :"users/show"
  end

  get '/tweets' do
    redirect "/login" if !is_logged_in?
    erb :"tweets/index"
  end

  # Posted from /tweets/new
  post '/tweets' do
    redirect "/tweets/new" if params[:content].empty?
    @user = current_user
    @user.tweets << Tweet.create(content: params[:content])

    erb :"tweets/index"
  end

  get '/tweets/new' do
    redirect "/login" if !is_logged_in?
    erb :"tweets/new"
  end

  get '/tweets/:id' do
    redirect "/login" if !is_logged_in?
    @tweet = Tweet.find(params[:id])
    erb :"tweets/show"
  end

  # Posted from /tweets/:id/edit
  post '/tweets/:id' do
    @tweet = Tweet.find(params[:id])
    redirect "/tweets/#{@tweet.id}/edit" if params[:content].empty?
    @tweet.update(content: params[:content])
      
    erb :"tweets/show"
  end

  get '/tweets/:id/edit' do
    @tweet = Tweet.find(params[:id])
    if is_logged_in?
      if @tweet.user_id == current_user.id
        erb :"tweets/edit"
      else
        redirect "/tweets"
      end
    else
      redirect "/login" 
    end  
  end

  post '/tweets/:id/delete' do
    @tweet = current_user.tweets.find_by(id: params[:id])
    if tweet && tweet.destroy
      redirect "/tweets"
    else
      redirect "/tweets/#{params[:id]}" 
    end  
  end

  def current_user
    @current_user || User.find(session[:user_id]) if session[:user_id] != nil
  end

  def is_logged_in?
    !!current_user
  end

end