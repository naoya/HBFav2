module RmWsse
  def wsse_header(user, password)
    formatter = NSDateFormatter.new.tap do |f|
      f.setDateFormat("yyyy-MM-dd'T'HH:mmZZZ")
    end

    rnd    = Random.new
    now    = formatter.stringFromDate(NSDate.new)
    nonce  = RmDigest::SHA1.hexdigest(now + rnd.rand.to_s)
    digest = RmDigest::SHA1.digest(nonce + now + password)

    "UsernameToken Username=\"#{user}\", PasswordDigest=\"#{digest.base64String}\", Nonce=\"#{nonce.base64String}\", Created=\"#{now}\""
  end
end
