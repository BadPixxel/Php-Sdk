<?php


namespace BadPixxel\PhpSdk\Helper;


/**
 * Initialize Empty Local Class for Splash Modules
 *
 * To Work without System Config
 */
class SplashFaker
{
    /** @var string  */
    const CORE_CLASS = "\\Splash\\Core\\SplashCore";

    /** @var string  */
    const TEMPLATE_CLASS = "\\Splash\\Templates\\Local\\Local";

    /**
     * Init Empty Local Class
     */
    static public function init(): void
    {
        //====================================================================//
        // Check if Splash PhpCore Module is Loaded
        if(!class_exists(self::CORE_CLASS) || !class_exists(self::TEMPLATE_CLASS)) {
            return;
        }
        //====================================================================//
        // Load Splash as Empty Local Class
        $coreClass = self::CORE_CLASS;
        $templateClass = self::TEMPLATE_CLASS;
        $coreClass::setLocalClass(new $templateClass());
        $coreClass::translator()->load('local');
        $coreClass::log()->cleanLog();
    }

}