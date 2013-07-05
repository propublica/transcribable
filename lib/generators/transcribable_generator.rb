require "rails/generators"
require "rails/generators/active_record"
#require "../../transcribable"

class TranscribableGenerator < ActiveRecord::Generators::Base
  desc "Generates transcriptions table"
  # to get around AR Generators requiring a NAME param
  argument :name, type: :string, default: 'random_name'

  source_root File.expand_path('../templates', __FILE__)

  def transcribable_attrs
    transcribable_attrs = []
    ActiveRecord::Base.connection.tables.reject {|t| t == "schema_migrations" }.each do |table|
      klass = Kernel.const_get(table.classify)
      klass.column_names.each do |col|
        if klass.transcribable?(col)
          transcribable_attrs << {col => Filing.columns_hash[col].type}
        end
      end
    end
    transcribable_attrs
  end

  # Copies the migration template to db/migrate.
  def copy_file
    migration_template 'migration.rb', 'db/migrate/create_transcribable_table.rb'
  end
end