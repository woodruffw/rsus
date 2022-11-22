require "kemal"
require "mime"

require "./rsus/*"

module RSUS
  @@config = Config.load

  post "/" do |env|
    auth = nil
    meta = nil
    body = nil

    HTTP::FormData.parse(env.request) do |part|
      case part.name
      when "auth"
        auth = part.body.gets_to_end
      when "file"
        # Falling back on Content-Length is overly conservative, but
        # `part.size` is always nil for me (with a cURL client).
        size = part.size || env.request.headers["Content-Length"]

        break error("missing size") unless size
        break error("file too large") unless size.to_i <= @@config.max_size

        meta = part
        body = part.body.gets_to_end
      end
    rescue
      break error("completely busted form data")
    end

    @@config.log(:post, {auth: auth, user: @@config.tokens[auth]?})

    next error("missing file") unless meta && body

    next error("missing auth") unless auth
    next error("bad auth") unless @@config.token?(auth)

    upload meta, body
  end

  error 404 do
    error("it is a mystery")
  end

  def self.slugify(meta)
    content_type = meta.headers["Content-Type"]?
    prefix = Random::Secure.urlsafe_base64(@@config.slug_size)
    suffix = if content_type.nil? || content_type == "application/octet-stream"
               uploaded_filename = meta.filename

               # if the file was uploaded without a content-type (or with a useless one),
               # try to guess the suffix from the filename (and fall back to bin)
               if uploaded_filename && uploaded_filename.includes?(".")
                 File.extname uploaded_filename
               else
                 ".bin"
               end
             else
               exts = MIME.extensions content_type

               # otherwise, try to get the extension from the content-type, falling back to
               # bin if the content-type isn't known
               exts.first? || ".bin"
             end

    "#{prefix}#{suffix}".tap do |fn|
      @@config.log(:slugify, {original_name: meta.filename, saved_name: fn})
    end
  end

  def self.upload(meta, body)
    filename = slugify meta
    filepath = File.join(@@config.store, filename)
    url = File.join(@@config.site, filename)

    File.write(filepath, body)

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
