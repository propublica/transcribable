class Filing < ActiveRecord::Base
  transcribable :buyer, :amount, :notes
  skip_verification :notes
  has_many :transcriptions
  set_verification_threshhold 4
end