#!/usr/bin/ruby

require 'rubygems'
require 'rb-inotify'

WDIR = "/home/mj/torture/temp"

def create_notify(event)
  puts "create notify for #{event.name}"
end

def close_notify(event)
  puts "close notify for #{event.name}"
end

create_notifier = INotify::Notifier.new
create_notifier.watch(WDIR,:create){|x| create_notify(x)}

close_notifier = INotify::Notifier.new
close_notifier.watch(WDIR,:close){|x| close_notify(x)}

create_notifier.run
close_notifier.run
