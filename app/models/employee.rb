class Employee < ApplicationRecord
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_validation :assign_employee_code, on: :create

  validates :first_name, :job_title, :country, :department, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: EMAIL_REGEX }
  validates :employee_code, presence: true, uniqueness: true
  validates :salary, presence: true, numericality: { greater_than: 0 }
  validates :hire_date, presence: true # rails 7+ automatically handle date parsing and presence ensures that it a valid date not nil

  def self.salary_statistics_for_country(country_code)
    rel = where(country: country_code)
    count = rel.count

    if count.zero?
      return {
        country: country_code,
        employee_count: 0,
        minimum_salary: nil,
        maximum_salary: nil,
        average_salary: nil
      }
    end

    min_salary, max_salary, avg_salary = rel.pick(
      Arel.sql("MIN(salary)"),
      Arel.sql("MAX(salary)"),
      Arel.sql("AVG(salary)")
    )

    {
      country: country_code,
      employee_count: count,
      minimum_salary: min_salary,
      maximum_salary: max_salary,
      average_salary: avg_salary.to_d.round(2)
    }
  end

  def self.average_salary_for_job_title_in_country(country_code, job_title)
    rel = where(country: country_code, job_title: job_title)
    count = rel.count

    if count.zero?
      return {
        country: country_code,
        job_title: job_title,
        employee_count: 0,
        average_salary: nil
      }
    end

    avg = rel.pick(Arel.sql("AVG(salary)"))
    {
      country: country_code,
      job_title: job_title,
      employee_count: count,
      average_salary: avg.to_d.round(2)
    }
  end

  private

  def assign_employee_code
    return if employee_code.present?

    self.employee_code = generate_unique_employee_code
  end

  def generate_unique_employee_code
    loop do
      code = "EMP-#{SecureRandom.hex(6).upcase}"
      return code unless self.class.exists?(employee_code: code)
    end
  end
end