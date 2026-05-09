module UserPayload
  extend ActiveSupport::Concern

  private

  def user_payload(user)
    { id: user.id, email: user.email }
  end
end
