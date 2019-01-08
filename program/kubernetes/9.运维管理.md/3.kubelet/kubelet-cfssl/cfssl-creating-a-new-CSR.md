
* [Creating a new CSR · cloudflare/cfssl Wiki ](https://github.com/cloudflare/cfssl/wiki/Creating-a-new-CSR)

## Creating a CSR with CFSSL

[CFSSL](https://github.com/cloudflare/cfssl) is CloudFlare's PKI
toolkit, and, among other things, it's useful for generating
Certificate Signature Requests, or CSRs. A CSR is what you give to a
Certificate Authority; they'll sign it and give you back a certificate
that you install on your webserver. CFSSL can generate both a private
key and certificate request.

In order to generate a CSR, you must provide a JSON file containing
the relevant details of your request. This JSON file looks something
like:

```json
{
    "hosts": [
        "example.com",
        "www.example.com"
    ],
    "CN": "www.example.com",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [{
        "C": "US",
        "L": "San Francisco",
        "O": "Example Company, LLC",
        "OU": "Operations",
        "ST": "California"
    }]
}
```

The `"hosts"` value is a list of the domain names which the
certificate should be valid for. The `"CN"` value is used by some CAs
to determine which domain the certificate is to be generated for
instead; these CAs will most often provide a certificate for both the
"www" (e.g. www.example.net) and "bare" (e.g. example.net) domain
names if the "www" domain name is provided. The `"key"` value in the
example is the default that most CAs support. (It may even be omitted
in this case; it is shown here for completeness.)

The `"names"` value is actually a list of name objects. Each name
object should contain at least one "C", "L", "O", "OU", or "ST" value
(or any combination of these). These values are:

* "C": country
* "L": locality or municipality (such as city or town name)
* "O": organisation
* "OU": organisational unit, such as the department responsible for
  owning the key; it can also be used for a "Doing Business As" (DBS)
  name
* "ST": the state or province

With our JSON request ready, a CSR and private key can be generated
either through the API or through the command line interface. Both
return a JSON response, but the `cfssljson` tool can be used to
convert the response to files. With the command line interface,
assuming the above certificate request is saved in "csr.json", the
command line tool should be called with

```
cfssl genkey csr.json | cfssljson -bare certificate
```

This will produce a "certificate.csr" and "certificate-key.pem" file;
the latter is the private key: it should be stored securely. The CSR
should be sent to the CA (most often by copying and pasting it into a
form on their site).

The API can also be used by making a POST request to
"/api/v1/cfssl/newkey". For example, a cURL request to a
locally-running CFSSL would look like:

```
curl -X POST -H "Content-Type: application/json" -d @csr.json \
    http://127.0.0.1:8888/api/v1/cfssl/newkey | cfssljson certificate
```

This will produce the same pair of files.

## Creating a self-signed cert

CFSSL can also create a self-signed certificate. You should be aware
that self-signed certificates present some security issues: they
cannot be revoked, and their authenticity is suspect. However, they
can be useful as a stopgap. CFSSL generates self-signed certificates
which are valid for only three months; this is just long enough for
them to serve as a temporary measure.

CFSSL's self-signer takes the same certificate request JSON as before;
using the example JSON above, saved in `csr.json`, issue the command:

```
cfssl selfsign www.example.net csr.json | cfssljson -bare selfsigned
```

This creates three files: "certificate.pem", which is the self-signed
certificate; "certificate-key.pem", which is the private key; and
"certificate.csr", which is a certificate request. Once a acceptable
CA is found, the CSR can be used to obtain a certificate signed by
that CA.
