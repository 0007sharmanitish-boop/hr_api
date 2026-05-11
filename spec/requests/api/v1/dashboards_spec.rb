require "rails_helper"

RSpec.describe "Dashboard API", type: :request do
  before { Rails.cache.clear }

  describe "GET /api/v1/dashboards" do
    it "returns aggregate statistics for all employees" do
      create(:employee, country: "US", department: "Engineering", salary: 80_000.00)
      create(:employee, country: "US", department: "Engineering", salary: 100_000.00)
      create(:employee, country: "CA", department: "Sales", salary: 60_000.00)

      get "/api/v1/dashboards"

      expect(response).to have_http_status(:ok)
      data = json_body["data"]
      expect(data["total_employees"]).to eq(3)
      expect(data["total_departments"]).to eq(2)
      expect(data["total_countries"]).to eq(2)
      expect(BigDecimal(data["average_salary"]).round(2)).to eq(BigDecimal("80000.00"))
    end

    it "returns zeros and nil average when there are no employees" do
      get "/api/v1/dashboards"

      expect(response).to have_http_status(:ok)
      data = json_body["data"]
      expect(data["total_employees"]).to eq(0)
      expect(data["total_departments"]).to eq(0)
      expect(data["total_countries"]).to eq(0)
      expect(data["average_salary"]).to be_nil
    end
  end
end
