module Ti
  module Utils

    def create_new_file(name, file=nil)
      log "Creating #{name}"
      contents = file.nil? ? '' : File.read(file)
      unless File.file?(location.join(name))
        File.open(location.join(name), 'w') { |f| f.write(contents) }
      end
    end

    def get_app_name
      config  = File.open("tiapp.xml")
      doc     = ::Nokogiri::XML(config)
      config.close
      doc.xpath('ti:app/name').text
    end

    def remove_files(*files)
      files.each do |file|
        log "Removing #{file} file."
        FileUtils.rm(location.join(file))
      end
    end


    def touch(*filenames)
      filenames.each do |filename|
        log "Creating #{filename} file."
        FileUtils.touch(location.join(filename))
      end
    end


    def create_directories(*dirs)
      dirs.each do |dir|
        log "Creating the #{dir} directory."
        FileUtils.mkdir_p(location.join(dir))
      end
    end


    def remove_directories(*names)
      names.each do |name|
        log "Removing #{name} directory."
        FileUtils.rm_rf(location.join(name))
      end
    end


    def create_with_template(name, template_location, contents={})
      template    = templates("#{template_location}.erb")
      eruby       = Erubis::Eruby.new(File.read(template))
      File.open(location.join(name.gsub(/^\//, '')), 'w') { |f| f.write(eruby.result(contents))}
    end

    def append_to_router(name, type)
      router_contents = File.read(location.join("app/app.coffee"))

      if router_contents.include?(type.capitalize)
        contents = router_contents.sub( "#{type.capitalize}:", "#{type.capitalize}:\n    #{name.capitalize}: {}" )
      else
        contents = router_contents.sub("#{get_app_name} =", "#{get_app_name} =\n\t#{type.capitalize}:\n    #{name.capitalize}: {}\n")
      end
      File.open(location.join("app/app.coffee"), 'w') { |f| f.write(contents) }
    end 


    def templates(path)
      ::Ti.root.join('ti/templates').join(path)
    end


    def log(msg)
      ::Ti::Logger.report(msg)
    end

    def error(msg)
      ::Ti::Logger.error(msg)
    end

    def base_location
      @location ||= Pathname.new(Dir.pwd)
    end
    alias_method :location, :base_location


    def underscore(string)
      string.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

  end
end
