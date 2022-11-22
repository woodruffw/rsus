require "yaml"

module RSUS
  class Config
    include YAML::Serializable

    CONFIG_FILE = "config.yml"

    @[YAML::Field]
    property environment : String

    @[YAML::Field]
    property site : String

    @[YAML::Field]
    property max_size : Int32

    @[YAML::Field]
    property store : String

    @[YAML::Field]
    property slug_size : Int32

    @[YAML::Field]
    property tokens : Hash(String, String)

    @[YAML::Field]
    property logfile : String

    def self.load : Config
      from_yaml(File.read(CONFIG_FILE)).tap do |c|
        c.store = File.join Kemal.config.public_folder, c.store
        Dir.mkdir_p(c.store) unless Dir.exists?(c.store)
        Kemal.config.env = c.environment
      end
    end

    def token?(auth)
      tokens.has_key?(auth)
    end

    def log(event, body = {} of String => String)
      Logger.log(logfile, {event: event, time: Time.utc.to_unix, body: body})
    end
  end
end
