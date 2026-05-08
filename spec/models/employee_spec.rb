require 'rails_helper'

RSpec.describe Employee, type: :model do
  subject { FactoryBot.build(:employee) }
  
  describe "validations" do
    it { should validate_presence_of(:employee_code)}
    it { should validate_uniqueness_of(:employee_code) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:job_title) }
    it { should validate_presence_of(:country) }
    it { should validate_presence_of(:salary) }
    it { should validate_numericality_of(:salary).is_greater_than(0) }
    it { should validate_presence_of(:department) }
    it { should allow_value(Date.today).for(:hire_date) }
    it { should_not allow_value("not-a-date").for(:hire_date) }
  end
end