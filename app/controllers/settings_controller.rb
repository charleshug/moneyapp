class SettingsController < ApplicationController
  def index
    session[:page]="Settings"
  end
end
