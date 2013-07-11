class Transcription < ActiveRecord::Base
  belongs_to :user
  belongs_to :<%= @table.singularize %>

  Transcribable.transcribable_attrs.select {|k,v| [:integer, :float, :decimal].include?(v) }.keys.each do |k|
    define_method("#{k}=") do |val|
      write_attribute k.to_sym, val.to_s.gsub(/[^0-9\.]/,"").to_f
    end
  end
end