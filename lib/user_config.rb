module UserConfig
  USER_DATA_TO_BE_SESSIONED = %w{user_id login email gender age full_name}
  def get_user_data_to_be_sessioned(new_user)
    new_user_sessioned_data = { :user_id => new_user.user_id,
                                :login => new_user.login,
                                :email => new_user.email,
                                :gender => new_user.gender,
                                :age => new_user.age,
                                :full_name => new_user.full_name,
                                :user_role => new_user.user_role}
  end
end
