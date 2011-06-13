#!/usr/bin/ruby

require 'rubygems'
require 'rb-inotify'
require 'pp'

WDIR = "/tmp"
START_TIME = Time.now


def process_hash(a)
  a.delete_if{|x,y| y[:flags].include?(:delete) }#or y[:flags].include?(:moved_to) }
end

def commit_write(hash)
  pp hash.to_a.select{|file|
    file[1][:mtime] > file[1][:old_mtime]
  }
  puts "--"
  pp H
  puts "----------------"
end

H = {}

monitor_thread = Thread.new {

  notifier = INotify::Notifier.new
  notifier.watch(WDIR,:all_events){|x|
    begin
      unless x.flags.include?(:isdir)
        if File.exist?("#{WDIR}/#{x.name}")
          old_mtime = 0
          if H[x.name]
            old_mtime = H[x.name][:mtime]
          end
          H[x.name] = {:flags => x.flags, :mtime => File.mtime("#{WDIR}/#{x.name}").to_i, :old_mtime => old_mtime }
        else
          H.delete(x.name)
        end
      end
    rescue 
    end
  }

  while true
    if IO.select([notifier.to_io], [], [], 0.0001)
      notifier.process
    end
    process_hash(H)
  end
}

printer_thread = Thread.new {
  while true
    sleep (3)
    process_hash(H)
    commit_write(H)
  end
}

monitor_thread.join
printer_thread.join

