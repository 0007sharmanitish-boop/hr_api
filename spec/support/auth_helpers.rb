module AuthHelpers
  # Performs login and returns headers suitable for authenticated API requests.
  def auth_headers_for(user, password: "password123")
    post "/api/v1/auth/login",
         params: { user: { email: user.email, password: password } },
         as: :json
    { "Authorization" => response.headers["Authorization"] }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
