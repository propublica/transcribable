require "rails/generators"
require "rails/generators/active_record"


class TranscribableGenerator < ActiveRecord::Generators::Base
  desc "Generates transcriptions table"
  # to get around AR Generators requiring a NAME param
  argument :name, type: :string, default: 'random_name'

  source_root File.expand_path('../templates', __FILE__)

  def transcribable_attrs
    transcribable_attrs = {}
    ActiveRecord::Base.connection.tables.reject {|t| t == "schema_migrations" }.each do |table|
      klass = Kernel.const_get(table.classify)
      klass.column_names.each do |col|
        if klass.transcribable?(col)
          @table = table
          transcribable_attrs[col] = Filing.columns_hash[col].type
        end
      end
    end
    transcribable_attrs
  end    

  def copy_files
    # Copies the migration template to db/migrate.
    migration_template 'migration.rb', 'db/migrate/create_transcribable_table.rb'
    
    # controller
    template 'controller.rb', 'app/controllers/transcriptions_controller.rb'
    
    # model
    template 'model.rb', 'app/models/transcription.rb'

    #views
    template 'views/_form.html.erb', 'app/views/transcriptions/_form.html.erb'
    template 'views/edit.html.erb', 'app/views/transcriptions/edit.html.erb'
    template 'views/new.html.erb', 'app/views/transcriptions/new.html.erb'
  
    route "resources :transcriptions, :only => [:new, :create, :update]"
  end
end