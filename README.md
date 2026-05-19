# BadPixxel Php-Sdk

Standardized development kit for BadPixxel & SplashSync PHP packages.

This SDK bundles **all the quality, CI/CD and build tooling** for a PHP project: just install it as `require-dev` and you get a complete GrumPHP configuration, multi-version Docker images, a ready-to-use Makefile and packaging tasks.

```bash
composer require --dev badpixxel/php-sdk
```

---

## Features

### 1. Ready-to-use GrumPHP quality suite

Centralized GrumPHP configuration that you import from your `grumphp.yml`:

```yaml
imports:
    - "vendor/badpixxel/php-sdk/grumphp/generic.yml"
    - "vendor/badpixxel/php-sdk/grumphp/extras.yml"  # optional: module/docs build
```

Bundled and preconfigured tools:

| Category        | Tools                                                     |
|-----------------|-----------------------------------------------------------|
| **Lint**        | `phplint`, `jsonlint`, `yamllint`, `twigcs`, `composer`   |
| **Style**       | `phpcs` (PSR-12), `phpcsfixer`, `phpmd`, `phpcpd`         |
| **Analysis**    | `phpstan` (level 9 by default)                            |
| **Git hooks**   | `git_blacklist` (blocks `var_dump`, `dump(`, `print_r`…)  |

Shipped test suites:

- `travis`   — full suite executed in CI
- `csfixer`  — PSR-12 compliance
- `phpstan`  — static analysis
- `splash`   — module + documentation build

### 2. Shared code standards

Plug-and-play BadPixxel / SplashSync rule sets:

- **PHP-CS-Fixer**: `phpcs/cs.badpixxel.php`, `cs.splashsync.php`, `cs.immopop.php`
- **PHPMD**: `phpmd/phpmd.xml`
- **PHPStan**: `phpstan/badpixxel.neon`, `splashsync.neon`, plus Symfony variants

Switch between profiles with a single parameter:

```yaml
parameters:
    mode: "badpixxel"   # or splashsync, immopop…
    stan-level: 9
```

### 3. Ready-to-use Makefile

Include it in your project's Makefile:

```makefile
include vendor/badpixxel/php-sdk/make/sdk.mk
```

Available targets:

| Target          | Effect                                                   |
|-----------------|----------------------------------------------------------|
| `make lint`     | Run all linters (composer, php, json, yaml, twig)        |
| `make style`    | Run all style checks (cs, csfixer, md, cpd)              |
| `make stan`     | Run PHPStan                                              |
| `make quality`  | Run `lint` + `style` + `stan` in a row                   |
| `make up/stop`  | Start/stop the project's Docker containers               |
| `make cc`       | Clear the Symfony cache on every container               |

### 4. Multi-version PHP Docker images

Official images published on:

- `registry.gitlab.com/badpixxel-projects/php-sdk:php-X.Y`
- `splashsync/php-sdk:php-X.Y`

Available versions: **PHP 7.2 → 8.5**, with `-apache` variants (8.2/8.3/8.4) and a `jekyll` image for docs.

Highlights:

- Based on `dunglas/frankenphp` (PHP 8.x) with embedded Caddy
- Preinstalled extensions: `intl`, `zip`, `soap`, `opcache`, `apcu`, `xml`, `bcmath`, `pcntl`, `exif`, `xsl`, `sockets`, `ftp`, `gd`, `imagick`, `pdo_mysql`, `pdo_sqlite`, `mongodb`
- Composer 2 included
- CLI tools: `git`, `make`, `curl`, `wget`, `unzip`, `openssh`

### 5. Multi-PHP `docker-compose.yml`

A single file to test your code against every PHP version in parallel:

```bash
make up                                  # start all containers
make all COMMAND="composer update -q"    # run the command on every container
make verify                              # run grumphp (travis + csfixer + phpstan) everywhere
```

### 6. Reusable GitLab CI pipeline

The SDK's `.gitlab-ci.yml` provides the canonical skeleton:

- **Docker** stage: build & push the PHP images (triggered on `docker/**` changes)
- **Quality** stage: run GrumPHP against every supported PHP version
- **Builds** stage: generate the Jekyll documentation site for GitLab Pages

Since the images are public, any project can reuse them:

```yaml
tests:php-8.4:
    image: registry.gitlab.com/badpixxel-projects/php-sdk:php-8.4
    script:
        - composer update --prefer-dist --no-interaction
        - cat vendor/badpixxel/php-sdk/ci/grumphp.sh | sh
```

### 7. Custom GrumPHP tasks

Exposed through the `BadPixxel\PhpSdk\Extension\Loader` extension:

- **`build-module`** — Automatically packages the module as an installable ZIP archive
  (`BadPixxel\PhpSdk\Task\ModuleBuilder`)
- **`build-docs`** — Generates the Jekyll documentation site for GitLab/GitHub Pages
  (`BadPixxel\PhpSdk\Task\DocumentationBuilder`)

Enabled via the `splash` testsuite:

```bash
vendor/bin/grumphp run --testsuite=splash
```

### 8. CI/CD scripts

Reusable shell scripts in `ci/` and `toolkit/`:

- `ci/composer.sh`, `ci/grumphp.sh`, `ci/verify.sh`, `ci/after.sh`
- `toolkit/build.sh`, `toolkit/phpunit.sh`, `toolkit/manifest.sh`
- `symfony/install.sh`, `symfony/configure.sh`, `symfony/deploy.sh`

---

## Quick start

```bash
# 1. Install the SDK
composer require --dev badpixxel/php-sdk

# 2. Create the project's grumphp.yml
cat > grumphp.yml <<EOF
parameters:
    core_dir: "vendor/badpixxel/php-sdk"
imports:
    - "vendor/badpixxel/php-sdk/grumphp/generic.yml"
EOF

# 3. Wire up the Makefile
echo 'include vendor/badpixxel/php-sdk/make/sdk.mk' >> Makefile

# 4. Check code quality
make quality
```

---

## Requirements

- **PHP 8.1+**
- Composer 2
- Docker + Docker Compose (for the multi-version workflows)

## Documentation

Full configuration guide: [Php Sdk Doc](https://badpixxel-projects.gitlab.io/Php-Sdk)

## License

MIT — see [LICENSE](LICENSE).

## Contributing

Pull requests are welcome.