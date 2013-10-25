# adds to Filing
require 'uuid'

module Transcribable
  require 'transcribable/railtie'
  extend ActiveSupport::Concern

  mattr_accessor :table
  mattr_accessor :transcribable_attrs

  included do
    set_verification_threshhold
  end

  def self.table
    # transcribable_attrs() "discovers" the columns
    # and table. run it if we don't have a table yet.
    transcribable_attrs if @@table.nil?
    @@table
  end

  # creates a hash like...
  # {'buyer' => :string, 'amount' => :integer}
  def self.transcribable_attrs
    return @@transcribable_attrs if @@transcribable_attrs

    @@transcribable_attrs = {}
    ActiveRecord::Base.connection.tables.reject {|t| t == "schema_migrations" }.each do |table|
      klass = Kernel.const_get(table.classify)
      klass.column_names.each do |col|
        if klass.transcribable?(col)
          @@table = table
          @@transcribable_attrs[col] = klass.columns_hash[col].type
        end
      end
    end

    @@transcribable_attrs
  end

  # If we've migrated our master table,
  # and need transcriptions to catch up.
  # Returns a hash like transcribable_attrs
  def self.new_columns
    return nil unless defined?(Transcription)

    cols = Transcribable.transcribable_attrs.keys - Transcription.columns_hash.keys
    cols.reduce(Hash.new(0)) do |memo, it|
      memo[it] = Kernel.const_get(@@table.classify).columns_hash[it].type
      memo
    end
  end

  module ClassMethods
    def transcribable(*args)
      args.each do |k|
        self.columns_hash[k.to_s].instance_variable_set("@transcribable", true)
      end
      include Transcribable::LocalInstanceMethods
    end

    def transcribable?(_attr)
      self.columns_hash[_attr].instance_variable_get("@transcribable")
    end

    def skip_verification(*args)
      @@skip_verification = args
    end

    def skipped_attrs
      @@skip_verification
    end

    # The number over which people must agree
    # on every attribute to verify a transcription
    def set_verification_threshhold(lvl = 1)
      @@verification_threshhold = lvl
    end

    def verification_threshhold
      @@verification_threshhold
    end

    # Attributes that are potential reasons
    # to skip a transcription. If enough people
    # agree to skip, the filing will be marked transcribed.
    def skip_transcription(*args)
      @@skippable = args
    end

    # Override this to write your own assigner
    # By default, it picks a random filing that 
    # a user has not transcribed. If there's nothing left
    # for that user to do, it returns nil. This will get slower
    # the more transcriptions you have, so it'll be a good idea
    # to index the filing_id (or whatever master table foreign key)
    # column in your transcriptions table.
    def assign!(user_id)
      user_transcribed_filings = Transcription.where(:user_id => user_id).map {|q| q["#{self.table_name.downcase.singularize}_id".to_sym] }.uniq
      filings = self.where(:verified => [nil, false])
      if user_transcribed_filings.length > 0
        filings = filings.where("id NOT IN (?)", user_transcribed_filings)
      end
      pick    = rand(filings.length - 1)
      filings.length > 0 ? filings[pick] : nil
    end
  end

  module LocalInstanceMethods
    # Override this to create your own verifier.
    # By default, all "transcribable" attributes
    # need to be agreed on by @@verification_threshhold people.
    def verify!
      chosen = {}
      
      attributes  = Transcribable.transcribable_attrs.keys.reject do |k|
        self.class.skipped_attrs.include?(k.to_sym)
      end

      Rails.logger.info("== Verifying #{attributes.join(", ")}")

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
          if answer_ct > self.class.verification_threshhold
            chosen[attribute] = answers.each.max_by {|k,v| v}.first
          end
        end
      end

      if chosen.keys.length == attributes.length
        attributes.each do |a|
          self[a] = chosen[a]
        end
        self.verified = true
        self.save
        Rails.logger.info("== Verified #{self.url}")
      else
        Rails.logger.info("== Not verified: #{self.url}")
      end
    end

    def dc_slug
      url.split(/\//)[-1]
    end
  end
end

ActiveRecord::Base.send :include, Transcribable
