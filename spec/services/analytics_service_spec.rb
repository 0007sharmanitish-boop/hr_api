require "rails_helper"

RSpec.describe AnalyticsService do
  before { Rails.cache.clear }

  describe "#dashboard_statistics" do
    it "aggregates employees, departments, countries, and average salary" do
      create(:employee, country: "US", department: "Eng", salary: 50_000.00)
      create(:employee, country: "US", department: "Eng", salary: 70_000.00)

      stats = described_class.new.dashboard_statistics

      expect(stats[:total_employees]).to eq(2)
      expect(stats[:total_departments]).to eq(1)
      expect(stats[:total_countries]).to eq(1)
      expect(stats[:average_salary].to_d.round(2)).to eq(BigDecimal("60000.00"))
    end

    it "reads from Rails cache using AnalyticsCache.dashboard_statistics_key" do
      key = AnalyticsCache.dashboard_statistics_key
      create(:employee, salary: 40_000.00)

      described_class.new.dashboard_statistics
      expect(Rails.cache.exist?(key)).to be true

      described_class.new.dashboard_statistics
      entry = Rails.cache.read(key)
      expect(entry).to include(total_employees: 1)
    end

    it "uses full Employee table regardless of constructor scope" do
      create(:employee, country: "US", department: "A", salary: 100_000.00)
      create(:employee, country: "CA", department: "B", salary: 50_000.00)

      scoped = described_class.new(employee_scope: Employee.where(country: "US"))
      stats = scoped.dashboard_statistics

      expect(stats[:total_employees]).to eq(2)
      expect(stats[:total_countries]).to eq(2)
    end
  end

  describe "#country_salary_statistics" do
    it "respects the employee relation passed to the constructor" do
      create(:employee, country: "US", salary: 100_000.00)
      create(:employee, country: "CA", salary: 200_000.00)

      service = described_class.new(employee_scope: Employee.where(country: "US"))
      stats = service.country_salary_statistics(country_code: "US")

      expect(stats[:employee_count]).to eq(1)
      expect(stats[:minimum_salary]).to eq(100_000)
    end

    it "returns empty aggregates when the scoped relation has no rows for that country" do
      create(:employee, country: "US", salary: 50_000.00)

      service = described_class.new(employee_scope: Employee.where(country: "CA"))
      stats = service.country_salary_statistics(country_code: "US")

      expect(stats[:employee_count]).to eq(0)
      expect(stats[:minimum_salary]).to be_nil
      expect(stats[:maximum_salary]).to be_nil
      expect(stats[:average_salary]).to be_nil
    end

    it "normalizes country code to uppercase for cache and query" do
      create(:employee, country: "DE", salary: 60_000.00)

      stats = described_class.new.country_salary_statistics(country_code: "de")

      expect(stats[:country]).to eq("DE")
      expect(stats[:employee_count]).to eq(1)
    end
  end

  describe "#job_title_average_salary" do
    it "respects the employee relation passed to the constructor" do
      create(:employee, country: "US", job_title: "Engineer", salary: 80_000.00)
      create(:employee, country: "CA", job_title: "Engineer", salary: 200_000.00)

      service = described_class.new(employee_scope: Employee.where(country: "US"))
      stats = service.job_title_average_salary(country_code: "US", job_title: "Engineer")

      expect(stats[:employee_count]).to eq(1)
      expect(stats[:average_salary].to_d.round(2)).to eq(BigDecimal("80000.00"))
    end

    it "returns nil average when no matching rows in scope" do
      create(:employee, country: "US", job_title: "Analyst", salary: 50_000.00)

      service = described_class.new(employee_scope: Employee.where(country: "CA"))
      stats = service.job_title_average_salary(country_code: "US", job_title: "Analyst")

      expect(stats[:employee_count]).to eq(0)
      expect(stats[:average_salary]).to be_nil
    end
  end
end
