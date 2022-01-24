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

use BadPixxel\PhpSdk\Helper\Composer;
use BadPixxel\PhpSdk\Helper\SplashFaker;
use BadPixxel\PhpSdk\Helper\ZipBuilder;
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

/**
 * GrumPhp Task: BadPixxel Php Module Builder
 *
 * Generate Installable Zip file for Module
 *
 * @SuppressWarnings(PHPMD.CouplingBetweenObjects)
 */
class ModuleBuilder extends AbstractExternalTask
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
        return 'build-module';
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
                'source_folder' => "/",
                'target_folder' => '/build',
                'build_folder' => '',
                'build_file' => 'my-module.x.y.z',
                'composer_run' => true,
                'composer_file' => "composer.json",
                'composer_options' => array("--no-dev" => true),
            )
        );

        $resolver->addAllowedTypes('enabled', array('boolean'));
        $resolver->addAllowedTypes('source_folder', array('string'));
        $resolver->addAllowedTypes('target_folder', array('string'));
        $resolver->addAllowedTypes('build_folder', array('string'));
        $resolver->addAllowedTypes('build_file', array('string'));
        $resolver->addAllowedTypes('composer_run', array('boolean'));
        $resolver->addAllowedTypes('composer_file', array('string'));
        $resolver->addAllowedTypes('composer_options', array('array'));

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
        // Initialize Empty Local Class for Splash Modules
        SplashFaker::init();

        //====================================================================//
        // Build Disabled => Skip this Task
        if (!$this->options["enabled"]) {
            return TaskResult::createPassed($this, $context);
        }

        //====================================================================//
        // Init Module Build Directory
        $result = $this->initDirectory();
        if (is_string($result)) {
            return TaskResult::createFailed($this, $context, $result);
        }

        //====================================================================//
        // Copy Module Contents to Build Directory
        $result = $this->copyContents();
        if (is_string($result)) {
            return TaskResult::createFailed($this, $context, $result);
        }

        //====================================================================//
        // Execute Composer
        $result = $this->runComposer();
        if (is_string($result)) {
            return TaskResult::createFailed($this, $context, $result);
        }

        //====================================================================//
        // Build Module Archive
        $result = $this->buildModule();
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
            return "An error occurred while creating your directory at ".$exception->getPath();
        }

        return null;
    }

    /**
     * Copy Module Contents to Temp Build Directory
     *
     * @return null|string
     */
    private function copyContents(): ?string
    {
        $filesystem = new Filesystem();

        //====================================================================//
        // Copy Module Contents
        try {
            $filesystem->mirror($this->getModuleDirectory(), $this->getModuleTempDirectory());
        } catch (IOExceptionInterface $exception) {
            return "An error occurred while module contents copy at ".$exception->getPath();
        }

        //====================================================================//
        // Copy Module Composer JSON to Build Directory
        if (!empty($this->options["composer_file"])) {
            $composerPath = $this->paths->getProjectDir()."/".$this->options["composer_file"];
            if (!$filesystem->exists($composerPath)) {
                return "Unable to find composer.json at ".$composerPath;
            }
            //====================================================================//
            // Copy Module Contents
            try {
                $filesystem->copy($composerPath, $this->getTempDirectory()."/composer.json");
            } catch (IOExceptionInterface $exception) {
                return "An error occurred while copy composer.json contents to ".$exception->getPath();
            }
        }

        return null;
    }

    /**
     * Execute Module Composer
     *
     * @return null|string
     */
    private function runComposer(): ?string
    {
        //====================================================================//
        // Check if Composer JSON is Required
        if (empty($this->options["composer_run"]) || empty($this->options["composer_file"])) {
            return null;
        }

        //====================================================================//
        // Execute Composer Update
        return Composer::update($this->getTempDirectory(), $this->options["composer_options"]);
    }

    /**
     * Build Module Archive to Build Directory
     *
     * @return null|string
     */
    private function buildModule(): ?string
    {
        return ZipBuilder::build($this->getBuildPath(), array(
            $this->options["build_folder"] => $this->getModuleTempDirectory()
        ));
    }

    /**
     * Get Temp Build Directory Path
     *
     * @return string
     */
    private function getTempDirectory(): string
    {
        return sys_get_temp_dir().$this->options["target_folder"];
    }

    /**
     * Get Module Directory Path
     *
     * @return string
     */
    private function getModuleDirectory(): string
    {
        return $this->paths->getProjectDir().$this->options["source_folder"];
    }

    /**
     * Get Module Temp Directory Path
     *
     * @return string
     */
    private function getModuleTempDirectory(): string
    {
        return sys_get_temp_dir().$this->options["target_folder"].$this->options["source_folder"];
    }

    /**
     * Get Build File Path
     *
     * @return string
     */
    private function getBuildPath(): string
    {
        return $this->paths->getProjectDir()."/build/".$this->options["build_file"].".zip";
    }
}
