class NotionService
    BASE_URL = 'https://api.notion.com/v1/'    
  
    def self.get_data(database_id, notion_access_token)
      url = "#{BASE_URL}databases/#{database_id}/query"
      
      response = HTTP.auth("Bearer #{notion_access_token}")
                     .headers('Notion-Version' => '2022-06-28', 'Content-Type' => 'application/json')
                     .post(url)
  
      handle_response(response)
    end  
  
    private
  
    def self.handle_response(response)
      case response.status
      when 200..299
        data = JSON.parse(response.body.to_s)        
        extract_properties(data)
      when 401
        Rails.logger.error 'Unauthorized: Check Notion API token or database permissions.'
        false
      when 404
        Rails.logger.error 'Not Found: The requested database could not be found.'
        false
      else
        Rails.logger.error "API Error: #{response.status} - #{response.body.to_s}"
        false
      end
    end
  
    def self.extract_properties(data)
      data["results"].map do |page|
        page_properties = page["properties"].map do |name, value|
          case value["type"]
          when "title"
            { name => value["title"].any? ? value["title"].first["plain_text"] : nil }
          when "rich_text"
            { name => value["rich_text"].any? ? value["rich_text"].map { |text| text["plain_text"] }.join(" ") : nil }
          when "number"
            { name => value["number"] }
          when "select"
            { name => value["select"] ? value["select"]["name"] : nil }
          when "multi_select"
            { name => value["multi_select"].any? ? value["multi_select"].map { |select| select["name"] }.join(", ") : nil }
          when "date"
            { name => value["date"] ? value["date"]["start"] : nil }
          when "checkbox"
            { name => value["checkbox"] }
          when "url"
            { name => value["url"] }
          when "email"
            { name => value["email"] }
          when "phone_number"
            { name => value["phone_number"] }
          when "files"
            { name => value["files"].any? ? value["files"].map { |file| file["name"] }.join(", ") : nil }
          else
            { name => "Unsupported property type" }
          end
        end
        page_properties.reduce({}, :merge)
      end
    end    
  end
  