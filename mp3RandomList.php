<?php
### 车载音乐播放器随机列表
### 原播放器随机功能很差，特重新开发此程序，将音乐列表按照歌手打乱

$SONG_PATH = "I:\\";
$SONG_PATTERN = '/\\.mp3$/'; # 只搜mp3文件
$SONG_DELIMETER = ' - ';  # 文件名：歌手 - 歌曲.mp3
$WIDTH = 3; # 同一歌手几首内不再次出现
$OUTPUT_FILE = 'I:\\$APP$\\AudioFileList-new.cfg'
$OUTPUT_PRIFIX = "SDMMC\\";

function list2hash($s_list, $deli) {
    $d_hash = array();
    foreach ($s_list as $s) {
        list($artist, $name) = explode($deli, $s);
        $d_hash[$s] = $artist;
    }
    return $d_hash;
}

function random_except($s_hash, $s_list) {
    $d_list = array();
    foreach ($s_hash as $s => $artist) {
        if (!in_array($artist, $s_list)) {
            $d_list []= $s;
        }
    }
    $length = count($d_list);
    $random = rand(0, $length-1);
    return $d_list[$random];
}

function get_files($directory, $pattern) {
    $d_list = array();
    $handler = opendir($directory);
    while( ($filename = readdir($handler)) !== false ) {
        if(preg_match($pattern, $filename)) {
            $d_list []= $filename;
        }
    }
    closedir($handler);
    return $d_list;
}

$l = get_files($SONG_PATH, $SONG_PATTERN);
$h = list2hash($l, $SONG_DELIMETER);
$r = array();
$p_r = array();
while(count($h)) {
    $s = random_except($h, $p_r);
    $r []= $s;
    $p_r []= $s;
    unset($h[$s]);
    if (count($p_r) > $WIDTH) array_shift($p_r);
}
$handler = fopen($OUTPUT_FILE,'w');
foreach ($r as $s) {
    $convs = mb_convert_encoding($OUTPUT_PRIFIX.$s."\r\n", "UTF-16LE", "GBK");
    fwrite($handler,$convs);
}
fclose($handler);

?>
