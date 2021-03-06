require "dotenv"
require "httparty"

Dotenv.load

SLACK_TOKEN = ENV["SLACK_TOKEN"]

module Slack
  class User
    attr_reader :id, :user_name, :name
    
    def initialize(member)
      raise ArgumentError, "Trying to create User object with bad data: #{member}." if member["id"] == nil || member["name"] == nil || member["real_name"] == nil 
      @id = member["id"]
      @user_name = member["name"]
      @name = member["real_name"]
    end

    def details
      return "Details for this user: \n id: #{id} \n user name: #{user_name} \n real name: #{name}"
    end

    def post_message(message)
      # API ENDPOINT: https://slack.com/api/chat.postMessage 
      # query: @id
      results = HTTParty.post("https://slack.com/api/chat.postMessage", query: { token: SLACK_TOKEN, channel: id, text: message})
      raise BadResponseError, "chat.postMessage endpoint response IS NOT OK." unless results["ok"]
    end

    # CLASS METHODS

    # Parameter users: collection representing Users
    # Returns an array of User objects   
    def self.list_all
      members_including_deleted = get_all
      members = members_including_deleted.reject { |member| member["deleted"] } #cover a wonky case
      members.map { |member| User.new(member) }
    end

    private

    # Method uses http get to retrieve all User "objects"
    # returns an httparty Response object
    def self.get_all
      data = HTTParty.get("https://slack.com/api/users.list?", query: { token: SLACK_TOKEN, })
      raise BadResponseError, "Users.list endpoint response IS NOT OK." unless data["ok"]
      return data["members"]
    end
  end
end