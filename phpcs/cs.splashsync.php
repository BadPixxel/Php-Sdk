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

global $config, $finder;

include_once "headers/splashsync.php";

/** @var string $pwd */
$pwd = $_SERVER['PWD'];

$finder = PhpCsFixer\Finder::create()
    ->in($pwd)
    ->exclude('vendor')
    ->exclude('tests/Fixtures')
    ->exclude('var')
;

include_once "cs.rules.php";

return $config;
