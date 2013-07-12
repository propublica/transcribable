class TranscriptionsController < ActionController::Base
  layout "simple_frame"

  def new
    @<%= @table.singularize %> = <%= @table.classify %>.assign!(current_user)
    # if we're able to assign a filing
    # that the user hasn't done and hasn't been verified
    if @<%= @table.singularize %>.nil?
      redirect_to(root_path, :alert => "You've transcribed all of the filings. Thank you.")
      return
    end
    @transcription = Transcription.new
    @transcription.<%= @table.singularize %> = @<%= @table.singularize %>
  end

  def create
    @<%= @table.singularize %> = <%= @table.classify %>.find(params[:<%= @table.singularize %>_id])
    @transcription = Transcription.new(transcription_params)
    @transcription.<%= @table.singularize %> = @<%= @table.singularize %>
    @transcription.user_id = current_user

    if @transcription.save
      @<%= @table.singularize %>.verify!
      redirect_to(new_transcription_path, :notice => "Thank you for transcribing. Here's another filing.")
    else
      render :action => "new", :alert => "Something went wrong. Please try again."
    end
  end

  private

  # By default, the current user is stored in a cookie.
  # For rigorous purposes, please consider implementing a
  # real login system.
  def current_user
    cookie_name = "#{Rails.application.engine_name}_transcriable_user_id".to_sym
    return cookies[cookie_name] if cookies[cookie_name]
    cookies[cookie_name] = {
      :value   => UUID.new.generate(:compact),
      :expires => 5.years.from_now
    }
    cookies[cookie_name]
  end

  def transcription_params
    params.require(:transcription).permit(<%= transcribable_attrs.keys.map{|q| ":#{q}" }.join(",") %>)
  end  
end