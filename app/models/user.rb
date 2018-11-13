class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable

  # keep track of history (changes)
  has_paper_trail

  # define user roles
  enum role: [:uploader, :editor, :admin, :superadmin]

  #################
  ## METHODS ##
  #################

end
