module RSUS
  class Logger
    def self.log(filename, blob)
      File.open(filename, mode: "a") do |file|
        file.puts(blob.to_json)
      end
    end
  end
end
