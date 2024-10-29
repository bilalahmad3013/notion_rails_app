# frozen_string_literal: true

class NotionDatabaseController < ApplicationController
  before_action :set_current_user
  before_action :set_selected_table, only: [:index, :insert, :create_in_notion]
  before_action :set_properties, only: [:insert, :create_in_notion]
  before_action :set_data, only: [:index, :insert]

  def index
    if @data.present?
      @columns = extract_unique_columns(@data)
    else
      @columns = []
      flash[:alert] = "No data found for the selected database."
    end
  end

  def insert
    @database_id = params[:database_id]    
  end
  
  def create_in_notion    
    notion_access_token = @selected_table.user.notion_access_token
    properties_data = build_properties_data
  
    @response = NotionService.create_entry(@selected_table.database_id, notion_access_token, properties_data)
    if @response
      flash[:notice] = "Entry created successfully."
    else
      flash[:alert] = "Error in creating entry"
    end
    render json: { message: flash[:notice] || flash[:alert], response: @response }
  end  

  private

  def set_current_user
    @current_user = current_user
  end

  def set_selected_table
    @selected_table = current_user.notion_tables.find { |table| table.database_id == params[:database_id] }
  end

  def set_properties
    @properties = @selected_table&.properties || []
  end

  def set_data
    if @selected_table
      notion_access_token = @selected_table.user.notion_access_token
      @data = NotionService.get_data(@selected_table.database_id, notion_access_token)
    else
      handle_no_matching_table
    end
  end

  def extract_unique_columns(data)
    data.flat_map(&:keys).uniq
  end 

  def handle_no_matching_table
    @data = []
    @columns = []
    flash[:alert] = "No matching table found for the database ID provided."
  end

  def build_properties_data
    @properties.each_with_object({}) do |(property_name, data_type), result|
      result[property_name] = [params[property_name], data_type]
    end
  end
end