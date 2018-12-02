# == Schema Information
#
# Table name: illustration_tags
#
#  id              :bigint(8)        not null, primary key
#  illustration_id :bigint(8)
#  tag_id          :bigint(8)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class IllustrationTag < ApplicationRecord
  #################
  ## HISTORY TRACKING ##
  #################
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
