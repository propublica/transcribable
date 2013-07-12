require "rails/generators"
require "rails/generators/active_record"
require "transcribable"


class TranscribableGenerator < ActiveRecord::Generators::Base
  include Transcribable

  desc "Generates transcriptions table"
  # to get around AR Generators requiring a NAME param
  argument :name, type: :string, default: 'random_name'

  source_root File.expand_path('../templates', __FILE__)

  def table
    @table = Transcribable.table
  end

  def transcribable_attrs
    Transcribable.transcribable_attrs
  end

  def new_columns
    Transcribable.new_columns
  end

  def copy_files
    # Copies the migration template to db/migrate.
    if Transcribable.new_columns.length > 0
      @migration_name = "add_#{Transcribable.new_columns.keys.join("_and_")}_to_transcriptions"
      migration_template 'migration_add_columns.rb', "db/migrate/#{@migration_name}.rb"
    elsif !ActiveRecord::Base.connection.tables.include?("transcriptions")
      migration_template 'migration.rb', 'db/migrate/create_transcriptions_table.rb'
    end
    
    # controller
    template 'controller.rb', 'app/controllers/transcriptions_controller.rb'
    
    # model
    template 'model.rb', 'app/models/transcription.rb'

    # views
    template 'views/layouts/simple_frame.html.erb', 'app/views/layouts/simple_frame.html.erb'
    template 'views/_form.html.erb', 'app/views/transcriptions/_form.html.erb'
    template 'views/edit.html.erb', 'app/views/transcriptions/edit.html.erb'
    template 'views/new.html.erb', 'app/views/transcriptions/new.html.erb'

    # assets
    template 'assets/stylesheets/simple_frame.css', 'app/assets/stylesheets/simple_frame.css'
  
    # config
    template 'config/documentcloud.yml', 'config/documentcloud.yml'

    # routes
    route "resources :transcriptions, :only => [:new, :create]"
    route "resources :#{@table.to_sym}, :only => [:index, :show]"
    route "root :to => \"#{@table}#index\""
  end
end