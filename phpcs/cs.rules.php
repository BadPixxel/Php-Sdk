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

global $header, $finder;

$config = (new PhpCsFixer\Config())
    ->setRiskyAllowed(true)
    ->setRules(array(
        '@PSR2' => true,
        '@PHPUnit60Migration:risky' => true,
        'align_multiline_comment' => true,
        'array_indentation' => true,
        'array_syntax' => array('syntax' => 'long'),
        'blank_line_before_statement' => true,
        'combine_consecutive_issets' => true,
        'combine_consecutive_unsets' => true,
        'comment_to_phpdoc' => true,
        'compact_nullable_typehint' => true,
        'escape_implicit_backslashes' => true,
        'explicit_indirect_variable' => true,
        'explicit_string_variable' => true,
        'final_internal_class' => true,
        'fully_qualified_strict_types' => true,
        'function_to_constant' => array(
            'functions' => array('get_class', 'get_called_class', 'php_sapi_name', 'phpversion', 'pi')
        ),
        'header_comment' => array('header' => $header),
        'heredoc_to_nowdoc' => true,
        'list_syntax' => array('syntax' => 'long'),
        'logical_operators' => true,
        'method_argument_space' => array('on_multiline' => 'ensure_fully_multiline'),
        'method_chaining_indentation' => true,
        'multiline_comment_opening_closing' => true,
        'no_alternative_syntax' => true,
        'no_binary_string' => true,
        'no_extra_blank_lines' => array(
            'tokens' => array(
                'break', 'continue', 'extra',
                'return', 'throw', 'use',
                'parenthesis_brace_block',
                'square_brace_block',
                'curly_brace_block'
            )
        ),
        'no_null_property_initialization' => true,
        'no_superfluous_elseif' => true,
        'no_unneeded_curly_braces' => true,
        'no_unneeded_final_method' => true,
        'no_unreachable_default_argument_value' => true,
        'no_unset_on_property' => true,
        'no_useless_else' => true,
        'no_useless_return' => true,
        'ordered_class_elements' => true,
        'ordered_imports' => true,
        'php_unit_internal_class' => false,
        'php_unit_method_casing' => true,
        'php_unit_set_up_tear_down_visibility' => true,
        'php_unit_strict' => false,
        'php_unit_test_annotation' => true,
        'php_unit_test_case_static_method_calls' => array('call_type' => 'this'),
        'php_unit_test_class_requires_covers' => false,
        'phpdoc_add_missing_param_annotation' => true,
        'phpdoc_align' => true,
        'phpdoc_order' => true,
        'phpdoc_no_useless_inheritdoc' => true,
        'phpdoc_separation' => true,
        'phpdoc_trim_consecutive_blank_line_separation' => true,
        'phpdoc_types_order' => true,
        'phpdoc_no_empty_return' => false,
        'phpdoc_trim' => true,
        'return_assignment' => true,
        'semicolon_after_instruction' => true,
        'single_line_comment_style' => true,
        'strict_param' => true,
        'string_line_ending' => true,
        'yoda_style' => true,
        'no_whitespace_in_blank_line' => true,
        'single_quote' => false,
        'concat_space' => true,
        'binary_operator_spaces' => true,
        'no_unused_imports' => true,
    ))
    ->setFinder($finder)
;
