require 'rubygems'
require 'rack'
require 'erb'
require 'yaml'
require 'logger'

begin; require 'git_store'; rescue LoadError; end

require 'kontrol/helpers'
require 'kontrol/template'
require 'kontrol/application'
require 'kontrol/builder'
require 'kontrol/router'
