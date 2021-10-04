<?php

/*
 *  Copyright (C) 2021 BadPixxel <www.badpixxel.com>
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  For the full copyright and license information, please view the LICENSE
 *  file that was distributed with this source code.
 */

namespace BadPixxel\PhpSdk\Helper;

use Composer\Console\Application as ComposerApp;
use Exception;
use Symfony\Component\Console\Input\ArrayInput;

/**
 * Execute Composer Updates During Grumphp Tasks
 */
class Composer
{
    /**
     * Execute Module Composer Update
     *
     * @param string $workingDir
     * @param array  $options
     *
     * @return null|string
     */
    public static function update(string $workingDir, array $options = array()): ?string
    {
        //====================================================================//
        // Prepare Command Input Array
        $input = new ArrayInput(
            self::buildUpdateOptions($workingDir, $options)
        );

        try {
            //====================================================================//
            // Execute Composer Build
            $composer = new ComposerApp();
            $composer->setAutoExit(false);
            $composer->run($input);
            //====================================================================//
            // Add .htaccess to Build directory
            $htaccessContent = file_get_contents(dirname(__DIR__)."/Resources/build/.htaccess");
            $app = $composer->getComposer();
            if (is_null($app)) {
                throw new Exception('Could not connect to Composer');
            }
            $vendorPath = $app->getConfig()->get("vendor-dir");
            $htaccessPath = $vendorPath.DIRECTORY_SEPARATOR.'.htaccess';
            if (!file_exists($htaccessPath)) {
                if (!is_writable($vendorPath)) {
                    throw new Exception('Could not write into module vendor folder');
                }

                file_put_contents($htaccessPath, $htaccessContent);
            }
        } catch (Exception $exception) {
            return "Composer Update Failed ".$exception->getMessage();
        }

        return null;
    }

    /**
     * Build Options Array for Composer
     *
     * @param string $workingDir
     * @param array  $options
     *
     * @return array
     */
    private static function buildUpdateOptions(string $workingDir, array $options = array()): array
    {
        //====================================================================//
        // Prepare Base Composer Options
        $baseOptions = array(
            'command' => 'update',
            "--working-dir" => $workingDir,
            "--quiet" => true,
            "--no-interaction" => true,
        );
        //====================================================================//
        // Merge with User Options
        return (array) array_replace_recursive($baseOptions, $options);
    }
}
