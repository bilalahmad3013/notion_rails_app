class UserController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
    @user.name = ''
  end

  def create
    @user = User.new(user_params)

    if @user.save     
      redirect_to root_path, notice: 'Signup successful. You can now log in.'
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :new
    end
  end

  def destroy
    user = User.find_by(id: params[:id])
  
    if user.present? && user.destroy
      redirect_to new_user_path, notice: 'Account deleted.'
    else
      flash[:alert] = 'Failed to delete account.'
      redirect_to root_path
    end  
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :name, :password)
  end
end
