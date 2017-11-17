class Ability
  include CanCan::Ability
  # The first argument to `can` is the action you are giving the user
  # permission to do.
  # If you pass :manage it will apply to every action. Other common actions
  # here are :read, :create, :update and :destroy.
  # You will usually be working with these four actions.
  # These aren't the same as the 7 RESTful actions in Rails!
  # CanCanCan automatically adds some convenient aliases for mapping the controller actions.
  # https://github.com/CanCanCommunity/cancancan/wiki/Action-Aliases
  #  `alias_action :index, :show, :to => :read`
  #  `alias_action :new, :to => :create`
  #  `alias_action :edit, :to => :update`
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

  def initialize(user)
    if user.present?
      can :manage, User, id: user.id
      can :manage, Event, creator_id: user.id
      can :manage, Team, creator_id: user.id
      can :create, :all
      cannot :create, User

      if user.admin?
        can :manage, :all
      end
    end
  end
end
