<?php

declare(strict_types=1);

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

namespace GrumPHP\Configuration;

use BadPixxel\PhpSdk\Configuration\Configuration;
use GrumPHP\Exception\DeprecatedException;
use Symfony\Component\Config\Definition\ConfigurationInterface;
use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Extension\Extension;

class GrumPHPExtension extends Extension
{
    /**
     * @param array            $configs
     * @param ContainerBuilder $container
     */
    public function load(array $configs, ContainerBuilder $container): void
    {
        $this->loadInternal(
            $this->processConfiguration(
                $this->getConfiguration($configs, $container),
                $configs
            ),
            $container
        );
    }

    /**
     * @SuppressWarnings(PHPMD.UnusedFormalParameter)
     *
     * @param array            $config
     * @param ContainerBuilder $container
     *
     * @return ConfigurationInterface
     */
    public function getConfiguration(array $config, ContainerBuilder $container): ConfigurationInterface
    {
        return new Configuration();
    }

    /**
     * @return string
     */
    public function getAlias(): string
    {
        return 'grumphp';
    }

    /**
     * @param array            $config
     * @param ContainerBuilder $container
     */
    private function loadInternal(array $config, ContainerBuilder $container): void
    {
        foreach ($config as $key => $value) {
            // We require to use grumphp instead of parameters at this point:
            if ($container->hasParameter($key)) {
                throw DeprecatedException::directParameterConfiguration($key);
            }

            $container->setParameter($key, $value);
        }
    }
}
