class <%= @migration_name.camelize %> < ActiveRecord::Migration
  def self.up
    <% new_columns.each do |name, type| %>
      add_column :transcriptions, :<%= name %>, :<%= type.to_s %>
    <% end %>
  end

  def self.down
    <% new_columns.each do |name, type| %>
      remove_column :transcriptions, :<%= name %>, :<%= type.to_s %>
    <% end %>
  end
end