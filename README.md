Exeshnik
===========

Provides a set of classes, methods, and helpers to ease development of exe.ru applications with Rails.

Installation
------------

In order to install Exeshnik you should add it to your Gemfile:

    gem 'exeshnik'

Usage
-----

**Accessing Current User**

Current Exeshnik user data can be accessed using the ```current_exe_user``` method:

    class UsersController < ApplicationController
      def profile
        @user = User.find_by_social_id(current_exe_user.uid)
      end
    end

This method is also accessible as a view helper.

**Application Configuration**

In order to use Exeshnik you should set a default configuration for your Exeshnik application. The config file should be placed at RAILS_ROOT/config/exeshnik.yml

Sample config file:

    development:
      app_id: ...
      app_secret: ...
      callback_domain: ...

    test:
      app_id: ...
      app_secret: ...
      callback_domain: ...
