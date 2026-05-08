require 'rails_helper'

RSpec.describe "Employees API", type: :request do
  let(:valid_attributes) { attributes_for(:employee) }
  let!(:employee) { create(:employee) }

  describe "GET /api/v1/employees" do
    it "returns a successful response" do
      get "/api/v1/employees"
      expect(response).to have_http_status(:ok)
      expect(json_body["data"].size).to eq(1)
    end
  end

  describe "POST /api/v1/employees" do
    context "with valid parameters" do
      it "creates a new Employee" do
        expect {
          post "/api/v1/employees", params: { employee: valid_attributes }
        }.to change(Employee, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    
    context "with invalid parameters" do
      it "does not create an Employee and returns error" do
        expect {
          post "/api/v1/employees", params: { employee: { email: "" } }
        }.not_to change(Employee, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "with duplicate data" do
      it "fails when email already exists" do
        expect {
          post "/api/v1/employees", params: { 
            employee: valid_attributes.merge(email: employee.email) 
          }
        }.not_to change(Employee, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_body["errors"]).to include("Email has already been taken")
      end

      it "fails when employee_code already exists" do
        expect {
          post "/api/v1/employees", params: { 
            employee: valid_attributes.merge(employee_code: employee.employee_code) 
          }
        }.not_to change(Employee, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_body["errors"]).to include("Employee code has already been taken")
      end
    end
  end
end
