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
 *
 * @package     tool_datatype
 * @copyright   2020 Shintaro Fujiwara <shintaro.fujiwara@gmail.com>
 * @license     http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

defined('MOODLE_INTERNAL') || die();

require_once($CFG->dirroot . '/admin/tool/datatype/classes/datatype_manager.php');

function tool_datatype_cron_task($dirroot, $analyzedir, $workdir) {
    \core_php_time_limit::raise(0);//infinite
    \raise_memory_limit(MEMORY_HUGE);
    $datatype_manager = new tool_datatype\datatype_manager();
    $exec_command = "$dirroot/admin/tool/datatype/file_size_m.sh";
    if ($datatype_manager->processDatatype($exec_command, $analyzedir, $workdir, "filedir") == false) {
        return false;
    }
    if ($datatype_manager->processDatatype($exec_command, $analyzedir, $workdir, "trashdir") == false) {
        return false;
    }
}
