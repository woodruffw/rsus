require "yaml"

module RSUS
  class Config
    CONFIG_FILE = "config.yml"

    YAML.mapping(
      site: String,
      max_size: Int32,
      store: String,
      slug_size: Int32,
      tokens: Hash(String, String),
    )

    def self.load : Config
      from_yaml(File.read(CONFIG_FILE)).tap do |c|
        c.store = File.join Kemal.config.public_folder, c.store
        Dir.mkdir_p(c.store) unless Dir.exists?(c.store)
      end
    end

    def token?(auth)
      tokens.has_key?(auth)
    end
  end
end
