class IllustrationTag < ApplicationRecord
  # keep track of history (changes)
  has_paper_trail

  #################
  ## ASSOCIATIONS ##
  #################
  belongs_to :illustration
  belongs_to :tag

  #################
  ## VALIDATION ##
  #################
  # validates :illustration_id, :presence => true
  # validates :tag_id, :presence => true
  # validates_uniqueness_of :tag_id, scope: :illustration_id

end
