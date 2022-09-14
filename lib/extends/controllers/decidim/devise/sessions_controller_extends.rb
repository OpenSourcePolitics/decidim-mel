# frozen_string_literal: true

module SessionControllerExtends
  def after_sign_in_path_for(user)
    return super if user.is_a? Decidim::System::Admin

    if user.present? && user.respond_to?(:blocked?) && user.blocked?
      check_user_block_status(user)
    elsif !user.admin? && !pending_redirect?(user) && !skip_authorization_handler? && first_login_and_not_authorized?(user)
      decidim_verifications.first_login_authorizations_path
    else
      super
    end
  end

  private

  # Skip authorization handler by default
  def skip_authorization_handler?
    ENV["SKIP_FIRST_LOGIN_AUTHORIZATION"] ? ActiveRecord::Type::Boolean.new.cast(ENV["SKIP_FIRST_LOGIN_AUTHORIZATION"]) : true
  end
end

Devise::SessionsController.class_eval do
  prepend(SessionControllerExtends)
end
