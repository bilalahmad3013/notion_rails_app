class NotionService
  BASE_URL = 'https://api.notion.com/v1/'

  def self.get_data(database_id, notion_access_token)
    url = "#{BASE_URL}databases/#{database_id}/query"

    response = HTTP.auth("Bearer #{notion_access_token}")
                   .headers('Notion-Version' => '2022-06-28', 'Content-Type' => 'application/json')
                   .post(url)

    handle_response(response, true)
  end

  def self.create_entry(database_id, notion_access_token, properties_data)
    url = "#{BASE_URL}pages"
    notion_data = {
      parent: { database_id: database_id },
      properties: build_notion_properties(properties_data)
    }   
    response = HTTP.auth("Bearer #{notion_access_token}")
                .headers('Notion-Version' => '2022-06-28', 'Content-Type' => 'application/json')
                .post(url, json: notion_data)      
    handle_response(response, false)
  end

  private

  def self.build_notion_properties(properties_data)
    properties_data.each_with_object({}) do |(property_name, (value, data_type)), notion_properties|
      notion_properties[property_name] = map_property_to_notion(value, data_type)
    end
  end

  def self.map_property_to_notion(value, data_type)
    case data_type
    when "number"      
      { number: value.to_f }
    when "rich_text"
      { rich_text: [{ text: { content: value } }] }
    when "title"
      { title: [{ text: { content: value } }] }
    when "date"
      { date: { start: value } }
    when "checkbox"
      { checkbox: value }
    when "select"
      { select: { name: value } }
    when "multi_select"
      { multi_select: value.map { |v| { name: v } } }
    when "url"
      { url: value }
    when "email"
      { email: value }
    when "phone_number"
      { phone_number: value }
    when "files"
      { files: value.map { |file| { name: file[:name], url: file[:url] } } }   
    else
      { rich_text: [{ text: { content: value.to_s } }] }
    end
  end  

  def self.handle_response(response, status)
    case response.status
    when 200..299
      data = JSON.parse(response.body.to_s)
      if status
        extract_properties(data)
      else
        true
      end
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
        extract_property_value(name, value)
      end
      page_properties.reduce({}, :merge)
    end
  end

  def self.extract_property_value(name, value)
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
end
