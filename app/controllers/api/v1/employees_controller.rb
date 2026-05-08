class Api::V1::EmployeesController < ApplicationController
  def index
    employees = Employee.page(params[:page] || 1).per(params[:per_page] || 10)
    render json: {
      data: employees,
    }, status: :ok
  end


  def create
    employee = Employee.new(employee_params)

    if employee.save
      render json: {
        message: "Employee created successfully",
        data: employee
      }, status: :created
    else
      render json: {
        errors: employee.errors.full_messages
      }, status: :unprocessable_content
    end
  end

  private
  def employee_params
    params.require(:employee).permit(
      :first_name, :last_name, :email, :job_title, 
      :country, :salary, :department, :hire_date, :employee_code
    )
  end
    
end