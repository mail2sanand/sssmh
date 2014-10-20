require 'yaml'

class UserNotifications < ActionMailer::Base
  def forgot_password(user)
    @subject="Link to change Password [from RoR-ECommerce Website]"
    @body={:user=>user}
    @recipients=user.primary_e_mail
#    @from="admin@ror_ecommerce.com"
    @sent_on=Time.now
  end

  def user_approved(user)
#    puts "Entered this user_approved method in the UserNotifications"
    @subject="SSSMH User Registration Approval Intimation"
    @body={:user=>user,:user_approval_message => "You have been approved by the SSSMH Admin. Thank you for joining this noble activity."}
    @recipients=user.email
#    @from="admin@ror_ecommerce.com"
    @sent_on=Time.now
  end

  # This method is to send a mail to the Director whenever a doctor is been invited by the Administrator/Director
  def mail_to_admin_about_invite_doctor(mail_subject_and_body)
    director_details = YAML.load(File.open("#{RAILS_ROOT}/config/director_details.yml"))
    
    @subject = mail_subject_and_body
    @body={
      :user_approval_message => mail_subject_and_body
    }
    
    @recipients = director_details["director_1"]['email']
    @sent_on=Time.now
    puts "Sending mail for confirmation ... "
  end

  def checkout_confirmation_mail(user,order,purchase_invoice)
    @subject="Purchase Checkout Confirmation [from RoR-ECommerce Website]"
    @body={:user=>user,:order=>order,:purchase_invoice=>purchase_invoice}
    @recipients=user.primary_e_mail
#    @from="admin@ror_ecommerce.com"
    @sent_on=Time.now
  end

  def offer_mails(user,offer_details)
    @subject="#{offer_details['offer_subject']}"
    @body={:user=>user,:offer_description=>offer_details['offer_description']}
    @recipients=user.primary_e_mail
#    @from="admin@ror_ecommerce.com"
    @sent_on=Time.now
  end

  def created_user_notification(user)
    @subject="New user Creation Confirmation mail [from RoR-ECommerce Website]"
    @body={:user=>user}
    @recipients=user.primary_e_mail
#    @from="admin@ror_ecommerce.com"
    @sent_on=Time.now
  end
end
