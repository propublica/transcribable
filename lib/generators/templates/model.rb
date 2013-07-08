class Transcription < ActiveRecord::Base
  belongs_to :user
  belongs_to :<%= @table.singularize %>

  after_save :suggest_another_filing

  def suggest_another_filing
    User.where(["suggested_filing_id = ?", self.filing.id]).each{|u| u.get_suggested_filing;}
  end
end
