class CreateTranscriptionsTable < ActiveRecord::Migration
  def self.up
    create_table :transcriptions do |t|
      <% transcribable_attrs.each do |name, type| %>
        t.<%= type.to_s %> :<%= name %>
      <% end %>
      t.integer :<%= @table.singularize %>_id
      t.string :user_id # by default, this will be a UUID stored by cookie
    end
  end

  def self.down
    drop_table :transcriptions
  end
end