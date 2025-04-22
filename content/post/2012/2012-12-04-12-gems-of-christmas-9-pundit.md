---
author: Mike Perham
categories:
- Rails
date: 2012-12-04T00:00:00Z
title: '12 Gems of Christmas #9 -- pundit'
url: /2012/12/04/12-gems-of-christmas-9-pundit/
---

When it comes to authorization, Ryan Bates' CanCan gem is the 800 lb gorilla that most Rails apps use. [pundit][1] is the latest gem from Jonas Nicklas (author of Carrierwave and Capybara) with some interesting ideas that you might like. Pundit uses code conventions along with a plain old Ruby API to make for a very simple implementation. First, write a policy for each type of model you wish to authorize:

```ruby
class PostPolicy &lt; Struct.new(:user, :post)
  def create?
    user.admin? or not post.published?
  end
end
```

Then in the corresponding controller, use `authorize` to verify permissions:

```ruby
def create
  @post = Post.new(params[:post])
  authorize @post
  if @post.save
    redirect_to @post
  else
    render :new
  end
end
```

Pundit assumes the current user is available via `current_user` within the controller and passes it to your policy along with the model instance.

There's a few more features to be discovered over on the GitHub README but the entire library is less than 200 lines of code; it's beautifully succinct.

Next up, I'll cover a handy little gem for creating nice PDF files without having to dive into the complexities of the PDF format.

 [1]: https://github.com/elabs/pundit
