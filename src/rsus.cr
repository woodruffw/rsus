require "kemal"
require "mime"

require "./rsus/*"

module RSUS
  @@config = Config.load

  post "/" do |env|
    file = env.params.files["file"]?
    auth = env.params.body["auth"]?

    @@config.log(:post, {auth: auth, user: @@config.tokens[auth]?})

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
    content_type = file.headers["Content-Type"]?
    prefix = Random::Secure.urlsafe_base64(@@config.slug_size)
    suffix = if content_type.nil? || content_type == "application/octet-stream"
               uploaded_filename = file.filename

               # if the file was uploaded without a content-type (or with a useless one),
               # try to guess the suffix from the filename (and fall back to bin)
               if uploaded_filename && uploaded_filename.includes?(".")
                 uploaded_filename.split(".", 2).last
               else
                 "bin"
               end
             else
               # otherwise, try to get the extension from the content-type, falling back to
               # bin if the content-type isn't known
               Mime.to_ext(content_type) || "bin"
             end

    "#{prefix}.#{suffix}".tap do |fn|
      @@config.log(:slugify, {original_name: file.filename, saved_name: fn})
    end
  end

  def self.upload(file)
    filename = slugify file
    filepath = File.join(@@config.store, filename)
    url = File.join(@@config.site, filename)

    File.open(filepath, "w") do |dest|
      IO.copy(file.tmpfile, dest)
    end

    @@config.log(:upload, {filepath: filepath, url: url})
    {url: url}.to_json
  end

  def self.error(msg)
    @@config.log(:error, {message: msg})
    {error: msg}.to_json
  end

  def self.run
    @@config.log(:startup)
    Kemal.run
  end
end

RSUS.run
