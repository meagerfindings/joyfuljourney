class FamilyInvitationMailer < ApplicationMailer
  default from: 'noreply@joyfuljourney.com'

  def invitation_email(family_invitation)
    @invitation = family_invitation
    @family = @invitation.family
    @inviter = @invitation.inviter
    @invitation_url = public_invitation_url(@invitation.token)
    
    mail(
      to: @invitation.email,
      subject: "#{@inviter.name} invited you to join #{@family.name} on Joyful Journey"
    )
  end
end
