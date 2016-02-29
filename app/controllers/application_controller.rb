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
    redirect "/tweets" if Helpers.is_logged_in?(session)
    erb :index
  end

  get '/signup' do
    redirect "tweets" if Helpers.is_logged_in?(session)
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
    redirect '/tweets'if Helpers.is_logged_in?(session)
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
      redirect "/login"
    end
  end

  get '/logout' do
    session.clear if Helpers.is_logged_in?(session)
    redirect "/login" if !Helpers.is_logged_in?(session)
  end

  get '/users' do
    redirect "/login" if !Helpers.is_logged_in?(session)
    erb :"users/index"
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :"users/show"
  end

  get '/tweets' do
    redirect "/login" if !Helpers.is_logged_in?(session)
    erb :"tweets/index"
  end

  # Posted from /tweets/new
  post '/tweets' do
    redirect "/tweets/new" if params[:content].empty?
    @user = Helpers.current_user(session)
    @user.tweets << Tweet.create(content: params[:content])

    erb :"tweets/index"
  end

  get '/tweets/new' do
    redirect "/login" if !Helpers.is_logged_in?(session)
    erb :"tweets/new"
  end

  get '/tweets/:id' do
    redirect "/login" if !Helpers.is_logged_in?(session)
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
    if Helpers.is_logged_in?(session)
      @tweet = Tweet.find(params[:id])
      if @tweet.user_id == Helpers.current_user(session).id
        erb :"tweets/edit"
      else
        redirect "/tweets"
      end
    else
      redirect "/login" 
    end  
  end

  post '/tweets/:id/delete' do
    if Helpers.is_logged_in?(session)
      @tweet = Tweet.find(params[:id])
      if @tweet.user_id == Helpers.current_user(session).id
        @tweet.delete
      else
        redirect "/tweets"
      end
    else
      redirect "/login" 
    end  
  end


end