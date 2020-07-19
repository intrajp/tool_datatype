<?php

// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

/**
 * Plugin administration pages are defined here.
 *
 * @package     tool_datatype
 * @copyright   2020 Shintaro Fujiwara <shintaro.fujiwara@gmail.com>
 * @license     http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

if ($hassiteconfig) {
    $settings = new admin_settingpage('tool_datatype_settings', new lang_string('pluginname', 'tool_datatype'));

    $ADMIN->add('tools', $settings);

    $ADMIN->add(
        'development',
        new admin_externalpage(
            'tool_datatype', get_string('datatype', 'tool_datatype'),
            new moodle_url('/admin/tool/datatype/index.php')
        )
    );
    $settings->add( 
        new admin_setting_configtext(
            // This is the reference you will use to your configuration
            'tool_datatype/moodledatapath',
            // This is the friendly title for the config, which will be displayed
            get_string('setting:friendlyname', 'tool_datatype'),
            // This is helper text for this config field
            get_string('setting:helpertext', 'tool_datatype'),
            // This is the default value
            '',
            // This is the type of Parameter this config is
            PARAM_TEXT,
            50 // size
        ) 
     );
}
