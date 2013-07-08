# adds to Filing
module Transcribable
  extend ActiveSupport::Concern

  included do
    set_verification_threshhold
  end

  module ClassMethods
    def transcribable(*args)
      args.each do |k|
        self.columns_hash[k.to_s].instance_variable_set("@transcribable", true)
      end
    end

    def transcribable?(_attr)
      self.columns_hash[_attr].instance_variable_get("@transcribable")
    end

    def set_verification_threshhold(lvl = 2)
      @@verification_threshhold = lvl
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
    end

    def verified?
    end
  end
end

ActiveRecord::Base.send :include, Transcribable
