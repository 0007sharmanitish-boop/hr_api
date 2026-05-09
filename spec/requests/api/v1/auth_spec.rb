require "rails_helper"

RSpec.describe "Authentication API", type: :request do
  describe "POST /api/v1/auth/sign_up" do
    it "creates a user and returns a JWT and user payload" do
      attrs = {
        email: "new.user@example.com",
        password: "password123",
        password_confirmation: "password123"
      }

      expect {
        post "/api/v1/auth/sign_up", params: { user: attrs }, as: :json
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.headers["Authorization"]).to start_with("Bearer ")
      expect(json_body["data"]["user"]["email"]).to eq(attrs[:email])
    end

    it "returns validation errors when email is taken" do
      create(:user, email: "taken@example.com")

      post "/api/v1/auth/sign_up", params: {
        user: {
          email: "taken@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json_body["errors"]).to be_present
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user) }

    it "returns a JWT when credentials are valid" do
      post "/api/v1/auth/login",
           params: { user: { email: user.email, password: "password123" } },
           as: :json

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to start_with("Bearer ")
      expect(json_body["data"]["user"]["email"]).to eq(user.email)
    end

    it "returns unauthorized when password is wrong" do
      post "/api/v1/auth/login",
           params: { user: { email: user.email, password: "wrong-password" } },
           as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(json_body["errors"]).to be_present
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    let!(:user) { create(:user) }

    it "returns no content when token is valid" do
      headers = auth_headers_for(user)

      delete "/api/v1/auth/logout", headers: headers

      expect(response).to have_http_status(:no_content)
    end
  end

  describe "protected routes" do
    let!(:user) { create(:user) }

    it "rejects employee index without Authorization" do
      get "/api/v1/employees"
      expect(response).to have_http_status(:unauthorized)
    end

    it "allows employee index with valid JWT" do
      headers = auth_headers_for(user)

      get "/api/v1/employees", headers: headers

      expect(response).to have_http_status(:ok)
    end
  end
end
