class IllustrationIssue < ApplicationRecord
  # keep track of history (changes)
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :illustration
  belongs_to :issue

  #################
  ## VALIDATION ##
  #################
end
