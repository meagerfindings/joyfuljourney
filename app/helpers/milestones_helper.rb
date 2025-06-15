module MilestonesHelper
  def milestone_options_for_type(type, user)
    case type
    when 'User'
      return [] unless user.family
      user.family.users.map { |u| [u.name, u.id] }
    when 'Family'
      return [] unless user.family
      [[user.family.name, user.family.id]]
    when 'Post'
      return [] unless user.family
      user.family.posts.map { |p| [p.title, p.id] }
    else
      []
    end
  end
end
