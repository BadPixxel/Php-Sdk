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

namespace BadPixxel\PhpSdk\Extension;

use BadPixxel\PhpSdk\Task\DocumentationBuilder;
use BadPixxel\PhpSdk\Task\ModuleBuilder;
use GrumPHP\Extension\ExtensionInterface;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Reference;

class Loader implements ExtensionInterface
{
    /**
     * @param ContainerBuilder $container
     *
     * @return void
     */
    public function load(ContainerBuilder $container): void
    {
        $this->addTask($container, ModuleBuilder::class, 'build-module');
        $this->addTask($container, DocumentationBuilder::class, 'build-docs');
    }

    /**
     * @param ContainerBuilder $container
     * @param string           $className
     * @param string           $taskName
     *
     * @return void
     */
    private function addTask(ContainerBuilder $container, $className, $taskName)
    {
        $container->register($className, $className)
            ->addArgument(new Reference('process_builder'))
            ->addArgument(new Reference('formatter.raw_process'))
            ->addArgument(new Reference('GrumPHP\Util\Paths'))
            ->addTag('grumphp.task', array('task' => $taskName))
        ;
    }
}
