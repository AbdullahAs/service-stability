#!/usr/bin/env ruby

require 'rest-client'
require 'nokogiri'

# Functionalites methods
# 1
def usage
  @url = 'http://www.mobily.com.sa/sec/mobilybe/rest/usage/list'
  request_body = {MSISDN: @MSISDN, "LANG":"EN", "APP_ID":"Iconick_IOS", "VERSION": @VERSION, "TRANSACTION_ID": @TRANSACTION_ID,"USER_NAME": @ACCOUNT_NUMBER, "DEVICE_ID": @DEVICE_ID, "SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 2
def settings
  @url = 'https://www.mobily.com.sa/sec/mobilybe/rest/app/settings'
  request_body = {"LANG":"EN","VERSION": @VERSION,"APP_ID":"Iconick_IOS","DEVICE_ID": @DEVICE_ID,"TRANSACTION_ID": @TRANSACTION_ID,"SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 3
def news
  @url = 'https://www.mobily.com.sa/sec/notificationcenter/rest/news/list/active'
  request_body = {"MSISDN": @MSISDN,"LANG":"EN","APP_ID":"Iconick_IOS","VERSION": @VERSION,"TRANSACTION_ID": @TRANSACTION_ID,"DEVICE_ID": @DEVICE_ID,"SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 4
def balance
  @url = 'https://www.mobily.com.sa/sec/mobilybe/rest/usage/balance/credit'
  request_body = {"MSISDN": @MSISDN,"LANG":"EN","APP_ID":"Iconick_IOS","VERSION": @VERSION,"TRANSACTION_ID": @TRANSACTION_ID,"USER_NAME": @ACCOUNT_NUMBER,"DEVICE_ID": @DEVICE_ID,"SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 5
def login
  @url = 'https://www.mobily.com.sa/sec/mobilybe/rest/login/account'
  request_body = {"APP_ID":"Iconick_IOS","VERSION": @VERSION,"LANG":"EN","TRANSACTION_ID": @TRANSACTION_ID,"USER_NAME": @USER_NAME,"PASSWORD": @PASSWORD,"DEVICE_ID": @DEVICE_ID}
  parse_json(request_body)
end

# 6
def neqaty
  @url = 'https://www.mobily.com.sa/sec/mobilybe/rest/loyalty/info'
  request_body = {MSISDN: @MSISDN, "LANG":"EN", "APP_ID":"Iconick_IOS", "VERSION": @VERSION, "TRANSACTION_ID": @TRANSACTION_ID,"USER_NAME": @ACCOUNT_NUMBER, "DEVICE_ID": @DEVICE_ID, "SESSION_ID": @seesion_id}
  parse_json(request_body)
end

# 7
def registerDevice
  @url = 'https://www.mobily.com.sa/sec/notificationcenter/rest/device/registerDevice'
  request_body = {MSISDN: @MSISDN, "LANG":"EN", "APP_ID":"Iconick_IOS", "VERSION": @VERSION, "TRANSACTION_ID": @TRANSACTION_ID, "DEVICE_ID": @DEVICE_ID, "SESSION_ID": @seesion_id, "DEVICE_MODEL":"Test API (device model)","DEVICE_NAME":"Test API (device name","TOKEN":"token","DEVICE_VERSION":"iOS 9.2"}
  parse_json(request_body)
end


def token
  @url = 'https://www.mobily.com.sa/token'
  request_body = {}
  parse_json(request_body)
end

# Parse the JSON response
def parse_json(request_body)
  begin
    response = RestClient.post @url , request_body.to_json, {content_type: :json, accept: :json , Authorization: @authorization_code}
  rescue RestClient::ExceptionWithResponse => err
    p '#### ERROR ####'
    p err.response
    @number_of_timeouts += 1
  end
  p response
end

def start
  @number_of_requests = 0
  while @number_of_requests < 100
    time_first = Time.now
    p Time.now
    p "try #{@number_of_requests}, hitting: #{@url}"
    # service name
    usage
    # neqaty
    # settings
    # news
    # balance
    # login
    # registerDevice
    res_time = Time.now - time_first
    @resonse_time  += res_time
    p "resonse time = #{res_time} sec"
    p '==========================================================================================================================='
    @number_of_requests += 1
  end
end

# Print a summary of the result at the end of the execution
def summary
  p "API: #{@url}"
  p "Number of Requests: #{@number_of_requests}"
  p "Number of Errors/Timeouts: #{@number_of_timeouts}"
  p "Avg Response Time: #{@resonse_time/100}"
  p '==========================================================================================================================='
end

@USER_NAME = '966546964160'
@PASSWORD = 'Mobily123'
@ACCOUNT_NUMBER = '1000153592196221'
@MSISDN = '966546964160'
@TRANSACTION_ID = '1043208260101229'
@VERSION = '0.10.47'
@DEVICE_ID = '040EC214-0B47-4807-9CE6-E6BDBE4F92CA'
@seesion_id = '351949'
@authorization_code = 'Bearer 813f98e5c671abfc779ac19df9311ad'
@resonse_time = 0
@number_of_timeouts = 0
start
summary
