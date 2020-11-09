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

global $config, $finder;

include_once "headers/badpixxel.php";

$finder = PhpCsFixer\Finder::create()
    ->in($_SERVER['PWD'])
    ->exclude('vendor')
    ->exclude('tests/Fixtures')
    ->exclude('var')
;

include_once "cs.rules.php";

return $config;