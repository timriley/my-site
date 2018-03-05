---
title: The Atomic Shell Script
permalink: 2009/11/4/the-atomic-shell-script
published_at: 2009-11-04 06:25:00 +0000
---

The single file is the fundamental building block of unix and the smallest unit that you work with when configuring servers. So, when scripting your repetitive server tasks, keeping your code contained within a similarly singular, atomic file is a worthy goal for the simplicity and convenience that it brings. A way to achieve this for complex scripts may not always be immediately clear, but it usually both possible and worth the effort.

 [caption id="" align="alignnone" width="500.0"] ![Image from freakdog.](squarespace/images/ss/163643b2426d.jpg) Image from freakdog.[/caption]

Here's my example. When we started using [request-log-analyzer](http://github.com/wvanbergen/request-log-analyzer/) to periodically analyse the logs from one of our Rails apps, it looked like I would need to use multiple files:

- A Ruby script to call request-log-analyzer with the appropriate log file and output the data we want.
- Another Ruby file to contain the definition for our custom log analysis rules (this is a requirement for request-log-analyzer).
- An SQLite database file for storing the parsed data from the log files.

What I initially was hoping to do in a single script had become a tenuous concert of interdependent files that would no doubt require documentation for my teammates to install and maintain. With a little creativity, I overcame the issue and reduced everything to a single script, achieving simplicity of installation and use. First, I'll show you the script (abridged for this article), and then the explanation of my technique:

```
#!/usr/bin/env ruby

require 'time'
require 'fileutils'
require 'tempfile'

require 'rubygems'
require 'activesupport'
require 'sqlite3'
require 'ruport'

Tempfile.class_eval do
  # Remove the dashes that Tempfile would otherwise put in the tmpname.
  def make_tmpname(basename, n)
    case basename
    when Array
      prefix, suffix = *basename
    else
      prefix, suffix = basename, ''
    end

    t = Time.now.strftime("%Y%m%d")
    path = "#{prefix}#{t}#{$$}#{rand(0x100000000).to_s(36)}#{n}#{suffix}"
  end

  def klassify
    File.basename(self.path, '.rb').gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
  end
end

LIB_FILE = Tempfile.new(['file_format', '.rb'])
DB_FILE = Tempfile.new(['questions', '.sqlite3'])
LOG_FILES = ARGV.blank? ? Dir["/var/log/rails/rails-questions-production/rails-questions-production-#{Time.now.yesterday.strftime('%Y%m%d')}*"].first : ARGV.join(' ')

LIB_FILE.puts "class #{LIB_FILE.klassify} < RequestLogAnalyzer::FileFormat::Rails\n"
LIB_FILE.puts <<'EOF'
  line_definition :current_user do |line|
    line.regexp = /Logged in as: (.+)/
    line.captures << { :name => :email, :type => :string }
  end
end
EOF
LIB_FILE.flush

unless system("request-log-analyzer -f #{LIB_FILE.path} -d #{DB_FILE.path} #{LOG_FILES} > /dev/null")
  exit "Error running request-log-analyzer"
end

db = SQLite3::Database.new(DB_FILE.path)

all_logins_query = <<EOQ
SELECT email AS user_email FROM current_user_lines GROUP BY user_email;
EOQ

all_logins_rows = db.execute2(all_logins_query)
all_logins_table = Ruport::Data::Table.new(:column_names => all_logins_rows.shift, :data => all_logins_rows)

puts
puts "All Logins"
puts all_logins_table.as(:text, :ignore_table_width => true)

# Cleanup
LIB_FILE.close!
DB_FILE.close!
```

The trick here is that the single ruby script creates all the auxiliary files that it needs, every time it runs! Ruby's `Tempfile` is your friend, since it will take care of creating unique temporary files for you, and clean them up again when you call `#close!`.

The other trick is getting request-log-analyzer to accept a Tempfile for its custom file format definition. It expects a single class to be defined inside this file, with a name matching the name of the file. Nothing a little monkey patch to Tempfile couldn't handle. I overwrote `make_tempname` to ensure no dashes were used in the file name (these aren't allowed in the names of Ruby classes), and then I added a `#klassify` instance method to convert the filename into the kind of class name that request-log-analyzer would expect.

I'm happy with the way this his script turned out. It may be a little more involved, but the result is far more explicit, without any dependence on other moving parts. This singular, atomic script is easy to install and maintain, and requires no documentation apart from its own source code.

