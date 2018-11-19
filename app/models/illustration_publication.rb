class IllustrationPublication < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
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
