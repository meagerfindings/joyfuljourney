class FamilyInvitationsController < ApplicationController
  before_action :require_login, except: [:show, :accept_form, :accept, :decline]
  before_action :set_family, only: [:new, :create, :index]
  before_action :require_family_admin, only: [:new, :create, :index, :destroy]
  before_action :set_invitation_by_token, only: [:show, :accept_form, :accept, :decline]
  before_action :set_invitation, only: [:destroy]
  before_action :check_invitation_validity, only: [:accept_form, :accept, :decline]

  def index
    @pending_invitations = @family.pending_invitations.includes(:inviter)
    @all_invitations = @family.family_invitations.includes(:inviter).order(created_at: :desc)
  end

  def new
    @invitation = @family.family_invitations.build
  end

  def create
    @invitation = @family.family_invitations.build(invitation_params)
    @invitation.inviter = current_user

    if @invitation.save
      FamilyInvitationMailer.invitation_email(@invitation).deliver_now
      flash[:success] = "Invitation sent to #{@invitation.email}!"
      redirect_to family_family_invitations_path(@family)
    else
      render :new, status: :unprocessable_entity
    end
  rescue StandardError => e
    flash[:error] = "Failed to send invitation: #{e.message}"
    render :new, status: :unprocessable_entity
  end

  def show
    # Public route for viewing invitation via token
    # This is where users land when they click the email link
    if @invitation.nil?
      render :invalid_invitation and return
    end
    
    if @invitation.expired?
      @invitation.expire!
      render :expired and return
    end
    
    unless @invitation.pending?
      render :already_processed and return
    end
    
    # Check if user is already registered with this email
    @existing_user = User.find_by(username: @invitation.email) # Assuming email is used as username
    
    if @existing_user
      # User exists, just need to join family
      render :existing_user
    else
      # New user needs to register
      @user = User.new(
        first_name: '',
        last_name: '',
        username: @invitation.email,
        claimed: true
      )
      render :new_user_registration
    end
  end

  def accept_form
    # GET route for accepting invitation - shows form for user registration if needed
    redirect_to public_invitation_path(@invitation.token)
  end

  def accept
    if params[:user].present?
      # New user registration flow
      @user = User.new(user_params)
      @user.username = @invitation.email
      @user.claimed = true
      @user.family = @invitation.family
      
      if @user.save
        @invitation.accept!
        session[:user_id] = @user.id
        flash[:success] = "Welcome to #{@invitation.family_name}! Your account has been created."
        redirect_to root_path
      else
        render :new_user_registration, status: :unprocessable_entity
      end
    elsif logged_in?
      # Existing user joining family
      if current_user.family.present?
        flash[:error] = "You're already part of a family. Please contact support if you need to switch families."
        redirect_to root_path and return
      end
      
      current_user.update!(family: @invitation.family)
      @invitation.accept!
      flash[:success] = "Welcome to #{@invitation.family_name}!"
      redirect_to root_path
    else
      # Existing user needs to log in first
      session[:invitation_token] = @invitation.token
      flash[:notice] = "Please log in to accept this family invitation."
      redirect_to login_path
    end
  end

  def decline
    @invitation.decline!
    flash[:notice] = "You have declined the invitation to join #{@invitation.family_name}."
    redirect_to root_path
  end

  def destroy
    @invitation = current_user.sent_family_invitations.find(params[:id])
    @invitation.cancel!
    flash[:success] = "Invitation cancelled."
    redirect_to family_family_invitations_path(@invitation.family)
  end

  private

  def set_family
    @family = current_user.family
    redirect_to root_path, alert: "You must be part of a family to manage invitations." unless @family
  end

  def set_invitation_by_token
    token = params[:token] || params[:id]
    @invitation = FamilyInvitation.find_by(token: token)
  end

  def set_invitation
    @invitation = FamilyInvitation.find(params[:id])
  end

  def require_family_admin
    unless current_user.admin? || current_user.manager?
      flash[:error] = "Only family managers and admins can send invitations."
      redirect_to root_path
    end
  end

  def check_invitation_validity
    return if @invitation&.pending? && !@invitation.expired?
    
    if @invitation.nil?
      render :invalid_invitation
    elsif @invitation.expired?
      @invitation.expire!
      render :expired
    else
      render :already_processed
    end
  end

  def invitation_params
    params.require(:family_invitation).permit(:email, :message)
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :middle_name, :nickname, :birthdate, :password, :password_confirmation)
  end
end