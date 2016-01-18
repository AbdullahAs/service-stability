#!/usr/bin/env ruby

require 'rest-client'
require 'nokogiri'
require 'colorize'

@USER_NAME = 'mobilyapp'
@PASSWORD = 'Mobily123'
@ACCOUNT_NUMBER = '1000153592196221'
@MSISDN = '966544900282'
@TRANSACTION_ID = 8899111111111111
@VERSION = '0.10.47'
@DEVICE_ID = '040EC214-0B47-4807-9CE6-E6BDBE4F92CA'
@token_authorization = "Basic SDdyblg0Q3RXSXJGZjI3Xzdscl9ualNDTDY0YTpVZUNmM3lBQnJnUkRRSGNJNmVWN0RxdGY1UG9h";
@resonse_time = 0
@number_of_timeouts = 0
@total_number_of_requests = 100

# Levels
@public = "https://www.mobily.com.sa/sec"
@BE_1 = "http://10.64.98.75:9080"
@BE_2 = "http://10.64.98.72:9080"
@WSO2_1 = "http://10.64.246.209:8280/sec"
@WSO2_2 = "http://10.64.246.210:8280/sec"
@http_1 = "http://10.64.250.8:80/sec"
@http_1 = "http://10.64.250.9:80/sec"

@level = @BE_2
# Functionalites methods
# 1
def fbi
  puts '[[FBI REQUEST]]'.yellow
  p @url = "#{@level}/mobilybe/rest/usage/list"
  p request_body = {MSISDN: @MSISDN, "LANG":"EN", "APP_ID":"Iconick_IOS", "VERSION": @VERSION, "TRANSACTION_ID": @TRANSACTION_ID, "DEVICE_ID": @DEVICE_ID, "SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 2
def settings
  puts '[[Settings REQUEST]]'.yellow
  p @url = "#{@level}/mobilybe/rest/app/settings"
  p request_body = {"LANG":"EN","VERSION": @VERSION,"APP_ID":"Iconick_IOS","DEVICE_ID": @DEVICE_ID,"TRANSACTION_ID": @TRANSACTION_ID,"SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 3
def news
  puts '[[News REQUEST]]'.yellow
  p @url = "#{@level}/notificationcenter/rest/news/list/active"
  p request_body = {"MSISDN": @MSISDN,"LANG":"EN","APP_ID":"Iconick_IOS","VERSION": @VERSION,"TRANSACTION_ID": @TRANSACTION_ID,"DEVICE_ID": @DEVICE_ID,"SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 4
def balance
  puts '[[Balance REQUEST]]'.yellow
  p @url = "#{@level}/mobilybe/rest/usage/balance/credit"
  p request_body = {"MSISDN": @MSISDN,"LANG":"EN","APP_ID":"Iconick_IOS","VERSION": @VERSION,"TRANSACTION_ID": @TRANSACTION_ID,"USER_NAME": @ACCOUNT_NUMBER,"DEVICE_ID": @DEVICE_ID,"SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 5
def neqaty
  puts '[[Neqaty REQUEST]]'.yellow
  p @url = "#{@level}/mobilybe/rest/loyalty/info"
  p request_body = {MSISDN: @MSISDN, "LANG":"EN", "APP_ID":"Iconick_IOS", "VERSION": @VERSION, "TRANSACTION_ID": @TRANSACTION_ID,"USER_NAME": @ACCOUNT_NUMBER, "DEVICE_ID": @DEVICE_ID, "SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 6
def outstanding
  puts '[[Neqaty REQUEST]]'.yellow
  p @url = "#{@level}/mobilybe/rest/usage/balance/outstanding"
  p request_body = {MSISDN: @MSISDN, "LANG":"EN", "APP_ID":"Iconick_IOS", "VERSION": @VERSION, "TRANSACTION_ID": @TRANSACTION_ID,"USER_NAME": @ACCOUNT_NUMBER, "DEVICE_ID": @DEVICE_ID, "SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# ===============

# Get Token
def token
  @url = 'https://www.mobily.com.sa/token'
  puts '(Token Request)'.yellow
  p request_body = "grant_type=client_credentials&scope=LOGIN"
  begin
    response = RestClient.post @url , request_body, {content_type: "application/x-www-form-urlencoded; charset=utf-8", Authorization: @token_authorization}
  rescue RestClient::ExceptionWithResponse => err
    puts '#### TOKEN ERROR ####'.red
    p err.response
  end
  puts '(Token Response)'.yellow
  p token_details = JSON.parse(response)
  @authorization_code = "Bearer " + token_details['access_token']
end

# get sesttion id
def login
  @url = 'https://www.mobily.com.sa/sec/mobilybe/rest/login/account'
  puts '(login request)'.yellow
  p request_body = {"APP_ID":"Iconick_IOS","VERSION": @VERSION,"LANG":"EN","TRANSACTION_ID": @TRANSACTION_ID,"USER_NAME": @USER_NAME,"PASSWORD": @PASSWORD,"DEVICE_ID": @DEVICE_ID}
  begin
    response = RestClient.post @url , request_body.to_json, {content_type: :json, accept: :json , Authorization: @authorization_code}
  rescue RestClient::ExceptionWithResponse => err
    puts '====== LOGIN ERROR ======'.red
    p err.response
  end
  puts '(Login Response)'.yellow
  p login_details = JSON.parse(response)
  @seesion_id = login_details["LOGIN_OUTPUT"]["SESSION_ID"]
  @access_token =  "Bearer " + login_details["LOGIN_OUTPUT"]["ACCESS_TOKEN"]
end

def registerDevice
  p '[[Register Device REQUEST]]'.yellow
  p @url = 'https://www.mobily.com.sa/sec/notificationcenter/rest/device/registerDevice'
  p request_body = {MSISDN: @MSISDN, "LANG":"EN", "APP_ID":"Iconick_IOS", "VERSION": @VERSION, "TRANSACTION_ID": @TRANSACTION_ID, "DEVICE_ID": @DEVICE_ID, "SESSION_ID": @seesion_id, "DEVICE_MODEL":"Test API (device model)","DEVICE_NAME":"Test API (device name","TOKEN":"token","DEVICE_VERSION":"iOS 9.2"}
  parse_json(request_body)
end

# ===============

# Parse the JSON response
def parse_json(request_body)
  begin
    puts '-RESPONSE-'.yellow
    response = RestClient.post @url , request_body.to_json, {content_type: :json, accept: :json , Authorization: @access_token}
  rescue RestClient::ExceptionWithResponse => err
    puts '###################### ERROR #####################'.red
    p err.response
    write_to_error_file(@url, response, err.response)
    @number_of_timeouts += 1
  end
  p response
end

def start
  token
  login
  @number_of_requests = 0
  while @number_of_requests <= @total_number_of_requests
    time_first = Time.now
    p Time.now
    p "try #{@number_of_requests}, hitting: #{@url}"
    # service name

    fbi
    neqaty
    settings
    news
    balance
    outstanding

    res_time = Time.now - time_first
    @resonse_time  += res_time
    p "resonse time = #{res_time} sec"
    puts '==========================================================================================================================='.yellow
    @number_of_requests += 1
    @TRANSACTION_ID += 1
  end
end

# Print a summary of the result at the end of the execution
def summary
  p "API: #{@url}"
  p "Number of Requests: #{@number_of_requests}"
  p "Number of Errors/Timeouts: #{@number_of_timeouts}"
  p "Avg Response Time: #{@resonse_time/@total_number_of_requests}"
  p '==========================================================================================================================='.yellow
end

def write_to_error_file(url, response, error)
  @errors_file.write("Error in:")
  @errors_file.write(url)
  @errors_file.write("\n TRANSACTION_ID:")
  @errors_file.write(@TRANSACTION_ID)
  @errors_file.write("\n Error Response: ")
  @errors_file.write(error)
  @errors_file.write("\n ================== \n\n")
end

@errors_file = File.open('errors.txt', 'w')
start
summary
@errors_file.close


