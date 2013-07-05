class CreateTranscriptionsTable < ActiveRecord::Migration
  def self.up
    create_table :transcriptions do |t|
    end
  end

  def self.down
    drop_table :transcriptions
  end
end