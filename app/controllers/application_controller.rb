class ApplicationController < ActionController::Base
  require 'handset_detection'

  protect_from_forgery
  handset_detection

end
