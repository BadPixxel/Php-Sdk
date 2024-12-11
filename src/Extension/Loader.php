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

namespace BadPixxel\PhpSdk\Extension;

use BadPixxel\PhpSdk\Task\DocumentationBuilder;
use BadPixxel\PhpSdk\Task\ModuleBuilder;
use GrumPHP\Extension\ExtensionInterface;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Reference;

class Loader implements ExtensionInterface
{
    /**
     * @inheritDoc
     */
    public function imports(): iterable
    {
        $configDir = dirname(__DIR__).'/Resources/config';

        yield $configDir.'/tasks.yaml';
    }
}
