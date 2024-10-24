# frozen_string_literal: true
require 'http'

class NotionController < ApplicationController
  def index
    response = fetch_access_token    
    access_token = response["access_token"]  
    current_user.update!(notion_access_token: access_token, is_notion_fetched: true)
    FetchNotionTableJob.perform_now(access_token, current_user)
    redirect_to root_path    
  end

  private

  def fetch_access_token
    redirect_uri = ENV['HOST'] + '/auth/notion/callback'
    encoded = Base64.strict_encode64("#{ENV['NOTION_CLIENT_ID']}:#{ENV['NOTION_CLIENT_SECRET']}")
    
    response = HTTP.post('https://api.notion.com/v1/oauth/token', 
      json: {
        grant_type: 'authorization_code',
        code: notion_code_params[:code],
        redirect_uri: redirect_uri
      },
      headers: {
        Accept: 'application/json',
        'Content-Type' => 'application/json',
        Authorization: "Basic #{encoded}"
      }
    )   
    response.parse
  end
  
  def notion_code_params
    params.permit(:code)
  end  
end
