class TranscriptionsController < ActionController::Base
  layout "simple_frame"

  def new
    @<%= @table.singularize %> = <%= @table.classify %>.find(params[:<%= @table.singularize %>_id])
    @transcription = Transcription.new
    @transcription.<%= @table.singularize %> = @<%= @table.singularize %>

     respond_to do |format|
      if @transcription.filing.verified?
        format.html { redirect_to gimme_filings_path }
      elsif @transcription.<%= @table.singularize %>.transcriptions.map(&:user_id).include?(current_user)
        format.html { redirect_to( gimme_filings_path) }
      else
        format.html
      end
    end   
  end

  def create
    @<%= @table.singularize %> = <%= @table.classify %>.find(params[:<%= @table.singularize %>_id])
    @transcription = Transcription.new(transcription_params)
    @transcription.<%= @table.singularize %> = @<%= @table.singularize %>
    @transcription.user_id = current_user

    respond_to do |format|
      if @transcription.save
        @<%= @table.singularize %>.verify!
        format.html { redirect_to(gimme_filings_path, :notice => "Thank you for transcribing. Here's another filing.") }
      else
        format.html { render :action => "new", :alert => "Something went wrong. Please try again." }
      end
    end
  end

  private

  # By default, the current user is stored in a cookie.
  # For rigorous purposes, please consider implementing a
  # real login system.
  def current_user
    cookies[:user_id] ? cookies[:user_id] : UUID.new.generate(:compact)
  end

  def transcription_params
    params.require(:transcription).permit(<%= transcribable_attrs.keys.map{|q| ":#{q}" }.join(",") %>)
  end  
end