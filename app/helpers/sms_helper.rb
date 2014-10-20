require 'yaml'

module SmsHelper
   
   @@sms_credentials = YAML.load(File.open("#{RAILS_ROOT}/config/sms_auth.yml"))
   
   def send_message_to_this_doc(message_info)
     begin
#     send_message_to_this_doc_via_way2sms(message_info)

      if message_info[:schedule_start_date] == message_info[:schedule_end_date]
        message_text = <<-EOF
Inviting you for the SSSMH prog "#{message_info[:programme_name]}" scheduled on #{message_info[:schedule_start_date].strftime("%b %d, %Y")}. Plz confirm "MINT #{@@sms_credentials["sms2mint_credentials"]['username']} <Yes/No> #{message_info[:programme_name]}" to 56677
EOF
      else
        message_text = <<-EOF
Inviting you for the SSSMH prog "#{message_info[:programme_name]}" schduled b/w #{message_info[:schedule_start_date].strftime("%b %d")} and #{message_info[:schedule_end_date].strftime("%b %d, %Y")}.Plz confrm "MINT #{@@sms_credentials["sms2mint_credentials"]['username']} <Yes/No> #{message_info[:programme_name]}" to 56677
EOF
      end

      send_message_to_this_doc_via_sms2mint(message_text,message_info[:user_phone_number])

    rescue Exception => e
#     puts "e : #{e}"
    end
   
   end
   
    # This method is to login to the SMS2Mint Application returning 3 handlers to the calling function to further process the request  
    def login_to_sms2mint
      sms2mint_creds = @@sms_credentials["sms2mint_credentials"]
      post_data = "_method=POST&data[Customer][user_type]=0&data[Customer][country_code]=#{sms2mint_creds['country_code']}&data[Customer][login]=#{sms2mint_creds['username']}&data[Customer][password]=#{sms2mint_creds['password']}"
      url = "www.sms2mint.com"
      path = "/users/userLogin"

      http = Net::HTTP.new(url)
      headers = {
        'User-Agent' => 'Mozilla/5.0 (Windows; U;Windows NT 6.0; en-US; rv:1.9.0.5) Gecko/2008120122 Firefox/3.0.5',
        'Referer' => 'http://www.sms2mint.com/users/userLogin',
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
     
      response, data = http.post(path,post_data,headers)

      cookie = response.response['set-cookie']
      
      instant_sms_headers = {
        'User-Agent' => 'Mozilla/5.0 (Windows; U;Windows NT 6.0; en-US; rv:1.9.0.5) Gecko/2008120122 Firefox/3.0.5',
        'Cookie' => cookie
      }

      return instant_sms_headers,http
      
    end

    def send_message_to_this_doc_via_sms2mint(message_text,user_phone_number,login = true,login_params = nil)
      begin
        
        if login
          # To loginto the SMS2Mint application with the registered number configured in te sms_auth.yml file
          instant_sms_headers,http = login_to_sms2mint
          login_params=[instant_sms_headers,http]
        else
          # This option is sought if the login is already performed before. So just use the return handlers
          instant_sms_headers = login_params[0]
          http = login_params[1]
        end

        send_prev_message_path = "/users/sendsms"
      
=begin
  You are invited for SSSMH prog. "Dec 6 to 9" scheduled b/w Dec 06 and Dec 09, 2010. Plz reply Yes/No to 56677 in the format "MINT 9500079694 <Yes/No> Dec 6 to 9"
    ==>
  
  Inviting you for the SSSMH prog "Dec 6 to 9" schduled b/w Dec 06 & Dec 09, 2010. Plz confirm "MINT 9500079694 <Yes/No> Dec 6 to 9" to 56677
    ==> 140 chars
=end
      
        if message_text.length > 140
          message_text_1 = message_text[0,131]
          message_text_2 = message_text[132,message_text.length]
  
          send_prev_message_data = "_method=POST&data[Customer][compose]=compose&data[Customer][country_code]=91&data[Customer][mobile_number]=#{user_phone_number}&data[Customer][message]=#{message_text_1}"
          send_prev_message_response,send_prev_message_data = http.post(send_prev_message_path,send_prev_message_data,instant_sms_headers)
            
          send_prev_message_data = "_method=POST&data[Customer][compose]=compose&data[Customer][country_code]=91&data[Customer][mobile_number]=#{user_phone_number}&data[Customer][message]=#{message_text_2}"
          send_prev_message_response,send_prev_message_data = http.post(send_prev_message_path,send_prev_message_data,instant_sms_headers)
        else
          send_prev_message_data = "_method=POST&data[Customer][compose]=compose&data[Customer][country_code]=91&data[Customer][mobile_number]=#{user_phone_number}&data[Customer][message]=#{message_text}"
          send_prev_message_response,send_prev_message_data = http.post(send_prev_message_path,send_prev_message_data,instant_sms_headers)
        end
        
        if login
          # Need to logout only if the login has been performed inside this method
          sms2mint_logout(login_params)
        end

      rescue Exception => e
#        puts "e : #{e}"
      end
  
   end

# =============================================================================================================================

  def send_message_to_this_doc_via_way2sms(message_info)
    way2sms_creds = @@sms_credentials["way2sms_credentials"]
    post_data = "username=#{way2sms_creds['username']}&password=#{way2sms_creds['password']}"
    url = "wwwa.way2sms.com"
    path = "/auth.cl"

    http = Net::HTTP.new(url)
    headers = {
      'User-Agent' => 'Mozilla/5.0 (Windows; U;Windows NT 6.0; en-US; rv:1.9.0.5) Gecko/2008120122 Firefox/3.0.5',
      'Referer' => 'http://wwwg.way2sms.com//entry.jsp',
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
   
    response, data = http.post(path,post_data,headers)
    cookie = response.response['set-cookie']
    
    instant_sms_url = "http://wwwa.way2sms.com//jsp"
    instant_path = "/jsp/InstantSMS.jsp?val=0"
    
    instant_sms_headers = {
      'User-Agent' => 'Mozilla/5.0 (Windows; U;Windows NT 6.0; en-US; rv:1.9.0.5) Gecko/2008120122 Firefox/3.0.5',
      "Cookie" => cookie
    }

    response,data = http.get(instant_path,instant_sms_headers)
       
    action_position = data.rindex("Action")
    action_sliced_data = data.slice(action_position+15, action_position+30)
    quote_index = action_sliced_data.index("\"")
    customer_id = action_sliced_data.slice!(0,quote_index)
     
    send_instant_sms_path = "/FirstServletsms?"
    if message_info[:schedule_start_date] == message_info[:schedule_end_date]
      message_text = <<-EOF
        You are invited for the prog. #{message_info[:programme_name]} happening on #{message_info[:schedule_start_date]}. 
        Plz reply Yes/No to 56677 in the format <MINT> <#{way2sms_creds['username']}> Yes/No.
EOF
    else
      message_text = <<-EOF
        You are invited for the prog. #{message_info[:programme_name]} happening between #{message_info[:schedule_start_date]} 
        and #{message_info[:schedule_end_date]}. Plz reply Yes/No to 56677 in the format &quot;<MINT> <#{way2sms_creds['username']}> Yes/No&quot;.
EOF
    end
    
    message_text_1 = message_text[0,130]
    message_text_2 = message_text[130,message_text.length]
    
    send_instant_sms_post_data = "custid=undefined&HiddenAction=instantsms&Action=#{customer_id}&login=&pass=&MobNo=#{message_info[:user_phone_number]}&textArea=#{message_text_1}"
    response, data = http.post(send_instant_sms_path,send_instant_sms_post_data,instant_sms_headers)
    
    send_instant_sms_post_data = "custid=undefined&HiddenAction=instantsms&Action=#{customer_id}&login=&pass=&MobNo=#{message_info[:user_phone_number]}&textArea=#{message_text_2}"
    response, data = http.post(send_instant_sms_path,send_instant_sms_post_data,instant_sms_headers)
    
  end

=begin
    def send_message_to_this_doc_via_sendsmsnow(programme_name,success)
      post_data = "uname=mail2sanand&upass=sairam"
      url = "www.sendsmsnow.com"
      path = "/index.php"

      http = Net::HTTP.new(url)
      headers = {
        'User-Agent' => 'Mozilla/5.0 (Windows; U;Windows NT 6.0; en-US; rv:1.9.0.5) Gecko/2008120122 Firefox/3.0.5',
        'Referer' => 'http://www.sendsmsnow.com/index.php',
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
     
      response, data = http.post(path,post_data,headers)

      cookie = response.response['set-cookie']
#      puts "response : #{response}, \n \n \n data : #{data}"
#      puts "response code : #{response.code}"
#      puts "cookie : #{cookie}"
      
#      instant_sms_url = "http://wwwa.way2sms.com//jsp"
      instant_sms_headers = {
        'User-Agent' => 'Mozilla/5.0 (Windows; U;Windows NT 6.0; en-US; rv:1.9.0.5) Gecko/2008120122 Firefox/3.0.5',
        'Cookie' => cookie
      }

      send_prev_message_path = "/membprev.php"
      send_prev_message_data = "phone=0&country=82&number=9500079694&from=Mail2sanand&message=Test Message"

      send_prev_message_response,send_prev_message_data = http.post(send_prev_message_path,send_prev_message_data,instant_sms_headers)
      send_final_message_path = "/send.php"
      send_final_message_data = "adv_hour=1&adv_minute=0&adv_ampm=0&do=sendit&country=82&ccode=91&number=9500079694&phone=0&from=Mail2sanand&message=Test Message&provid=0"

     send_final_response,send_final_data = http.post(send_final_message_path,send_final_message_data,instant_sms_headers)
     
    end
=end

    def recieve_sms_from_sms2mint_through_web
      
      # To loginto the SMS2Mint application with the registered number configured in te sms_auth.yml file
      instant_sms_headers,http = login_to_sms2mint
      
      login_params = [instant_sms_headers,http]

      home_page_path = "/users/userDashboard"
      inbox_path = "/users/userInbox"

      inbox_response,inbox_data = http.post(inbox_path,home_page_path,instant_sms_headers)
      
      # parse_sms2mint_inbox_data is a private method is to parse the inbox response from the SMS2Mint service and return the phone number, 
      # Invitation Status, Programme Name and the SMS2Mint IDs(for deletion)
      final_data,sms2mint_id_array = parse_sms2mint_inbox_data(inbox_data)

      #Process the SMS2Mint Inbox data
      processed_sms = process_sms2mint_data(final_data,login_params)
      
      deleted_sms = delete_sms2mint_messages(sms2mint_id_array,login_params)
      
      sms2mint_logout(login_params)
      
      return processed_sms,deleted_sms

    end

    def process_sms2mint_data(final_data,login_params)
      begin
        if final_data.size > 0
          
          final_data.each do |each_received_message|
            schedule = Schedule.find_by_programme_name(each_received_message["programme_name"])
            mail_subject_and_body = ""
            
            if each_received_message['valid_message'] and schedule
              user = User.find_by_contact_mob_no(each_received_message['phone_number'])
              user_schedule = UserSchedule.find_by_user_id_and_schedule_id(user.id,schedule.id) if user
              
              if user_schedule
                if each_received_message['invitation_status'] == "Yes"
                  user_schedule.update_attribute('volunteered',1)
                elsif each_received_message['invitation_status'] == "No"
                  user_schedule.update_attribute('volunteered',-1)
                end
              
                message_text = <<-EOF
SSSMH: Your invitation "#{(each_received_message['invitation_status'] == "Yes" ? 'Acceptance' : 'Rejection')}" is confirmed for the programme "#{each_received_message['programme_name']}"
EOF

                # Send a confirmation mail(for Accept/Rejection for a schedule invitation) to the Administrator/Director
                if schedule[:start_date] == schedule[:end_date]
                  mail_subject_and_body = "#{user.full_name.split(" ").map(&:capitalize).join(" ")}(#{each_received_message['phone_number']}) has #{(each_received_message['invitation_status'] == 'Yes' ? 'Accepted' : 'Rejected')} the invitation for the programme #{each_received_message['programme_name']} happening on #{schedule[:start_date].strftime("%b %d %Y")}"
                else
                  mail_subject_and_body = "#{user.full_name.split(" ").map(&:capitalize).join(" ")}(#{each_received_message['phone_number']}) has #{(each_received_message['invitation_status'] == 'Yes' ? 'Accepted' : 'Rejected')} the invitation for the programme #{each_received_message['programme_name']} happening between #{schedule[:start_date].strftime("%b %d %Y")} and #{schedule[:start_date].strftime("%b %d %Y")}"
                end
        
              else
                message_text = <<-EOF
SSSMH: You were not invited for the prog "#{each_received_message['programme_name']}".Plz check ur contact mob. no. in SSSMH portal(or)check with the SSSMH Director.
EOF
              end
            else
              message_text = <<-EOF
SSSMH: The Prog #{each_received_message['programme_name']} does not exist or the SMS format is incorrect. Please check the Invitation message and send again. 
EOF
            end
            
            # Send a confirmation SMS(for Accept/Rejection for a schedule invitation) or an incorrect notice SMS to the user.
            send_message_to_this_doc_via_sms2mint(message_text,each_received_message['phone_number'],false,login_params)

            UserNotifications.deliver_mail_to_admin_about_invite_doctor(mail_subject_and_body)

          end
          return final_data.size
        else
          return nil
        end
      rescue Exception => e
#        puts "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE : #{e}"
      end
    end

    # This method is to logout of the SMS2Mint application once the processing and deletion of the messages have been done.
    def sms2mint_logout(login_params)
      logout_path = "/users/userLogout"
      instant_sms_headers = login_params[0]
      http = login_params[1]
      logout_sms_response,logout_sms_data = http.post(logout_path,logout_path,instant_sms_headers)
    end

   private
   
    # This private method is to parse the inbox response data into the phone number, the SMS2Mint ID, invitation status and the Programme Name 
    def parse_sms2mint_inbox_data(inbox_data)
      begin
        div_parsing = inbox_data.split("loginform")
        
        first_div_parsing = div_parsing[1]
        
        second_div_parsing = first_div_parsing.split("delete_button")[0].gsub(/[\n]/,'')
        
        third_tr_parsing_array = second_div_parsing.split("<tr")     #.map(&:strip!)
        
        third_tr_parsing_array.each do |e|
            third_tr_parsing_array.delete(e) if !(e=~/(\[SmsInbox\]\[id\]\[\])/)
        end
        
        third_tr_parsing_array.delete_at(0)
        
        final_array = []
        id_array = []
        
        third_tr_parsing_array.each do |r|
            fourth_tr_parsing_array = r.split("<td")
            
            fourth_tr_parsing_array.each do |i|
                final_hash = {}
                if (i=~/checkbox/)
                    index_of_i = fourth_tr_parsing_array.index(i)
                    
                    #Parsing the SMS2Mint ID
                    double_quotes_array = i.split(/value="/)
                    #final_hash["sms2mint_id"] = double_quotes_array[1].split(/"/)[0]
                    id_array << double_quotes_array[1].split(/"/)[0]
                    
                    #Parsing the user's phone number.
                    phone_number_string = fourth_tr_parsing_array[index_of_i+1]
                    final_hash["phone_number"] = phone_number_string.slice((phone_number_string.index('>')+3)..(phone_number_string.index('<')-1))
                    
                    #Parsing the User's Message            
                    message_string = fourth_tr_parsing_array[index_of_i+2]
                    yes_no_index = message_string.index(/Yes|No/)
                    
                    if yes_no_index
                      message_string_from_yes_no_index = message_string.slice(yes_no_index..message_string.length-1)
                      final_message = message_string_from_yes_no_index.slice(0..message_string_from_yes_no_index.index('<')-1).gsub(">",'')
                      
                      #Parse the Invitation Status and the Programme_name
                      final_message_status_and_programe_name = final_message.split(" ")
                      final_hash["invitation_status"] = final_message_status_and_programe_name.delete_at(0)
                      final_hash["programme_name"] = final_message_status_and_programe_name.join(" ")
                      final_hash["valid_message"] = true
                      
                    else
                      
                      final_hash["valid_message"] = false
                      final_hash["invitation_status"] = ""
                      final_hash["programme_name"] = (message_string.slice(message_string.index('>')+1..message_string.index('<')-1)).strip
                    end
                    
                    unless final_hash["phone_number"] == @@sms_credentials["sms2mint_credentials"]["username"]
                      final_array << final_hash
                    end
                    
                    break
                end
            end
        
        end
        return final_array,id_array
      rescue Exception => e
#        puts "e : #{e}"
      end
    #end of the def parse_sms2mint_inbox_data
    end
  
    def delete_sms2mint_messages(sms2mint_id_array,login_params)
      begin
        sms2mint_id_array_size = sms2mint_id_array.size
        
        # Need to delete SMSs only if there are any messages in the SMS2Mint Inbox 
        if sms2mint_id_array_size > 0 
          instant_sms_headers = login_params[0]
          http = login_params[1]
          delete_path = "/users/userInbox/Array"
          
          delete_data = "_method=PUT&data[SmsInbox][search_txt]=&checkbox="
          sms2mint_id_array.each do |each_sms2mint_id|
            delete_data += "&data[SmsInbox][id][]=#{each_sms2mint_id}"
          end

          # Triggering the http URL for deleting all the SMSs in the inbox.
          delete_sms_response,delete_sms_data = http.post(delete_path,delete_data,instant_sms_headers)
          
          return sms2mint_id_array_size
        else
          return nil
        end
      rescue Exception => e
 #       puts "e : #{e}"
      end
    end

#Class End  
end

