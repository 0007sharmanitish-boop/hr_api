class AuthFailureApp < Devise::FailureApp
  def respond
    if request.original_fullpath.start_with?("/api/")
      unauthorized_json
    else
      super
    end
  end

  private

  def unauthorized_json
    self.status = Rack::Utils.status_code(:unauthorized)
    self.content_type = "application/json"
    self.response_body = { errors: [ i18n_message ] }.to_json
  end
end
