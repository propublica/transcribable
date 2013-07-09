class Transcription < ActiveRecord::Base
  belongs_to :user
  belongs_to :<%= @table.singularize %>
end
