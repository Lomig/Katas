# frozen_string_literal: true

# Friend or Foe?
def friend(friends)
  friends.each_with_object([]) { |friend, a| a << friend if friend.length == 4 }
end
