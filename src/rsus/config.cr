require "yaml"

module RSUS
  class Config
    CONFIG_FILE = "config.yml"

    YAML.mapping(
      environment: String,
      site: String,
      max_size: Int32,
      store: String,
      slug_size: Int32,
      tokens: Hash(String, String),
      logfile: String,
    )

    def self.load : Config
      from_yaml(File.read(CONFIG_FILE)).tap do |c|
        c.store = File.join Kemal.config.public_folder, c.store
        Dir.mkdir_p(c.store) unless Dir.exists?(c.store)
        ENV["KEMAL_ENV"] = c.environment
      end
    end

    def token?(auth)
      tokens.has_key?(auth)
    end

    def log(event, body = {} of String => String)
      Logger.log(logfile, {event: event, time: Time.now.to_unix, body: body})
    end
  end
end
