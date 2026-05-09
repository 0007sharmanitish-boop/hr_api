class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  include UserPayload

  respond_to :json

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def respond_with(resource, _opts = {})
    unless resource.persisted?
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_content
      return
    end

    render json: { data: { user: user_payload(resource) } }, status: :created
  end
end
