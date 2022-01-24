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

namespace BadPixxel\PhpSdk\Helper;

/**
 * Execute Shell Command Line Actions
 */
class ShellRunner
{
    /**
     * Execute a Shell Action
     *
     * @param string $command
     *
     * @return null|string
     */
    public static function run(string $command): ?string
    {
        //====================================================================//
        // Prepare Returns Variables
        $outputs = array();
        $return = 0;
        //====================================================================//
        // Execute Shell Operation
        exec($command, $outputs, $return);
        //====================================================================//
        // Failed => Push Outputs to Splash Log
        if ($return) {
            return implode(". ", $outputs);
        }

        return null;
    }
}
