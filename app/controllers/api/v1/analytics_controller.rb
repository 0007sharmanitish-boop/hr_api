class Api::V1::AnalyticsController < ApplicationController
  def country_salary_statistics
    country = normalize_country(params.require(:country))
    return invalid_country_response unless country

    render_success(Employee.salary_statistics_for_country(country))
  end

  def job_title_average_salary
    country = normalize_country(params.require(:country))
    return invalid_country_response unless country

    job_title = params.require(:job_title).to_s.strip
    if job_title.blank?
      render_error(errors: [ "Job title can't be blank" ], status: :bad_request)
      return
    end

    render_success(Employee.average_salary_for_job_title_in_country(country, job_title))
  end

  private

  def normalize_country(raw)
    code = raw.to_s.strip.upcase
    return if code.blank? || code.length != 2

    code
  end

  def invalid_country_response
    render_error(errors: [ "Country must be a 2-letter code" ], status: :bad_request)
  end
end
