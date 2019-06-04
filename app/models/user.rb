# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role                   :integer          default("uploader")
#  name                   :string
#  deleted_at             :datetime
#

class User < ApplicationRecord
  include FullTextSearch

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable, :registerable
  devise :database_authenticatable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable

  # define user roles
  enum role: [:uploader, :editor, :admin, :superadmin]

  #################
  ## HISTORY TRACKING ##
  #################
  has_paper_trail

  #################
  ## VALIDATION ##
  #################
  validates :name, presence: true
  validates :email, presence: true
  validates :encrypted_password, presence: true
  validates :role, presence: true


  #################
  ## SCOPES ##
  #################
  # search query for the list admin page
  # - name
  # - email
  def self.admin_search(q)
    ids = []

    users = self.where(build_full_text_search_sql(%w(name email)),
            q
          ).pluck(:id)

    if users.present?
      ids << users
    end

    ids = ids.flatten.uniq

    if ids.present?
      self.where(id: ids).distinct
    else
      self.none
    end
  end

  def self.roles_for_select
    options = {}
    roles.each do |key, value|
      options[I18n.t("activerecord.attributes.#{model_name.i18n_key}.roles.#{key}")] = value
    end
    return options
  end


  #################
  ## METHODS ##
  #################
  # instead of deleting, indicate the user requested a delete & timestamp it
  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  # ensure user account is active
  def active_for_authentication?
    super && !deleted_at
  end

  # provide a custom message for a deleted account
  def inactive_message
    !deleted_at ? super : :deleted_account
  end

  # show the translated name of the enum value
  def role_formatted
    self.role? ? I18n.t("activerecord.attributes.#{model_name.i18n_key}.roles.#{role}") : nil
  end


  #################
  ## RAILS ADMIN CONFIGURATION ##
  #################
  rails_admin do
    # add to a navigration group
    navigation_label I18n.t('navigation_groups.admin')

    # control the order in the admin nav menu
    weight 400

    # configuration
    configure :role do
      # enum User.roles_for_select
      pretty_value do
        bindings[:object].role_formatted
      end
    end

    configure :updated_at do
      # remove the time zone
      pretty_value do
        value.nil? ? nil : value.strftime("%Y-%m-%d %H:%M")
      end
    end

    # list page
    list do
      search_by :admin_search

      field :name
      field :email
      field :role
      field :deleted_at
      field :current_sign_in_at
      field :updated_at
    end

    # show page
    show do
      field :name
      field :email
      field :role
      field :deleted_at
      field :created_at
      field :updated_at
      field :sign_in_count
      field :current_sign_in_at
      field :current_sign_in_ip
      field :last_sign_in_at
      field :last_sign_in_ip
      field :remember_created_at
      field :reset_password_sent_at
      field :confirmation_token
      field :confirmation_sent_at
      field :confirmed_at
    end

    # form
    edit do
      field :name
      field :email
      field :password
      field :password_confirmation
      field :role
      field :deleted_at do
        help I18n.t('admin.help.soft_delete')
      end
    end
  end

end
