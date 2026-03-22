class UserApprovalMailer < ApplicationMailer
  def approval_email(user)
    @user = user
    mail(to: @user.email, subject: "Your FindAm account has been approved!")
  end

  def rejection_email(user)
    @user = user
    @reason = user.rejection_reason
    mail(to: @user.email, subject: "Update on your FindAm account application")
  end
end
