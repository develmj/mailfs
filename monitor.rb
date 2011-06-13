#!/usr/bin/ruby

require 'rubygems'
require 'rb-inotify'
require 'pp'
require 'thread'

WDIR = "/home/mj/torture/temp"
START_TIME = Time.now
H = {}
semaphore = Mutex.new
cv = ConditionVariable.new

def process_hash(a)
  a.delete_if{|x,y| y[:flags].include?(:delete) }#or y[:flags].include?(:moved_to) }
end

def commit_write(hash)
  selected = hash.to_a.select {|file|
    file[1][:mtime] > file[1][:old_mtime]
  }
  if selected.length > 0
    semaphore.synchronize {
      cv.wait(semaphore)  
      selected.each {|x|
        puts "Processed: #{x[0]}"
        hash.delete(x[0])
      }
    }
  end
  puts "--"
  pp H
  puts "----------------"
end


monitor_thread = Thread.new {

  notifier = INotify::Notifier.new
  notifier.watch(WDIR,:all_events){|x|
    begin
      unless x.flags.include?(:isdir)
        if File.exist?("#{WDIR}/#{x.name}")
          old_mtime = 0
          mtime = File.mtime("#{WDIR}/#{x.name}").to_i
          old_mtime = H[x.name][:mtime] if H[x.name] and H[x.name][:mtime] < mtime
          semaphore.synchronize {
            cv.wait(semaphore)
            H[x.name] = {:flags => x.flags, :mtime => mtime, :old_mtime => old_mtime}
          }
        else
          semaphore.synchronize {
            cv.wait(semaphore)
            H.delete(x.name)
          }
        end
      end
    rescue
    end
  }

  while true
    if IO.select([notifier.to_io], [], [], 0.0001)
      notifier.process
    end
    semaphore.synchronize {
      cv.wait(semaphore)
      process_hash(H)
    }
  end
}

printer_thread = Thread.new {
  while true
    sleep (3)
    commit_write(H)
  end
}

monitor_thread.join
printer_thread.join

