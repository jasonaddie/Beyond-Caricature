class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    shared_resources = [
        Illustration, IllustrationIssue, IllustrationPublication, IllustrationTag, Illustrator,
        Issue, Publication, PublicationEditor, PublicationLanguage, Tag
    ]
    news_resources = [
        Highlight, News, Research
    ]

    # abilities are written from least restrictive access to most restrictive access

    can :read, shared_resources

    return unless user
    can :access, :rails_admin
    can :access, :ckeditor
    can :read, :dashboard
    # cannot :history, :all

    can :manage, shared_resources
    can [:read, :create, :destroy], Ckeditor::Picture
    can [:read, :create, :destroy], Ckeditor::AttachmentFile
    return if user.uploader?

    # can :history, :all
    can :manage, news_resources
    return if user.editor?

    can :manage, User
    return if user.admin?

    can :manage, :all
    return if user.superadmin?

  end
end
