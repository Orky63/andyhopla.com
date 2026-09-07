# andyhopla.com production infrastructure

Production delivery is unconditional. There is no staging variable or delivery toggle.

## Architecture

- Private, versioned, SSE-S3 encrypted S3 content bucket in `eu-west-2`, with all public access blocked and ACLs disabled.
- CloudFront uses the S3 regional REST origin through OAC with SigV4 signing. The bucket policy permits reads only from this distribution and denies insecure transport.
- Apex and `www` aliases, HTTPS redirect, TLSv1.2_2021, GET/HEAD, compression, IPv6, HTTP/2 and HTTP/3, and PriceClass_100.
- AWS managed CachingOptimized policy. The root object is `index.html`; missing-origin 403 responses become 404 using `/404.html`, without a homepage fallback.
- A CloudFront Function permanently redirects `www` to the HTTPS apex, preserving paths and query values.
- Response headers: nosniff, DENY framing, strict-origin-when-cross-origin and HSTS max-age=300. No CSP, preload or includeSubDomains.
- ACM in `us-east-1` covers apex and `www`. Keep the Route 53 validation CNAMEs for renewal.
- Route 53 hosts the four apex/www A and AAAA aliases. Domain registration remains with Hostinger; production nameservers have been switched to Route 53.

## Backend and planning

Use `AWS_PROFILE=nextfoundry` and confirm account `387344700059` before planning. The backend in `backend.tf` uses:

- Bucket: `nextfoundry-terraform-state-387344700059`
- Region: `us-east-1`
- Key: `andyhopla/prod/terraform.tfstate`
- Encryption and native S3 lockfile locking enabled

Do not use another project's state key. Terraform 1.10 or later is required. Authentication comes from the normal AWS credential chain; do not store credentials in configuration.

From this directory:

```sh
terraform fmt -recursive
terraform validate
AWS_PROFILE=nextfoundry terraform plan
```

Review every plan before any separately authorised apply. Do not pass the former staging flag. Resource destruction, replacement or unexpected production changes require investigation.

## State address migration

`moved.tf` maps the six previously counted delivery resources from `[0]` addresses to singleton addresses. These declarations preserve their existing AWS identities; they do not recreate resources. The four Route 53 alias instances keep their existing domain keys and addresses.

Keep the moved blocks for compatibility with state that still uses the old addresses. A plan previews the moves; only a separately authorised apply persists them to remote state. No manual state move or import is needed.

## Website deployment and operations

Website objects are deployed separately from Terraform. Only deploy `index.html`, `404.html`, `pages/`, `css/`, `js/`, `images/`, `favicon.ico` and `favicon.svg`. Never upload repository, infrastructure, state or documentation files. GitHub Actions is not configured here.

Preserve HTML update-friendly caching and suitable asset metadata. Verify pages, assets, HTTPS, www redirects, missing-path 404 responses and denied anonymous S3 access after changes.

Do not destroy delivery resources as a rollback mechanism. DNS rollback or retirement of Hostinger hosting requires a separate reviewed decision.
