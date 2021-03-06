class UsersController < ApplicationController
  before_action :require_login, except: [:index, :new, :create]
  before_action :require_logout, only: [:new]
  before_action :require_current_user, only: [:update, :destroy]


  def index
    if signed_in_user?
      @activities = Activity.followed_activity_list(current_user)
      @users = User.top_users
    else
      redirect_to new_user_path
    end
  end


  def show
    @user = User.find_by_id(params[:id])
    @user.profile.build_photo if @user.profile.photo.nil?
    unless @user
      flash[:danger] = "Sorry! That user doesn't exist!"
      redirect_to users_path
    end
  end


  def new
    @user = User.new
    @user.build_profile
    @user.profile.build_photo
  end

  # TODO: welcome email
  def create
    @user = User.new( user_params )
    if @user.save
      sign_in(@user)
      flash[:success] = "Thanks for signing up!"
      redirect_to user_path(@user)
    else
      flash.now[:danger] = "Oops... please correct errors and try again: " +
        @user.errors.full_messages.join(', ')
      render :new
    end
  end


  def update
    if current_user.update( user_params )
      flash[:success] = "User information updated!"
      redirect_to user_path(current_user)
    else
      flash[:danger] = "Oops... please correct errors and try again."
      redirect_to user_path(current_user)
    end
  end


  def destroy
    if current_user.destroy
      flash[:success] = "User destroyed!"
      redirect_to root_path
    else
      flash[:danger] = "Could not destroy user!"
      redirect :back
    end
  end


  private

  def user_params
    # TODO: update necessary params based on backend
    params.require(:user).permit(:email, :password, :password_confirmation,
                                 :profile_attributes => [:user_id, :first_name, :last_name, :pokemon_id, :pokemon_type_id, :username,
                                                         :photo_attributes => [:photo]])
  end

  def get_user
    User.find(params[:id])
  end
  helper_method :get_user

end
