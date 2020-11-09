<?php

declare(strict_types=1);

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

namespace BadPixxel\PhpSdk\Configuration;

use GrumPHP\Configuration\Configuration as BaseConfiguration;
use Symfony\Component\Config\Definition\Builder\TreeBuilder;

/**
 * Override Grumphp Configuration to Allow Tasks & Test Suites Merge
 */
class Configuration extends BaseConfiguration
{
    /**
     * @return TreeBuilder
     */
    public function getConfigTreeBuilder(): TreeBuilder
    {
        //==============================================================================
        // Load Original Tree Builder
        $treeBuilder = parent::getConfigTreeBuilder();
        $rootNode = $treeBuilder->getRootNode();
        //==============================================================================
        // Override Tasks ArrayNode
        $rootNode->find('tasks')->useAttributeAsKey('name');
        //==============================================================================
        // Override TestSuite ArrayNode
        $rootNode->find('testsuites')->useAttributeAsKey('name');

        return $treeBuilder;
    }
}
