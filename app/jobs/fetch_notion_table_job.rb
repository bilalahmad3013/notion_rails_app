# frozen_string_literal: true
require 'http'

class FetchNotionTableJob < ApplicationJob
  def perform(access_token, user)
    response_data = fetch_databases(access_token)
    databases = extract_database_info(response_data)    
    databases.each do |db_info|
      process_database(db_info, user)
    end    
  end

  private

  def fetch_databases(access_token)
    response = HTTP.post('https://api.notion.com/v1/search', 
      json: {
        "filter": {
          "property": "object",
          "value": "database"
        }
      },
      headers: {
        Accept: 'application/json',
        'Content-Type' => 'application/json',
        Authorization: "Bearer #{access_token}",
        'Notion-Version' => '2022-06-28'
      }
    )

    response.parse
  end

  def extract_database_info(response_data)
    response_data["results"].map do |db|
      {
        database_id: db["id"],
        title: db["title"].first["text"]["content"],
        properties: db["properties"].map { |name, _| name }.join(", ")
      }
    end
  end
  
  def process_database(db_info, user)
    notion_table = NotionTable.find_or_initialize_by(database_id: db_info[:database_id], user: user) do |table|
      table.title = db_info[:title]
      table.properties = db_info[:properties]
    end
  
    notion_table.save! unless notion_table.persisted?
  end  
end
