require 'spec_helper'

describe ApplicationController do
  controller do
    before_filter :authenticate_user!
    def index
      render text: "Yay!"
    end
  end
end
