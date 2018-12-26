# == Schema Information
#
# Table name: thumbs
#
#  id         :bigint(8)        not null, primary key
#  uid        :string
#  job        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Thumb < ApplicationRecord

  #################
  ## THIS MODEL IS USED FOR
  ## CACHING DIFFERENT IMAGE
  ## SIZES THROUGH DRAGONFLY
  ## THIS MODEL IS USED IN THE
  ## dragonfly.rb INITIALIZER FILE
  #################


end
