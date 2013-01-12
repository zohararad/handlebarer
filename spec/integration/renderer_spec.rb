require 'spec_helper'

describe Handlebarer::Renderer do

  context 'users/index' do

    before do
      User.all.each do |user|
        user.destroy
      end
      @joe = User.create(:name => 'Joe', :email => 'joe@gmail.com')
      @mike = User.create(:name => 'Mike', :email => 'mike@gmail.com')
    end

    before :each do
      get '/users'
    end

    it 'render users index page' do
      response.should render_template(:index)
    end

    it 'renders the template HTML' do
      response.body.should include '<h1 id="topHeading">Hello All Users</h1>'
    end

    it 'renders users' do
      response.body.should include "<p>#{@mike.name}</p>"
      response.body.should include "<p>#{@joe.name}</p>"
    end

  end

  context 'users/show' do

    before :each do
      @user = stub_model(User, :name => 'Sam', :email => 'sam@gmail.com')
      User.should_receive(:find).and_return(@user)
    end

    it 'renders instance variables' do
      get user_path(@user)
      response.body.should include 'My name is %s' % @user.name
    end

  end
end