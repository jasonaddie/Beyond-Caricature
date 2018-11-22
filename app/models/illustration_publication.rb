# == Schema Information
#
# Table name: illustration_publications
#
#  id                :integer          not null, primary key
#  illustration_id   :integer
#  publication_id    :integer
#  page_number_start :integer
#  page_number_end   :integer
#  is_public         :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

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
