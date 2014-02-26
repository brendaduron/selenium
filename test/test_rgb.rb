#!/bin/env ruby
# encoding: utf-8
require "json"
require "selenium-webdriver"
gem "test-unit"
require "test/unit"

class Rgb < Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "http://hex2rgba.devoth.com/"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end
  
  def teardown
    @driver.quit
    assert_equal [], @verification_errors
  end
  
  def test_rgb
    @driver.get(@base_url + "/")
    @driver.find_element(:id, "f_hex_value").clear
    @driver.find_element(:id, "f_hex_value").send_keys "ffffff"
    @driver.find_element(:id, "calculate").click
    verify { assert_equal "rgb(255, 255, 255)", @driver.find_element(:id, "f_rgb_for_css").attribute("value") }
    verify { assert_equal "rgba(255, 255, 255, 1)", @driver.find_element(:id, "f_rgba_for_css").attribute("value") }
    @driver.find_element(:id, "f_hex_value").clear
    @driver.find_element(:id, "f_hex_value").send_keys "45C678"
    @driver.find_element(:id, "calculate").click
    verify { assert_equal "rgb(69, 198, 120)", @driver.find_element(:id, "f_rgb_for_css").attribute("value") }
    verify { assert_equal "rgba(69, 198, 120, 1)", @driver.find_element(:id, "f_rgba_for_css").attribute("value") }
    @driver.find_element(:id, "f_hex_value").clear
    @driver.find_element(:id, "f_hex_value").send_keys "blue"
    @driver.find_element(:id, "calculate").click
    verify { assert_equal "rgb(0, 0, 255)", @driver.find_element(:id, "f_rgb_for_css").attribute("value") }
    verify { assert_equal "rgba(0, 0, 255, 1)", @driver.find_element(:id, "f_rgba_for_css").attribute("value") }
  end
  
  def element_present?(how, what)
    $receiver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
    $receiver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
  def verify(&blk)
    yield
  rescue Test::Unit::AssertionFailedError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = $receiver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
