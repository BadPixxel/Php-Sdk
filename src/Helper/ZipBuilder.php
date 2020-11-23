<?php

/*
 *  Copyright (C) 2020 BadPixxel <www.badpixxel.com>
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  For the full copyright and license information, please view the LICENSE
 *  file that was distributed with this source code.
 */

namespace BadPixxel\PhpSdk\Helper;

use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;
use ZipArchive;

/**
 * Module Zip Builder
 */
class ZipBuilder
{
    /**
     * Build Module Archive
     *
     * @param string $targetFile
     * @param array  $sources
     *
     * @return null|string
     */
    public static function build(string $targetFile, array $sources): ?string
    {
        //====================================================================//
        // Ensure Module Final Build Directory Exists
        $result = self::ensureDirectoryExists($targetFile);
        if (is_string($result)) {
            return $result;
        }

        //====================================================================//
        // Verify Zip Extension is Loaded
        if (!extension_loaded("zip")) {
            return 'PHP : Zip PHP Extension is required to build Splash PHP Module.';
        }

        //====================================================================//
        // Create the archive
        $zip = new ZipArchive();
        if (true !== $zip->open($targetFile, ZIPARCHIVE::CREATE)) {
            return "Unable to Create Zip Archive: ".$targetFile;
        }

        //====================================================================//
        // Add the files
        $filesCount = 0;
        foreach ($sources as $index => $srcDirectory) {
            $innerDirectory = is_string($index) ? $index : "";
            $filesCount += self::addDir($zip, $srcDirectory, $innerDirectory);
        }

        if ($filesCount <= 0) {
            return "No Files found for Zip Archive.";
        }

        //====================================================================//
        // Close the zip -- done!
        $zip->close();

        return null;
    }

    /**
     * Ensure Target Directory Exist or Create it
     *
     * @param string $targetFile
     *
     * @return null|string
     */
    private static function ensureDirectoryExists(string $targetFile): ?string
    {
        $filesystem = new Filesystem();

        //====================================================================//
        // Ensure Module Final Build Directory Exists
        if (!$filesystem->exists(dirname($targetFile))) {
            try {
                $filesystem->mkdir(dirname($targetFile));
            } catch (IOExceptionInterface $exception) {
                return "An error occurred while creating your directory at ".$exception->getPath();
            }
        }

        //====================================================================//
        // Verify Module Final Build Directory Exists
        if (!$filesystem->exists(dirname($targetFile))) {
            return "Unable to Create Final Module Build Directory: ".dirname($targetFile);
        }

        //====================================================================//
        // Remove Last Build File if Exists
        if (!$filesystem->exists($targetFile)) {
            $filesystem->remove($targetFile);
        }

        return null;
    }

    /**
     * Add Full Directory to Zip Archive
     *
     * @param ZipArchive $zip
     * @param string     $srcDirectory
     * @param string     $innerDirectory
     *
     * @return int
     */
    private static function addDir(ZipArchive $zip, string $srcDirectory, string $innerDirectory = ""): int
    {
        //====================================================================//
        // List Files to Add on Zip
        $finder = new Finder();
        $finder->ignoreDotFiles(false);
        $finder->files()->in($srcDirectory);
        // check if there are any search results
        if (!$finder->hasResults()) {
            return 0;
        }

        //====================================================================//
        // Add the files
        foreach ($finder as $file) {
            $zip->addFile(
                (string) $file->getRealPath(),
                $innerDirectory.$file->getRelativePathname()
            );
        }

        return $finder->count();
    }
}
