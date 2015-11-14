module Authorizable
  extend ActiveSupport::Concern

  included do
    helper_method :authorized_user?, :authorize_moderator?, :authorized_admin?
  end

  def authorize_admin!
    unless authorized_admin?
      redirect_unauthorized
    end
  end

  def authorize_moderator!
    unless authorized_moderator?
      redirect_unauthorized
    end
  end

  def authorize_user!
    unless authorized_user?
      redirect_unauthorized
    end
  end

  def authorized_user?
    current_user.user? || current_user.moderator? || current_user.admin?
  end

  def authorized_moderator?
    current_user.moderator? || current_user.admin?
  end

  def authorized_admin?
    current_user.admin?
  end

  private

  def redirect_unauthorized
    redirect_to root_url, alert: I18n.t('authorization.denied')
  end
end
