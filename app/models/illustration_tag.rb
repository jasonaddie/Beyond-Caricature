# == Schema Information
#
# Table name: illustration_tags
#
#  id              :integer          not null, primary key
#  illustration_id :integer
#  tag_id          :integer
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
