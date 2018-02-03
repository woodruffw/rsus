require "kemal"
require "mime"

require "./rsus/*"

module RSUS
  @@config = Config.load

  post "/" do |env|
    file = env.params.files["file"]?
    auth = env.params.body["auth"]?

    next error("missing file") unless file
    next error("missing auth") unless auth
    next error("bad auth") unless @@config.token?(auth)
    next error("file too large") unless file.tmpfile.stat.size <= @@config.max_size

    upload file
  end

  error 404 do
    error("it is a mystery")
  end

  def self.slugify(file)
    prefix = Random::Secure.urlsafe_base64(@@config.slug_size)
    suffix = Mime.to_ext(file.headers["Content-Type"]) || "dat"
    "#{prefix}.#{suffix}"
  end

  def self.upload(file)
    filename = slugify file
    filepath = File.join(@@config.store, filename)
    File.open(filepath, "w") do |dest|
      IO.copy(file.tmpfile, dest)
    end

    {url: File.join(@@config.site, filename)}.to_json
  end

  def self.error(msg)
    {error: msg}.to_json
  end

  def self.run
    Kemal.run
  end
end

RSUS.run
