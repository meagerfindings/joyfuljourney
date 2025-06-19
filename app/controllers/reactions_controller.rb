# frozen_string_literal: true

class ReactionsController < ApplicationController
  before_action :require_login
  before_action :set_post

  def create
    @reaction = @post.reactions.find_by(user: current_user)
    
    if @reaction
      # Update existing reaction
      old_reaction_type = @reaction.reaction_type
      @reaction.update(reaction_type: reaction_params[:reaction_type])
      
      # Track activity for updated reaction
      ActivityService.track_reaction_activity(@reaction)
      
      flash[:notice] = 'Reaction updated!'
    else
      # Create new reaction
      @reaction = @post.reactions.build(reaction_params)
      @reaction.user = current_user
      
      if @reaction.save
        # Track activity
        ActivityService.track_reaction_activity(@reaction)
        
        # Send notification to post author
        NotificationService.create_reaction_notification(@reaction)
        
        flash[:notice] = 'Reaction added!'
      else
        flash[:alert] = "Error adding reaction: #{@reaction.errors.full_messages.join(', ')}"
      end
    end
    
    redirect_back(fallback_location: @post)
  end

  def destroy
    @reaction = @post.reactions.find_by(user: current_user)
    
    if @reaction
      @reaction.destroy
      flash[:notice] = 'Reaction removed!'
    else
      flash[:alert] = 'Reaction not found.'
    end
    
    redirect_back(fallback_location: @post)
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def reaction_params
    params.require(:reaction).permit(:reaction_type)
  end

  def require_login
    return if current_user

    redirect_to login_path, alert: 'Please log in to react to posts.'
  end
end