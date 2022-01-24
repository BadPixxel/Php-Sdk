<?php

/*
 *  Copyright (C) BadPixxel <www.badpixxel.com>
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  For the full copyright and license information, please view the LICENSE
 *  file that was distributed with this source code.
 */

namespace BadPixxel\PhpSdk\Task;

use BadPixxel\PhpSdk\Helper\ShellRunner;
use BadPixxel\PhpSdk\Helper\SplashFaker;
use GrumPHP\Configuration\GrumPHP;
use GrumPHP\Formatter\ProcessFormatterInterface as Formater;
use GrumPHP\Process\ProcessBuilder;
use GrumPHP\Runner\TaskResult;
use GrumPHP\Runner\TaskResultInterface;
use GrumPHP\Task\AbstractExternalTask;
use GrumPHP\Task\Context\ContextInterface;
use GrumPHP\Task\Context\GitPreCommitContext;
use GrumPHP\Task\Context\RunContext;
use GrumPHP\Util\Paths;
use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Yaml\Exception\ParseException;
use Symfony\Component\Yaml\Yaml;

/**
 * Grumphp Task: Jekyll Documentation Builder
 *
 * Generate Static Documentation Website for Github|Gitlab Pages
 *
 * @SuppressWarnings(PHPMD.CouplingBetweenObjects)
 */
class DocumentationBuilder extends AbstractExternalTask
{
    /**
     * @var array
     */
    private $options;

    /**
     * @var Paths
     */
    private $paths;

    /**
     * @param ProcessBuilder $processBuilder
     * @param Formater       $formatter
     * @param Paths          $path
     */
    public function __construct(ProcessBuilder $processBuilder, Formater $formatter, Paths $path)
    {
        parent::__construct($processBuilder, $formatter);

        $this->paths = $path;
    }

    /**
     * @return string
     */
    public function getName(): string
    {
        return 'build-docs';
    }

    /**
     * @return OptionsResolver
     */
    public static function getConfigurableOptions(): OptionsResolver
    {
        $resolver = new OptionsResolver();
        $resolver->setDefaults(
            array(
                'enabled' => true,
                // Path of Jekyll Base Site (Relative to Sdk)
                'source_folder' => "/Resources/jekyll",
                // Path of Final Docs (Relative to Project)
                'target_folder' => '/public',
                // Path of Modules Documentations Contents (Relative to Sdk)
                'local_folder' => '/src/Resources/docs',
                // Generic Contents Path (Relative to Project or Sdk)
                'generic_folder' => array("/src/Resources/contents", "/jekyll"),
                // Generic Contents To Add
                'generic_contents' => array(),
                // Temp Folder for Building the Site
                'build_folder' => '/.gh-pages',
            )
        );

        $resolver->addAllowedTypes('enabled', array('bool'));
        $resolver->addAllowedTypes('source_folder', array('string'));
        $resolver->addAllowedTypes('target_folder', array('string'));
        $resolver->addAllowedTypes('build_folder', array('string'));
        $resolver->addAllowedTypes('generic_folder', array('array'));
        $resolver->addAllowedTypes('generic_contents', array('array'));

        return $resolver;
    }

    /**
     * {@inheritdoc}
     */
    public function canRunInContext(ContextInterface $context): bool
    {
        return ($context instanceof GitPreCommitContext || $context instanceof RunContext);
    }

    /**
     * {@inheritdoc}
     */
    public function run(ContextInterface $context): TaskResultInterface
    {
        //====================================================================//
        // Load Task Configuration
        $this->options = $this->getConfig()->getOptions();

        //====================================================================//
        // Build Disabled => Skip this Task
        if (!$this->options["enabled"]) {
            return TaskResult::createPassed($this, $context);
        }

        //====================================================================//
        // Initialize Empty Local Class for Splash Modules
        SplashFaker::init();
        ;

        //====================================================================//
        // Init Module Build Directory
        $result = $this->initDirectory();
        if (is_string($result)) {
            return TaskResult::createFailed($this, $context, $result);
        }

        //====================================================================//
        // Copy Documentation Site Contents to Build Directory
        $result = $this->copyContents();
        if (is_string($result)) {
            return TaskResult::createFailed($this, $context, $result);
        }

        //====================================================================//
        // Execute Yarn
        $result = $this->runYarn();
        if (is_string($result)) {
            return TaskResult::createFailed($this, $context, $result);
        }

        //====================================================================//
        // Build Jekyll Configuration File
        $result = $this->buildConfig();
        if (is_string($result)) {
            return TaskResult::createFailed($this, $context, $result);
        }

        //====================================================================//
        // Execute Jekyll Bundler
        $result = $this->runBundler();
        if (is_string($result)) {
            return TaskResult::createFailed($this, $context, $result);
        }

        //====================================================================//
        // Build Final Documentation Site
        $result = $this->buildSite();
        if (is_string($result)) {
            return TaskResult::createFailed($this, $context, $result);
        }

        return TaskResult::createPassed($this, $context);
    }

    /**
     * Init Temp Build Directory
     *
     * @return null|string
     */
    private function initDirectory(): ?string
    {
        $filesystem = new Filesystem();
        //====================================================================//
        // Init Module Build Directory
        try {
            $filesystem->remove($this->getTempDirectory());
            $filesystem->mkdir($this->getTempDirectory());
        } catch (IOExceptionInterface $exception) {
            return "An error occurred while creating your directory at ".$this->getTempDirectory();
        }

        return null;
    }

    /**
     * Copy Documentation Contents to Docs Directory
     *
     * @return null|string
     */
    private function copyContents(): ?string
    {
        $filesystem = new Filesystem();

        //====================================================================//
        // Copy Jekyll Base Contents
        try {
            $filesystem->mirror($this->getJekyllSrcDirectory(), $this->getTempDirectory());
        } catch (IOExceptionInterface $exception) {
            return "An error occurred while Jekyll Base copy at ".$exception->getPath();
        }

        //====================================================================//
        // Copy Generic Contents
        foreach ($this->options["generic_contents"] as $code) {
            $contentDirs = $this->getGenericContentDirectories($code);
            if (empty($contentDirs)) {
                return "Unable to find Generic Contents for ".$code;
            }
            foreach ($contentDirs as $contentDir) {
                try {
                    $filesystem->mirror(
                        $contentDir,
                        $this->getTempDirectory(),
                        null,
                        array("override" => true)
                    );
                } catch (IOExceptionInterface $exception) {
                    return "An error occurred while Generic Contents copy at ".$exception->getPath();
                }
            }
        }

        //====================================================================//
        // Copy Local Contents
        try {
            $filesystem->mirror(
                $this->getLocalContentsDirectory(),
                $this->getTempDirectory(),
                null,
                array("override" => true)
            );
        } catch (IOExceptionInterface $exception) {
            return "An error occurred while Local Contents copy at ".$exception->getPath();
        }

        return null;
    }

    /**
     * Execute Yarn Install
     *
     * @return null|string
     */
    private function runYarn(): ?string
    {
        //====================================================================//
        // Check if Yarn is Installed
        if (null !== ShellRunner::run("yarn --version")) {
            return "Yarn is Not Installed!! But sorry it's required...";
        }
        //====================================================================//
        // Prepare Shell Command
        $command = "yarn --cwd ".$this->getTempDirectory();
        $command .= " install";
        $command .= " --silent --non-interactive";
        $command .= ' --modules-folder="'.$this->getTempDirectory().'/assets/vendor" ';
        //====================================================================//
        // Execute Yarn install
        $run = ShellRunner::run($command);
        if (!is_null($run)) {
            return "Yarn install failed: ".$run;
        }

        return null;
    }

    /**
     * Execute Jekyll Bundler Install
     *
     * @return null|string
     */
    private function runBundler(): ?string
    {
        //====================================================================//
        // Check if Gem Bundler is Installed
        if (null !== ShellRunner::run("bundle --version")) {
            return "Gem Bundler is Not Installed!! But sorry it's required...";
        }
        //====================================================================//
        // Prepare Shell Command
        $command = "cd ".$this->getTempDirectory();
        $command .= " && bundle install ";
        $command .= " && bundle exec jekyll build ";
        //====================================================================//
        // Execute Gem Bundler install
        $run = ShellRunner::run($command);
        if (!is_null($run)) {
            return "Bundler Jekyll Build Failed: ".$run;
        }

        return null;
    }

    /**
     * Build Site Configuration
     *
     * @return null|string
     */
    private function buildConfig(): ?string
    {
        try {
            //====================================================================//
            // Load Generic Configuration
            /** @var array $coreConfig */
            $coreConfig = Yaml::parseFile($this->getJekyllSrcDirectory().'/_config.yml');
            //====================================================================//
            // Load Local Configuration
            /** @var array $localConfig */
            $localConfig = Yaml::parseFile($this->getLocalContentsDirectory().'/_config.yml');
            //====================================================================//
            // Load Module Splash Manifest
            $manifest = array("manifest" => null);
            if (is_file($this->getManifestPath())) {
                $manifest = array("manifest" => Yaml::parseFile($this->getManifestPath()));
            }
        } catch (ParseException $exception) {
            return "Unable to build Jekyll Configuration: ".$exception->getMessage();
        }
        //====================================================================//
        // Build Final Configuration
        $finalConfig = array_replace_recursive($coreConfig, $localConfig, $manifest);
        file_put_contents($this->getTempDirectory().'/_config.yml', Yaml::dump($finalConfig, 5));

        return null;
    }

    /**
     * Copy Compiled Site to Docs Directory
     *
     * @return null|string
     */
    private function buildSite(): ?string
    {
        $filesystem = new Filesystem();

        //====================================================================//
        // Verify Final Contents are Here
        $siteDir = $this->getTempDirectory()."/_site";
        if (!is_dir($siteDir)) {
            return "Unable to find Final Site at ".$siteDir;
        }
        //====================================================================//
        // Copy Jekyll Base Contents
        try {
            $filesystem->remove($this->getDocsDirectory());
            $filesystem->mkdir($this->getDocsDirectory());
            $filesystem->mirror($siteDir, $this->getDocsDirectory());
        } catch (IOExceptionInterface $exception) {
            return "An error occurred while Jekyll Base copy at ".$exception->getPath();
        }

        return null;
    }

    /**
     * Get Documentations Sources Directory Path
     *
     * @return string
     */
    private function getDocsDirectory(): string
    {
        return $this->paths->getProjectDir().$this->options["target_folder"];
    }

    /**
     * Get Jekyll Sources Directory Path
     *
     * @return string
     */
    private function getJekyllSrcDirectory(): string
    {
        return dirname(__DIR__).$this->options["source_folder"];
    }

    /**
     * Get Generic Contents Directory Path
     *
     * @param string $contentsDir
     *
     * @return string[]
     */
    private function getGenericContentDirectories(string $contentsDir): array
    {
        $paths = array();
        //====================================================================//
        // Walk on Generic Content Paths
        foreach ($this->options["generic_folder"] as $genericFolder) {
            //====================================================================//
            // Build List of Possible Paths
            $possiblePaths = array(
                dirname(__DIR__, 2).$genericFolder."/".$contentsDir,
                $this->paths->getProjectDir().$genericFolder."/".$contentsDir,
            );
            //====================================================================//
            // Walk on Possible Content Paths
            foreach ($possiblePaths as $possiblePath) {
                if (is_dir($possiblePath)) {
                    $paths[] = (string) realpath($possiblePath);
                }
            }
        }

        return array_unique($paths);
    }

    /**
     * Get Local Sources Directory Path
     *
     * @return string
     */
    private function getLocalContentsDirectory(): string
    {
        return $this->paths->getProjectDir().$this->options["local_folder"];
    }

    /**
     * Get Temp Build Directory Path
     *
     * @return string
     */
    private function getTempDirectory(): string
    {
        return $this->paths->getProjectDir().$this->options["build_folder"];
    }

    /**
     * Get Splash Manifest Path
     *
     * @return string
     */
    private function getManifestPath(): string
    {
        return $this->paths->getProjectDir()."/splash.yml";
    }
}
