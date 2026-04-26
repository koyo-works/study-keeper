return unless Gem::Version.new(OpenSSL::VERSION) >= Gem::Version.new("3.0.0")

require "webpush/encryption"
require "webpush/vapid_key"

module Webpush
  class VapidKey
    def initialize
      @curve = OpenSSL::PKey::EC.generate("prime256v1")
    end

    def self.from_keys(public_key, private_key)
      pub_bytes  = Webpush.decode64(public_key)
      priv_bytes = Webpush.decode64(private_key)

      group    = OpenSSL::PKey::EC::Group.new("prime256v1")
      priv_bn  = OpenSSL::BN.new(priv_bytes, 2)
      pub_point = OpenSSL::PKey::EC::Point.new(group, OpenSSL::BN.new(pub_bytes, 2))

      der = OpenSSL::ASN1::Sequence([
        OpenSSL::ASN1::Integer(1),
        OpenSSL::ASN1::OctetString(priv_bn.to_s(2).rjust(32, "\x00")),
        OpenSSL::ASN1::ASN1Data.new(
          [OpenSSL::ASN1::ObjectId("prime256v1")],
          0, :CONTEXT_SPECIFIC
        ),
        OpenSSL::ASN1::ASN1Data.new(
          [OpenSSL::ASN1::BitString(pub_point.to_octet_string(:uncompressed))],
          1, :CONTEXT_SPECIFIC
        )
      ]).to_der

      instance = allocate
      instance.instance_variable_set(:@curve, OpenSSL::PKey::EC.new(der))
      instance
    end
  end

  module Encryption
    def encrypt(message, p256dh, auth)
      assert_arguments(message, p256dh, auth)

      group_name = "prime256v1"
      salt = Random.new.bytes(16)

      server = OpenSSL::PKey::EC.generate(group_name)
      server_public_key_bn = server.public_key.to_bn

      group = OpenSSL::PKey::EC::Group.new(group_name)
      client_public_key_bn = OpenSSL::BN.new(Webpush.decode64(p256dh), 2)
      client_public_key = OpenSSL::PKey::EC::Point.new(group, client_public_key_bn)

      shared_secret = server.dh_compute_key(client_public_key)
      client_auth_token = Webpush.decode64(auth)

      info = "WebPush: info\0" + client_public_key_bn.to_s(2) + server_public_key_bn.to_s(2)
      prk = HKDF.new(shared_secret, salt: client_auth_token, algorithm: "SHA256", info: info).next_bytes(32)
      content_encryption_key = HKDF.new(prk, salt: salt, info: "Content-Encoding: aes128gcm\0").next_bytes(16)
      nonce = HKDF.new(prk, salt: salt, info: "Content-Encoding: nonce\0").next_bytes(12)

      ciphertext = encrypt_payload(message, content_encryption_key, nonce)
      serverkey16bn = convert16bit(server_public_key_bn)
      raise ArgumentError, "encrypted payload is too big" if ciphertext.bytesize > 4096

      "#{salt}" + [ciphertext.bytesize].pack("N*") + [serverkey16bn.bytesize].pack("C*") + serverkey16bn + ciphertext
    end
  end
end
