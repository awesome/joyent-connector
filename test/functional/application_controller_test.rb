=begin #(fold)
++
Copyright 2004-2007 Joyent Inc.

Redistribution and/or modification of this code is 
governed by the GPLv2.

Report issues and contribute at http://dev.joyent.com/

$Id$
--
=end #(end)

require File.dirname(__FILE__) + '/../test_helper'
require 'authenticate_controller'

# Re-raise errors caught by the controller.
class ApplicationController
  alias_method :rescue_action_without_reraising, :rescue_action
  def rescue_action_with_reraising(e)
    rescue_action_without_reraising(e)
    raise e
  end
  alias_method :rescue_action, :rescue_action_with_reraising
end

class ApplicationControllerTest < Test::Unit::TestCase
  fixtures all_fixtures

  def setup
    @controller = AuthenticateController.new  # pick an innocuous controller
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  # Commented as the .currents get cleared
  # def test_organization_current_gets_set
  #   @request.host = 'joyent.joyent.com'
  #   get :login
  #   
  #   assert_equal domains(:joyent).id, current_domain.id
  # end
  
  def test_valid_domain_name_can_access
    @request.host = 'joyent.joyent.com'
    get :login
    
    assert_response :success
  end
  
  def test_invalid_domain_name_redirected_to_invalid_message
    @request.host = 'pap.joyent.com'
    get :login
    
    assert_redirected_to '/noaccount.html'
  end
  
  def test_ip_address_request_host
    @request.host = '1.2.3.4'
    get :login
    
    assert_redirected_to '/noaccount.html'
  end
  
  def test_production_languages
    get :login
    host = 'textdrive.joyent.com'
    assert ! JoyentConfig.staging_servers.includes?(host)
    @controller.request.env['SERVER_NAME'] = host

    assert_equal @controller.send(:connector_languages).length, JoyentConfig.production_languages.length
  end
  
  def test_development_languages
    get :login
    host = 'staging.example.com'
    assert JoyentConfig.staging_servers.includes?(host)
    @controller.request.env['SERVER_NAME'] = host

    assert_equal @controller.send(:connector_languages).length, (JoyentConfig.production_languages.length + JoyentConfig.development_languages.length)
  end
  
end