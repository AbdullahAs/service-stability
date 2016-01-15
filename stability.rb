#!/usr/bin/env ruby

require 'rest-client'
require 'nokogiri'


@USER_NAME = 'Jallal.m'
@PASSWORD = 'zxzszaQWE123'
@ACCOUNT_NUMBER = '1000153592196221'
@MSISDN = '966543103379'
@TRANSACTION_ID = 1111111111111111
@VERSION = '0.10.47'
@DEVICE_ID = '040EC214-0B47-4807-9CE6-E6BDBE4F92CA'
@token_authorization = "Basic SDdyblg0Q3RXSXJGZjI3Xzdscl9ualNDTDY0YTpVZUNmM3lBQnJnUkRRSGNJNmVWN0RxdGY1UG9h";
@resonse_time = 0
@number_of_timeouts = 0

# Functionalites methods
# 1
def fbi
  p '[[FBI REQUEST]]'
  p @url = 'http://www.mobily.com.sa/sec/mobilybe/rest/usage/list'
  p request_body = {MSISDN: @MSISDN, "LANG":"EN", "APP_ID":"Iconick_IOS", "VERSION": @VERSION, "TRANSACTION_ID": @TRANSACTION_ID, "DEVICE_ID": @DEVICE_ID, "SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 2
def settings
  p '[[Settings REQUEST]]'
  p @url = 'https://www.mobily.com.sa/sec/mobilybe/rest/app/settings'
  p request_body = {"LANG":"EN","VERSION": @VERSION,"APP_ID":"Iconick_IOS","DEVICE_ID": @DEVICE_ID,"TRANSACTION_ID": @TRANSACTION_ID,"SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 3
def news
  p '[[News REQUEST]]'
  p @url = 'https://www.mobily.com.sa/sec/notificationcenter/rest/news/list/active'
  p request_body = {"MSISDN": @MSISDN,"LANG":"EN","APP_ID":"Iconick_IOS","VERSION": @VERSION,"TRANSACTION_ID": @TRANSACTION_ID,"DEVICE_ID": @DEVICE_ID,"SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 4
def balance
  p '[[Balance REQUEST]]'
  p @url = 'https://www.mobily.com.sa/sec/mobilybe/rest/usage/balance/credit'
  p request_body = {"MSISDN": @MSISDN,"LANG":"EN","APP_ID":"Iconick_IOS","VERSION": @VERSION,"TRANSACTION_ID": @TRANSACTION_ID,"USER_NAME": @ACCOUNT_NUMBER,"DEVICE_ID": @DEVICE_ID,"SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 5
def neqaty
  p '[[Neqaty REQUEST]]'
  p @url = 'https://www.mobily.com.sa/sec/mobilybe/rest/loyalty/info'
  p request_body = {MSISDN: @MSISDN, "LANG":"EN", "APP_ID":"Iconick_IOS", "VERSION": @VERSION, "TRANSACTION_ID": @TRANSACTION_ID,"USER_NAME": @ACCOUNT_NUMBER, "DEVICE_ID": @DEVICE_ID, "SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# ===============

# Get Token
def token
  @url = 'https://www.mobily.com.sa/token'
  p '(Token Request)'
  p request_body = "grant_type=client_credentials&scope=LOGIN"
  begin
    response = RestClient.post @url , request_body, {content_type: "application/x-www-form-urlencoded; charset=utf-8", Authorization: @token_authorization}
  rescue RestClient::ExceptionWithResponse => err
    p '#### TOKEN ERROR ####'
    p err.response
  end
  p '(Token Response)'
  p token_details = JSON.parse(response)
  @authorization_code = "Bearer " + token_details['access_token']
end

# get sesttion id
def login
  @url = 'https://www.mobily.com.sa/sec/mobilybe/rest/login/account'
  p '(login request)'
  p request_body = {"APP_ID":"Iconick_IOS","VERSION": @VERSION,"LANG":"EN","TRANSACTION_ID": @TRANSACTION_ID,"USER_NAME": @USER_NAME,"PASSWORD": @PASSWORD,"DEVICE_ID": @DEVICE_ID}
  begin
    response = RestClient.post @url , request_body.to_json, {content_type: :json, accept: :json , Authorization: @authorization_code}
  rescue RestClient::ExceptionWithResponse => err
    p '====== LOGIN ERROR ======'
    p err.response
  end
  p '(Login Response)'
  p login_details = JSON.parse(response)
  @seesion_id = login_details["LOGIN_OUTPUT"]["SESSION_ID"]
  @access_token =  "Bearer " + login_details["LOGIN_OUTPUT"]["ACCESS_TOKEN"]
end

def registerDevice
  p '[[Register Device REQUEST]]'
  p @url = 'https://www.mobily.com.sa/sec/notificationcenter/rest/device/registerDevice'
  p request_body = {MSISDN: @MSISDN, "LANG":"EN", "APP_ID":"Iconick_IOS", "VERSION": @VERSION, "TRANSACTION_ID": @TRANSACTION_ID, "DEVICE_ID": @DEVICE_ID, "SESSION_ID": @seesion_id, "DEVICE_MODEL":"Test API (device model)","DEVICE_NAME":"Test API (device name","TOKEN":"token","DEVICE_VERSION":"iOS 9.2"}
  parse_json(request_body)
end

# ===============

# Parse the JSON response
def parse_json(request_body)
  begin
    p '[[RESPONSE]]'
    response = RestClient.post @url , request_body.to_json, {content_type: :json, accept: :json , Authorization: @access_token}
  rescue RestClient::ExceptionWithResponse => err
    p '###################### ERROR #####################'
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
  while @number_of_requests <= 500
    time_first = Time.now
    p Time.now
    p "try #{@number_of_requests}, hitting: #{@url}"
    # service name
    fbi
    # neqaty
    # settings
    # news
    balance
    # login
    # registerDevice
    res_time = Time.now - time_first
    @resonse_time  += res_time
    p "resonse time = #{res_time} sec"
    p '==========================================================================================================================='
    @number_of_requests += 1
    @TRANSACTION_ID += 1
  end
end

# Print a summary of the result at the end of the execution
def summary
  p "API: #{@url}"
  p "Number of Requests: #{@number_of_requests}"
  p "Number of Errors/Timeouts: #{@number_of_timeouts}"
  p "Avg Response Time: #{@resonse_time/500}"
  p '==========================================================================================================================='
end

def write_to_error_file(url, response, error)
  @errors_file.write("Error in:")
  @errors_file.write(url)
  @errors_file.write("\n Error Response: ")
  @errors_file.write(error)
  @errors_file.write("\n ================== \n\n")
end

@errors_file = File.open('errors.txt', 'w')
start
summary
@errors_file.close


