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
 * File containing the general information page.
 *
 * @package     tool_datatype
 * @category    admin
 * @copyright   2020 Shintaro Fujiwara <shintaro dot fujiwara at gmail dot com>
 * @license     http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

require(__DIR__.'/../../../config.php');
require_once($CFG->libdir.'/adminlib.php');
require_once($CFG->libdir.'/moodlelib.php');
require_once($CFG->dirroot.'/admin/tool/datatype/classes/renderer.php');

if (isguestuser()) {
    throw new require_login_exception('Guests are not allowed here.');
}

// This is a system level page that operates on other contexts.
require_login();

admin_externalpage_setup('tool_datatype');

$url = new moodle_url('/admin/tool/datatype/index.php');
$PAGE->set_url($url);
$PAGE->set_title(get_string('datatype', 'tool_datatype'));
$PAGE->set_heading(get_string('datatype', 'tool_datatype'));

$returnurl = new moodle_url('/admin/tool/datatype/index.php');

echo $OUTPUT->header();

$outputdir = "$CFG->dataroot" . "/temp/filestorage/output_intrajp";

$files = scandir($outputdir);
$cnt = count($files);
for($i = 0; $i < $cnt; $i++) {
    if (file_exists($files[$i])) {
        $contents = file_get_contents($files[$i]);
        $contents = str_replace ("\n", "<br />", $contents);
        echo "$contents";
    }
}

echo $OUTPUT->footer();
