class IllustrationPublication < ApplicationRecord
  # keep track of history (changes)
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :illustration
  belongs_to :publication

  #################
  ## VALIDATION ##
  #################
end
