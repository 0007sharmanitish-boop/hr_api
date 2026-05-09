class Api::V1::Users::SessionsController < Devise::SessionsController
  include UserPayload

  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: { data: { user: user_payload(resource) } }, status: :ok
  end

  def respond_to_on_destroy(*)
    head :no_content
  end
end
