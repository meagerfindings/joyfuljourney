namespace :pwa do
  desc "Generate PWA icons"
  task :generate_icons => :environment do
    require 'mini_magick'
    
    # Create base icon with ImageMagick
    sizes = [96, 192, 512]
    
    sizes.each do |size|
      MiniMagick::Tool::Convert.new do |convert|
        convert.size "#{size}x#{size}"
        convert.canvas "#4A90E2"
        convert.fill "white"
        convert.font "Arial-Bold"
        convert.pointsize (size * 0.3).to_i
        convert.gravity "center"
        convert.annotate "+0+0", "JJ"
        convert.stroke "white"
        convert.strokewidth (size * 0.05).to_i
        convert.fill "none"
        convert.draw "rectangle #{size * 0.1},#{size * 0.1} #{size * 0.9},#{size * 0.9}"
        convert << Rails.root.join("public", "icon-#{size}.png").to_s
      end
      
      puts "Generated icon-#{size}.png"
    end
    
    puts "PWA icons generated successfully!"
  rescue LoadError
    puts "This task requires mini_magick gem. Add it to your Gemfile."
    puts "Alternatively, open /public/generate_icons.html in a browser and save the images manually."
  end
end