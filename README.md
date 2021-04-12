
## Generate Certificate using OpenSSL
```sh
  openssl genrsa 2048 > private.pem
  openssl req -x509 -new -key private.pem -out public.pem
  openssl pkcs12 -export -in public.pem -inkey private.pem -out mycert.pfx
```