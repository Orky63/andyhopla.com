# Andy Hopla — personal portfolio

A static personal professional portfolio for Andy Hopla, separate from the commercial NextFoundry website. The migration from Hostinger Website Builder to AWS is complete, and andyhopla.com is live on AWS. The site contains professional background, career history, skills, project summaries, learning, planned article previews and contact links.

Built with HTML, shared CSS and vanilla JavaScript. No framework, package installation or build step is required. The visual foundation uses dark navy, light backgrounds and restrained gold accents with system fonts and no external asset dependencies.

## Structure

```text
index.html             Home page
404.html               Missing-page response
favicon.ico            Browser favicon
favicon.svg            SVG favicon
pages/about.html       Professional background
pages/experience.html  Experience overview
pages/resume.html      Career history and skills summary
pages/skills.html      Grouped professional and cloud skills
pages/projects.html    Project summaries and statuses
pages/learning.html    Certifications and ongoing development
pages/articles.html    Planned article previews and statuses
pages/contact.html     Email, LinkedIn and GitHub links
css/styles.css         Shared styles and responsive layouts
js/main.js             Responsive menu and current footer year
images/andy-hopla.jpg  Homepage portrait
infra/terraform/       Production infrastructure and state migration declarations
.gitignore             Local secrets, state and temporary-file exclusions
README.md              Project notes
```

## Local preview

Open `index.html` directly in a browser, or run the following from the project directory if Python 3 is available:

```sh
python3 -m http.server 8000
```

Then visit `http://localhost:8000`. Stop the server with Ctrl+C.

## Editing

Update each page's main content as portfolio material becomes available. Navigation and footers are intentionally plain HTML: keep these shared sections consistent across all nine pages when editing them. Each page has its own title, description and `aria-current` navigation marker. Paths are relative so the site can be previewed locally or served from a static directory.

Add future images under `images/`, with descriptive alternative text for meaningful images and explicit dimensions where possible. Shared colours and spacing rules live in `css/styles.css`.

The foundation includes semantic landmarks, a skip link, visible keyboard focus, responsive layout and a keyboard-operable mobile menu with Escape support. Navigation remains available without JavaScript. When extending it, check keyboard navigation, narrow screens, browser zoom and contrast.

## Production hosting

- Route 53 provides authoritative DNS for `andyhopla.com` and `www.andyhopla.com`; domain registration remains with Hostinger.
- CloudFront distribution `E2D9Q1YJAVZRVA` serves the site over HTTPS. Its hostname is `d1rv2koddt9wx9.cloudfront.net`.
- The private S3 bucket `andyhopla-prod-content-c23a464d04681a56f971c5279e` is in `eu-west-2`. CloudFront accesses its REST endpoint through Origin Access Control; public S3 access is blocked.
- ACM in `us-east-1` supplies the certificate for both domain names. Keep its Route 53 validation CNAMEs for renewal.
- CloudFront redirects `www` to the HTTPS apex, preserving paths and query strings. Missing objects return HTTP 404 using `404.html`, with no homepage fallback.
- Terraform under `infra/terraform/` manages the infrastructure. Production delivery is unconditional; no staging toggle is required. See [infrastructure guidance](infra/terraform/README.md) for backend and planning details.

## Content deployment

The current deployment model is a separately authorised manual AWS CLI upload of approved static files, followed by a CloudFront invalidation and verification. Normal content deployment does not require Terraform.

Deploy only `index.html`, `404.html`, the eight HTML files in `pages/`, `css/styles.css`, `js/main.js`, `images/andy-hopla.jpg`, `favicon.ico` and `favicon.svg`, preserving their paths. Do not upload the repository root recursively: infrastructure, documentation, credentials, Git data and local files must stay out of the content bucket.

HTML uses `public, max-age=0, must-revalidate`; assets use `public, max-age=3600`. Preserve appropriate content types. After deployment, verify all pages and assets, HTTPS, security headers, the path/query-preserving www redirect and missing-page 404 behaviour.

## Planned source control and GitHub Actions

The intended dedicated repository is `Orky63/andyhopla.com`, with production branch `main`. Repository creation, commits and pushes are separate steps; no repository or workflow is created by this preparation.

Future GitHub Actions deployment is planned to use an explicit website-file allowlist, temporary AWS credentials through OIDC, a dedicated least-privilege IAM role, serialised production deployments, CloudFront invalidation and post-deployment verification. Start with manual dispatch, then consider approved website changes pushed to `main`. The workflow should not run Terraform or use the existing broadly privileged deployment role.

Commit website files, Terraform configuration, `.terraform.lock.hcl`, `terraform.tfvars.example`, documentation and future workflow files. Keep credentials, private keys, local environment files, Terraform state, saved plans and `.terraform/` data out of source control. `.gitignore` is a guardrail, not a secret scanner; review the staged file list before committing and never force-add sensitive files. Any `.env.example` must contain placeholders only.

## Scope

Contact uses an email link and external profile links; there is no contact form, application backend or downloadable CV. Articles are previews only and do not link to individual article pages. No build step or server runtime is required for hosting.
