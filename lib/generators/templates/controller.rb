class TranscriptionsController < ActionController::Base
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

  def edit
    @transcription = Transcription.find(params[:id])
  end

  def create
    @<%= @table.singularize %> = <%= @table.classify %>.find(params[:<%= @table.singularize %>_id])
    @transcription = Transcription.new(params[:transcription])
    @transcription.<%= @table.singularize %> = @<%= @table.singularize %>
    @transcription.user = current_user

    respond_to do |format|
      if @transcription.save
        @<%= @table.singularize %>.verify!
        format.html { redirect_to @<%= @table.singularize %> }
        format.json { render :json => @transcription }
      else
        format.html { render :action => "new" }
      end
    end    
  end

  def update
    @transcription = Transcription.find(params[:id])
    new_transcription = params[:transcription]

    respond_to do |format|
      if @transcription.update_attributes(new_transcription)
        @transcription.<%= @table.singularize %>.verify!
        format.html { redirect_to @transcription.<%= @table.singularize %> }
        format.json { render :json => { :transcription => @transcription.attributes }}
      else
        format.html { render :action => "edit" }
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
end