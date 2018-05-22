guard :shell do
  watch %r{(lib|source|system|templates)/.*} do |match|
    puts "#{match[0]} updated"
    `./bin/build --no-clean --no-assets`
  end
end
