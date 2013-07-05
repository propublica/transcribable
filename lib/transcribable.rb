# adds to Filing
module Transcribable
  extend ActiveSupport::Concern

  included do
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

    def verification_threshhold(lvl = 2)
      lvl
    end
  end

  # override this to create your own 
  # verifier
  module LocalInstanceMethods
    def verify!
    end
  end
end

ActiveRecord::Base.send :include, Transcribable
