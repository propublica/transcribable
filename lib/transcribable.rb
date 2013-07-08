# adds to Filing
module Transcribable
  require 'transcribable/railtie' if defined?(Rails)
  extend ActiveSupport::Concern

  mattr_accessor :table
  mattr_accessor :transcribable_attrs

  included do
    set_verification_threshhold
  end

  def self.table=(table)
    @@table = table
  end

  def self.table
    @@table
  end

  # This expects a hash like
  # {'buyer' => :string, 'amount' => :integer}
  def self.transcribable_attrs=(attrs)
    @@transcribable_attrs = attrs
  end

  def self.transcribable_attrs
    @@transcribable_attrs
  end

  # def transcribable_attrs
  #   transcribable_attrs = {}
  #   ActiveRecord::Base.connection.tables.reject {|t| t == "schema_migrations" }.each do |table|
  #     klass = Kernel.const_get(table.classify)
  #     klass.column_names.each do |col|
  #       if klass.transcribable?(col)
  #         @table = table
  #         transcribable_attrs[col] = Filing.columns_hash[col].type
  #       end
  #     end
  #   end
  #   transcribable_attrs
  # end


  module ClassMethods
    def transcribable(*args)
      Transcribable.table = self.to_s.downcase.pluralize
      Transcribable.transcribable_attrs = args.reduce(Hash.new(0)) do |memo, it|
        memo[self.columns_hash[it.to_s].name] = self.columns_hash[it.to_s].type
        memo
      end
    end

    def transcribable?(_attr)
      Transcribable.transcribable_attrs.keys.include?(_attr.to_s)
    end

    def set_verification_threshhold(lvl = 2)
      @@verification_threshhold = lvl
    end

    # Attributes that are potential reasons
    # to skip a transcription. If enough people
    # agree to skip, the filing will be marked transcribed.
    def skip_transcription(*args)
      @@skippable = args
    end

    # Override this to write your own assigner
    # By default, it picks a random filing
    def assign!
      offset = rand(self.count)
      filing = self.first(:offset => offset)
    end
  end

  module LocalInstanceMethods
    # Override this to create your own verifier.
    # By default, all "transcribable" attributes
    # need to be agreed on by @@verification_threshhold people.
    def verify!
      chosen = {}
      
      attributes  = self.class.columns_hash.select do |q| 
        q.instance_variable_get("@transcribable") 
      end.keys

      aggregate = transcriptions.reduce({}) do |memo, it|
        attributes.each do |attribute|
          memo[attribute] = memo[attribute] ? memo[attribute] : {}
          memo[attribute][it.instance_values['attributes'][attribute].to_s.upcase] = memo[attribute][it.instance_values['attributes'][attribute].to_s.upcase] ? 
          memo[attribute][it.instance_values['attributes'][attribute].to_s.upcase] + 1 : 1
        end

        memo
      end

      aggregate.each do |attribute, answers|
        answers.each do |answer, answer_ct|
          if answer_ct > @@verification_threshhold
            chosen[attribute] = answers.each.max_by {|k,v| v}.first
          end
        end
      end

      if chosen.keys.length == attributes.length
        attributes.each do |a|
          # TODO: Account for numeric attributes
          self[a] = chosen[a]
        end
        self.verified = true
        self.save
      end
    end

    def dc_slug
      url.split(/\//)[-1]
    end
  end
end

ActiveRecord::Base.send :include, Transcribable
