# Handlerbarer - Share your Handlerbars templates between client and server

Handlerbars is a very popular templating engine, recently given much deserved attention due to the awesome Ember.js Framework.
Handlebarer gives you ability to easily use Handlerbars templates for both server and client side in your Rails project.

On the client-side your templates should be used with Rails' JST engine. On the server side, you can render your
Handlerbars templates as Rails views (similar to how you'd render ERB or HAML templates).

## Writing your templates

Lets assume you have a users controller `app/controllers/users_controller.rb` which in turn renders a list of users.
We'd like to share that view between the client and the server.

### Server-Side code

```ruby
class UsersController < ApplicationController

  def index
    @users = User.all
    respond_to do |format|
      format.html
    end
  end

end
```

To share our template between client and server, we need to place it under `app/assets/javascripts` for Sprockets' JST engine.

Lets create a views directory for our shared templates `app/assets/javascripts/views` and add our template there, following Rails' naming convensions.

The full template path should look like this: `app/assets/javascripts/views/users/index.jst.hbs`

### Template code

The most significant differences between using standard server-side Ruby-based engines like ERB or HAML and using Handlerbarer are:

* No access to server-side view helpers (such as url_for)
* No ruby-style instance variable like `@users`
* Template code is not Ruby and has to follow Handlerbars' syntax rather than embedded Ruby syntax
* No partials (for now)

Our template code should look like this:

```html
<ul class="users">
{{#users}}
<li>{{this.name}}</li>
{{/users}}
</ul>
```

Note that rendering this template server-side, will be done inside your application's layout. You can write your views layout file in ERB / HAML
and the call to `=yield` will render your Handlerbars template above.

### Sharing template code

Since Rails doesn't expect server-side templates to live under `app/assets` we need to add our client-side views path to Rails views lookup path.

Assuming we have an initializer `app/config/initializers/handlebarer.rb` we can add our client-side views directory like this:

```ruby
Handlerbarer.configure do |config|
  # make your client-side views directory discoverable to Rails
  config.views_path = Rails.root.join('app','assets','javascripts','views')
end
```

Internally, this adds a `before_filter` to `ApplicationController::Base` that prepends the provided path to `ActionView::Context` .

### Client-side code

To render the same template from the client, we need to fetch our users list from the server and then call our JST template with that list.

First, lets change our controller to return a JSON formatted list of users when called from the client:

```ruby
class UsersController < ApplicationController

  def index
    @users = User.all
    respond_to do |format|
      format.html
      format.json {
        render :json => @users.to_hbs
      }
    end
  end

end
```

Note the call to `to_hbs` on the `@users` collection. This ensures our users are properly serialized for use inside our template.
See the [Serialization](https://github.com/zohararad/handlebarer#serialization) section below for more details.

In our `application.js` file lets write the following:

```javascript
//= require handlebars/runtime
//= require views/users/index

$.getJSON('/users', function(users){
  $('body').html(JST['views/users/index']({users:users}));
});
```

## Serialization

To help Handlerbarer access Ruby and Rails variables inside the template, we need to employ some sort of JSON serializing before passing
these variables to the template. On the server-side, this happens automagically before the template is rendered.

Internally, Handlerbarer will try to call the `to_hbs` method on each instance variable that's passed to the template. Ruby's Hash, Array and Object classes have been extended
to support this functionality. Arrays and Hashes will attempt to call the `to_hbs` method on their members when `to_hbs` is invoked on their instances. For
other collection-like variables, the `to_hbs` method will only be invoked if they respond to a `to_a` method. This allows ActiveModel / ActiveRecord instance variables to
automatically serialize their members before rendering.

### Serializing models

Handlerbarer does not assume your Rails models should be serialized by default. Instead, it expects you to enable serializing on desired models explicitly.

To enable this behaviour, consider the following example:

```ruby
class User < ActiveRecord::Base

  include Handlerbarer::Serialize

  hbs_serializable :name, :email, :favorites, :merge => false

end
```

The call to `include Handlerbarer::Serialize` mixes Handlerbarer::Serializer capabilities into our model class.

We can then tell the serializer which attributes we'd like to serialize, and how we'd like the serialization to work.

By default, calling `hbs_serializable` with no arguments will serialize all your model attributes. Lets look at two examples:

Consider the following code:

```ruby
# define our model
class User < ActiveRecord::Base

  include Handlerbarer::Serialize

  hbs_serializable

end

# access in controller
class UsersController < ApplicationController

  def index
    @users = User.all
    @users.to_hbs # => all available user attributes (users table columns) will be serialized
  end

  def active
    @users = User.where('active = 1').select('name, email')
    @users.to_hbs # => only name and email attributes are serialized
  end
end
```

For better control over which attributes are serialized, and when serializing model relationships, we can tell the serializer
which attributes should always be serialized, and whether we'd like these attributes to be merged with the default attributes or not.

Consider the following code:


```ruby
# define our models

class Favorite < ActiveRecord::Base

  include Handlerbarer::Serialize

  hbs_serializable

  belongs_to :user

end

class User < ActiveRecord::Base

  include Handlerbarer::Serialize

  hbs_serializable :favorites, :merge => true

  has_many :favorites
end

# access in controller
class UsersController < ApplicationController

  def active
    @users = User.where('active = 1').select('name, email')
    @users.to_hbs # => only name, email and favorites attributes are serialized
  end
end
```

In the above, we defined serialization for the `User` model to include the `:favorites` attribute, which is available because of the `has_many` relationship
to the `Favorite` model. Additionally, we specified that serialization should merge model default attributes with the specified attributes, by setting `:merge => true` .

This will result in merging `self.attributes` and `self.favorites` on any instance of the `User` model when calling the `to_hbs` method on it.

To only serialize the specified attributes, call `hbs_serializable` with `:merge => false` .

Invokation format for `hbs_serializable` is:

```ruby
hbs_serializable :attr1, :attr2, :attr3 ...., :merge => true/false
```

By default, `hbs_serializable` will operate with `:merge => true` and merge instnace attributes with specified attributes.

## Helpers

Handlerbars has built in support for helper function registration, which is great for client-side rendering, but alas requires a
bit of extra work for server-side rendering.

Lets assume you have registered Handlebars helpers reside under `app/assets/javascripts/helpers/link.js`
that might look something like this:

```javascript
Handlebars.registerHelper('link_to', function(context) {
  return '<a href="/users/' + context.id + '">' + context.name + '</a>';
});
```

On the client-side, you might add to the asset pipeline like this:

```javascript
//= require handlebars/runtime
//= require helpers/link.js
```

To use the same helper on the server-side, you'll need to configre Handlebarer like so:

```ruby
Handlerbarer.configure do |config|
  config.helpers_path = Rails.root.join('app','assets','javascripts','helpers')
end
```

When rendering your Handlebars template server-side, Handlerbarer will look for any Javascript file in the helpers path and
include it in the rendering context.

Please note that at the moment, Handlebarer only supports Javascript helper files rather than both Javascript and CoffeeScript.

## Configuration

Its recommended to configure Handlerbarer inside a Rails initializer so that configuration is defined at boot time.

Assuming we have an initializer `app/config/initializers/handlebarer.rb` it should include:

```ruby
Handlerbarer.configure do |config|
  # tell Handlebarer where to find your Handlebars helpers
  config.helpers_path = Rails.root.join('app','assets','javascripts','helpers')
  # make your client-side views directory discoverable to Rails
  config.views_path = Rails.root.join('app','assets','javascripts','views')
end
```

## Asset Pipeline

In case your Rails asset pipeline is configured **not** to load the entire Rails environment when calling `rake assets:precompile`, you should include Handlerbarer's configuration initalizer in your Rakefile.

Simply add `require File.expand_path('../config/initializers/handlebarer', __FILE__)` before `require File.expand_path('../config/application', __FILE__)` in your Rakefile, and ensure Handlerbarer is properly configured when your assets are precompiled

# License

Copyright (c) 2013 Zohar Arad <zohar@zohararad.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
