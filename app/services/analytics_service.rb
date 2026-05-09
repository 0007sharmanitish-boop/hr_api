class AnalyticsService
  def initialize(employee_scope: Employee.all)
    @employee_scope = employee_scope
  end

  def country_salary_statistics(country_code:)
    rel = scoped_to_country(country_code)
    count = rel.count

    if count.zero?
      return empty_country_stats(country_code)
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

  def job_title_average_salary(country_code:, job_title:)
    rel = scoped_to_country(country_code).where(job_title: job_title)
    count = rel.count

    if count.zero?
      return empty_job_title_stats(country_code, job_title)
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

  def scoped_to_country(country_code)
    @employee_scope.where(country: country_code)
  end

  def empty_country_stats(country_code)
    {
      country: country_code,
      employee_count: 0,
      minimum_salary: nil,
      maximum_salary: nil,
      average_salary: nil
    }
  end

  def empty_job_title_stats(country_code, job_title)
    {
      country: country_code,
      job_title: job_title,
      employee_count: 0,
      average_salary: nil
    }
  end
end
