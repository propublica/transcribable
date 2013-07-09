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

  def copy_files
    # Copies the migration template to db/migrate.
    migration_template 'migration.rb', 'db/migrate/create_transcriptions_table.rb'
    
    # controller
    template 'controller.rb', 'app/controllers/transcriptions_controller.rb'
    
    # model
    template 'model.rb', 'app/models/transcription.rb'

    # views
    template 'views/_form.html.erb', 'app/views/transcriptions/_form.html.erb'
    template 'views/edit.html.erb', 'app/views/transcriptions/edit.html.erb'
    template 'views/new.html.erb', 'app/views/transcriptions/new.html.erb'
  
    # config
    template 'config/documentcloud.yml', 'config/documentcloud.yml'

    # routes
    route "resources :transcriptions, :only => [:new, :create, :update]"
  end
end